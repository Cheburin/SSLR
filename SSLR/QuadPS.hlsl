cbuffer cbMain : register( b0 )
{
	matrix    g_mWorld;                         // World matrix
	matrix    g_mView;                          // View matrix
	matrix    g_mProjection;                    // Projection matrix
	matrix    g_mWorldViewProjection;           // WVP matrix
	matrix    g_mWorldView;                     // WV matrix
	matrix    g_mInvView;                       // Inverse of view matrix

	matrix    g_mObject1;                // VP matrix
	matrix    g_mObject1WorldView;                       // Inverse of view matrix
	matrix    g_mObject1WorldViewProjection;                       // Inverse of view matrix

	matrix    g_mObject2;                // VP matrix
	matrix    g_mObject2WorldView;                       // Inverse of view matrix
	matrix    g_mObject2WorldViewProjection;                       // Inverse of view matrix

	float4    g_vFrustumNearFar;              // Screen resolution
	float4    g_vFrustumParams;              // Screen resolution
	float4    g_viewLightPos;                   //

    float4    g_FocalLen;
};

Texture2D<float4> colorMap                 : register( t0 );
Texture2D<float4> normalMap                : register( t1 );
Texture2D<float>  depthMap                 : register( t2 );

/////////////////////////////////////////////////////////////
float3 GetColor(float2 frag)
{
    frag.x = frag.x;//clamp(frag.x, 0, g_vFrustumParams.x );
    frag.y = frag.y;//clamp(frag.y, 0, g_vFrustumParams.y );
	  return colorMap.Load( int3(frag.xy,0) ).xyz;
}

float3 GetNormal(float2 frag)
{
    frag.x = frag.x;//clamp(frag.x, 0, g_vFrustumParams.x );
    frag.y = frag.y;//clamp(frag.y, 0, g_vFrustumParams.y );
	  return normalMap.Load( int3(frag.xy,0) ).xyz;
}

float GetDepth(float2 frag)
{
    frag.x = frag.x;//clamp(frag.x, 0, g_vFrustumParams.x );
    frag.y = frag.y;//clamp(frag.y, 0, g_vFrustumParams.y );
    return normalMap.Load( int3(frag.xy,0) ).w;
    //return depthMap.Load(  int3(frag.xy,0) ).x;
}

float NonLinearToLinearDepth(float depth)
{
    float near = g_vFrustumNearFar.x;
    float far =  g_vFrustumNearFar.y;
    return near * far / (far - depth * (far - near));
}

float LinearToNonLinearDepth(float depth)
{
    float near = g_vFrustumNearFar.x;
    float far =  g_vFrustumNearFar.y;
    return far/(far-near) - near*far/(depth*(far-near));
}
/////////////////////////////////////////////////////////////
float3 GetPosition(float2 frag, float depth)
{
    float2 texcoords = frag.xy/g_vFrustumParams.xy;
    //float eye_z = NonLinearToLinearDepth(depth);
    float eye_z = depth;

    texcoords.xy -= float2(0.5, 0.5);
    texcoords.xy /= float2(0.5, -0.5);
    float2 eye_xy = (texcoords.xy / g_FocalLen.xy) * eye_z;

    //float2 ndc = float2(frag.xy/g_vFrustumParams.xy) * float2(2, -2) + float2(-1, 1); 
    //float3 view_p = NonLinearToLinearDepth(depth) * float3(ndc.x * g_vFrustumParams.w/g_vFrustumParams.z, ndc.y * 1/g_vFrustumParams.z, 1);
    //return mul( float4( float3(eye_xy, eye_z), 1.0 ), g_mInvView ).xyz;

    return float3(eye_xy, eye_z);
}

float3 GetProjection(float3 eye)
{
    //float3 eye = mul( float4(position, 1.0f), g_mView).xyz;

    float2 win = g_FocalLen.xy * eye.xy / eye.z;
    win.xy *= float2(0.5, -0.5);
    win.xy += float2(0.5, 0.5);

    //return float3(win.xy*g_vFrustumParams.xy, LinearToNonLinearDepth(eye.z));
    return float3(win.xy*g_vFrustumParams.xy, eye.z);

	 //float4 projected_p = mul( float4(position, 1.0f), g_mWorldViewProjection);
     //projected_p /= projected_p.w;
	 //return float3((float2(0.5f, -0.5f) * projected_p.xy + float2(0.5f, 0.5f))*g_vFrustumParams.xy, projected_p.z);
}
/////////////////////////////////////////////////////////////
float4 PS(in float4 frag: SV_POSITION):SV_TARGET
{ 
    float3 texelColor =       GetColor(frag.xy);
    float3 texelNormal =     GetNormal(frag.xy);
    float  texelDepth =       GetDepth(frag.xy);
    float3 texelPosition = GetPosition(frag.xy, texelDepth);

    //float3 cameraPosition = g_mInvView._m30_m31_m32;
    
    float3 V = normalize(-texelPosition);

    float3 R = -normalize(reflect(V, texelNormal));

    ///new version
    float maxDistance = 50;
    float resolution  = 0.5;
    int   steps       = 10;
    float thickness   = 1; 

    float3 positionFrom = texelPosition;

    float3 pivot            = R;

    float3 positionTo = positionFrom; 

    float3 startView = positionFrom + (pivot *           0);
    float3 endView   = positionFrom + (pivot * maxDistance); 

    float3 startFrag = GetProjection(startView.xyz);    
    float3 endFrag = GetProjection(endView.xyz);
    
    if(0.1 > endFrag.z || endFrag.z > 500.0){
      return float4(texelColor, 1); 
    }

    float2 frag2  = startFrag.xy;
    
    float deltaX    = endFrag.x - startFrag.x;
    float deltaY    = endFrag.y - startFrag.y;
    float useX      = abs(deltaX) >= abs(deltaY) ? 1 : 0;
    float delta     = lerp(abs(deltaY), abs(deltaX), useX) * clamp(resolution, 0, 1);
    float2 increment = float2(deltaX, deltaY) / max(delta, 0.001);

    float search0 = 0;
    float search1 = 0;

    int hit0 = 0;
    int hit1 = 0;

    float viewDistance = startView.z;
    float depth        = thickness;

    for (int i = 0; i < min(int(delta),400); ++i) {
        frag2      += increment;
        positionTo = GetPosition(frag2.xy, GetDepth(frag2.xy));

        search1 =
          lerp //зачем? Ответ так как одно из измерений может схлопнуться в ноль
            ( (frag2.y - startFrag.y) / deltaY
            , (frag2.x - startFrag.x) / deltaX
            , useX
            );

        search1 = clamp(search1, 0, 1);

        viewDistance = (startView.z * endView.z) / lerp(endView.z, startView.z, search1);
        depth        = viewDistance - positionTo.z;

        if (depth > 0) {
            hit0 = 1;
            break;
        } else {
            search0 = search1;
        }
    }     

    search1 = search0 + ((search1 - search0) / 2);

    steps *= hit0;
/*
    for (int j = 0; j < steps; ++j) {
      frag2       = lerp(startFrag.xy, endFrag.xy, search1);
      positionTo = GetPosition(frag2.xy, GetDepth(frag2.xy));

      viewDistance = (startView.z * endView.z) / lerp(endView.z, startView.z, search1);
      depth        = viewDistance - positionTo.z;

      if (depth > 0 && depth < 0.5) {
        hit1 = 1;
        search1 = search0 + ((search1 - search0) / 2);
      } else {
        float temp = search1;
        search1 = search1 + ((search1 - search0) / 2);
        search0 = temp;
      }
    }
*/
    float3 rColor = float3(0,0,0);

    if(hit0 == 1)
      if(clamp(frag2.x, 0, g_vFrustumParams.x-1)==frag2.x)
        if(clamp(frag2.y, 0, g_vFrustumParams.y-1)==frag2.y) 
          if(0.1 <= positionTo.z && positionTo.z <= 500.0)
            if(length(positionTo - positionFrom)<maxDistance)
              //if(depth < 0.001)
                rColor = GetColor(frag2.xy).rgb;

    return float4(texelColor+rColor, 1);   
    ///new version

    //float frenel = saturate(pow(1-dot(V, texelNormal), 1));
    //return float4(frenel, frenel, frenel, 0);
    //float LDelmiter = 0.001;

    float3 newPosition = float3(0,0,0);
    float3 currentPosition = 0;
    float3 nuv = 0;
    float n = 0;
    float L = 0.1;

    float prev_depth = 1;
    float next_L;
    float error = 0;
    for(int i = 0; i < 100; i++)
    {
        currentPosition = texelPosition + R * L;

        //if(currentPosition.z<0.1){
        //    error = 1;
        //    break;
        //}

        nuv = GetProjection(currentPosition);

        //if(abs(prev_depth - nuv.z)<0.0001){
           //error = 0; 
           //break; 
        //}
        //prev_depth = nuv.z;

        //if(clamp(nuv.x, 0, g_vFrustumParams.x)!=nuv.x){
        //    error = 1; 
        //    break;
        //};
        //if(clamp(nuv.y, 0, g_vFrustumParams.y)!=nuv.y){
        //    error = 1; 
        //    break;
        //};

        n = GetDepth(nuv.xy);

        L = length(texelPosition - GetPosition(nuv.xy, n));    

        //if(next_L < L && i<100){
        //    error = 1;
        //    break; 
        //}

        //L = next_L;
    }

    float3 reflectColor = float3(0,0,0);

    if(clamp(nuv.x, 0, g_vFrustumParams.x)==nuv.x)
      if(clamp(nuv.y, 0, g_vFrustumParams.y)==nuv.y) 
        if(0.1 <= currentPosition.z && currentPosition.z <= 500.0)
          if(length(currentPosition - texelPosition)>0.1)
            if(abs(nuv.z - n)<0.01)
              reflectColor = GetColor(nuv.xy).rgb;
     
    return float4(texelColor+reflectColor, 1);//float4(color*reflectionMultiplier, 1);//float4(color + cnuv, 1);

    //L = saturate(L * LDelmiter);
    //float error = (1 - L);
    //if(abs(n-nuv.z)<0.0001)
    //float fresnel = 0.0 + 2.8 * pow(1+dot(viewDir, normal), 2);

    /*
    float4 reflectionDistanceFadeFactor = float4(1,1,1,1);
    float4 edgeFactorPower = float4(1,1,1,1);
    float fresnel = 1;
    
    float distFactor = 1.0 - saturate(L * reflectionDistanceFadeFactor.x);

    float2 vCoordsEdgeFact = float2(1.0, 1.0) - pow(saturate(abs(nuv.xy - float2(0.5, 0.5)) * 2.0), edgeFactorPower.x);
    float fScreenEdgeFactor = saturate(min(vCoordsEdgeFact.x, vCoordsEdgeFact.y));
    float reflectionMultiplier = fresnel * saturate(reflectDir.z) * fScreenEdgeFactor;
    reflectionMultiplier = clamp(reflectionMultiplier, 0.0, 1.0);
    */
}