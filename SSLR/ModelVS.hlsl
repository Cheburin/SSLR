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

struct PosNormalTex2d
{
    float3 pos : SV_Position;
    float3 normal   : NORMAL;
    float2 tex      : TEXCOORD0;
};

struct ClipPosNormalTex2d
{
    float3 normal         : TEXCOORD1;   // Normal vector in world space
    float2 tex            : TEXCOORD2;
	float2 bary           : TEXCOORD3;
	float3 wpos           : TEXCOORD4;
	float3 v_w_pos[3]     : THREEPOS;
    float4 clip_pos       : SV_POSITION; // Output position
};
///////////////////////////////////////////////////////////////////////////////////////////////////

ClipPosNormalTex2d MODEL_VERTEX( in PosNormalTex2d i )
{
    ClipPosNormalTex2d output = (ClipPosNormalTex2d)0.0f;

    output.tex = i.tex;

    output.normal = normalize( mul( float4( i.normal, 0.0 ), g_mWorldView ).xyz );

    output.wpos =              mul( float4( i.pos,    1.0 ), g_mWorld ).xyz;

    output.clip_pos =          mul( float4( i.pos,    1.0 ), g_mWorldViewProjection );
    
    return output;
}; 

[maxvertexcount(3)]
void MODEL_GS( triangle ClipPosNormalTex2d In[3], inout TriangleStream<ClipPosNormalTex2d> SceneEnvStream )
{	
	In[0].bary = float2(0,0);
	In[1].bary = float2(1,0);
	In[2].bary = float2(0,1);

    In[0].v_w_pos[0] = In[1].v_w_pos[0] = In[2].v_w_pos[0] = In[0].wpos;

    In[0].v_w_pos[1] = In[1].v_w_pos[1] = In[2].v_w_pos[1] = In[1].wpos;

    In[0].v_w_pos[2] = In[1].v_w_pos[2] = In[2].v_w_pos[2] = In[2].wpos;

	SceneEnvStream.Append( In[0] );
	SceneEnvStream.Append( In[1] );
	SceneEnvStream.Append( In[2] );

	SceneEnvStream.RestartStrip();
}