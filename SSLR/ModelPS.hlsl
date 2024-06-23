Texture2D colorMap  : register( t0 );

SamplerState linearSampler : register( s0 );

struct Targets
{
    float4 color: SV_Target0;

    float4 normal: SV_Target1;
};

Targets MODEL_FRAG(
    float3 normal         : TEXCOORD1,
    float2 tex            : TEXCOORD2,
	float2 bary           : TEXCOORD3,
	float3 wpos           : TEXCOORD4,
	float3 v_w_pos[3]     : THREEPOS,
    float4 clip_pos       : SV_POSITION
):SV_TARGET
{ 
   Targets output;

   output.color = colorMap.Sample( linearSampler, tex.xy);

   float3 BA = v_w_pos[1] - v_w_pos[0];

   float3 CA = v_w_pos[2] - v_w_pos[0];

   float3 CB =  v_w_pos[2] - v_w_pos[1];

   float3 PA = bary.x*BA + bary.y*CA;

   float3 PB = PA + v_w_pos[0] - v_w_pos[1];

   BA = normalize(BA);

   CA = normalize(CA);

   CB = normalize(CB);

   if(abs(length(PA - dot(PA, BA)*BA))<0.08) //dot(PA, BA)>.0 && 
     output.color = float4(0,1,1,1);   
   else if(abs(length(PA - dot(PA, CA)*CA))<0.08) //dot(PA, CA)>.0 &&
     output.color = float4(0,1,1,1);     
   else if(abs(length(PB - dot(PB, CB)*CB))<0.08) //dot(PB, CB)>.0 && 
     output.color = float4(0,1,1,1);    

   output.normal = float4(normalize( normal ),clip_pos.w);

   return output;
};
