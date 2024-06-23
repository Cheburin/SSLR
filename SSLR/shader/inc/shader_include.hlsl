//--------------------------------------------------------------------------------------
// Defines
//--------------------------------------------------------------------------------------                  
#define ADD_SPECULAR 0
                                          
//--------------------------------------------------------------------------------------
// Structures
//--------------------------------------------------------------------------------------

struct PosNormalTex2d
{
    float3 pos : SV_Position;
    float3 normal   : NORMAL;
    float2 tex      : TEXCOORD0;
};

struct PosNormalTangetColorTex2d
{
    float3 pos      : SV_Position;
    float3 normal   : NORMAL;
    float4 tangent  : TANGENT; 
    float4 color    : COLOR0;
    float2 tex      : TEXCOORD0;
};

struct ExpandPosNormalTangetColorTex2d
{
    float3 normal   : NORMAL;
    float4 tangent  : TANGENT; 
    float4 color    : COLOR0;
    float2 tex      : TEXCOORD0;
    float4 pos      : SV_POSITION;
};

struct ExpandPosNormalTex2d
{
    float3 normal   : NORMAL;
    float2 tex      : TEXCOORD0;
    float4 pos      : SV_POSITION;
};

struct ExpandPos
{
    float4 pos      : SV_POSITION;
};

struct ClipPosTex2d
{
    float2 tex            : TEXCOORD0;
    float4 clip_pos       : SV_POSITION; // Output position
};

struct ClipPosTex4d
{
    float4 tex            : TEXCOORD0;
    float4 clip_pos       : SV_POSITION; // Output position
};

struct ClipPosTex2dTex4d
{
    float4 tex4d            : TEXCOORD0;
    float2 tex2d            : TEXCOORD1;
    float4 clip_pos       : SV_POSITION; // Output position
};

struct ClipPosTex3d
{
    float3 tex            : TEXCOORD0;
    float4 clip_pos       : SV_POSITION; // Output position
};

struct ClipPosPosNormalTex2d
{
    float3 pos            : TEXCOORD0;
    float3 normal         : TEXCOORD1;   // Normal vector in world space
    float2 tex            : TEXCOORD2;
    float4 clip_pos       : SV_POSITION; // Output position
};

struct ClipPosPosNormalTex2dClipDist0
{
    float3 pos            : TEXCOORD0;
    float3 normal         : TEXCOORD1;   // Normal vector in world space
    float2 tex            : TEXCOORD2;
    float4 clip_pos       : SV_POSITION; // Output position
    float clip : SV_ClipDistance0;
};


struct ClipPosPosNormalTex2dTex4d
{
    float3 pos            : TEXCOORD0;
    float3 normal         : TEXCOORD1;   // Normal vector in world space
    float2 tex_0          : TEXCOORD2;
    float4 tex_1          : TEXCOORD3;
    float4 clip_pos       : SV_POSITION; // Output position
};

struct ClipPosNormalTex2d
{
    float3 normal         : TEXCOORD1;   // Normal vector in world space
    float2 tex            : TEXCOORD2;
    float4 clip_pos       : SV_POSITION; // Output position
};

struct ClipPosNormal
{
    float3 normal         : TEXCOORD0;
    float4 clip_pos       : SV_POSITION;
};

struct ClipPosPosNormalTangentBitangentTex2d
{
    float3 pos            : TEXCOORD0;
    float3 normal         : TEXCOORD1;
    float3 tangent        : TEXCOORD2;
    float3 bitangent      : TEXCOORD3;
    float2 tex            : TEXCOORD4;
    float4 clip_pos       : SV_POSITION; // Output position
};

struct ClipPosColor
{
    float4 color          : TEXCOORD0;
    float4 clip_pos       : SV_POSITION; // Output position
};

struct ThreeTargets
{
    float4 target0: SV_Target0;

    float4 target1: SV_Target1;

    float4 target2: SV_Target2;
};

//--------------------------------------------------------------------------------------
// Constant Buffers
//--------------------------------------------------------------------------------------
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

float DepthLinear(float near, float far, float depth){
  return near * far / (far - depth * (far - near));
}

struct Light
{
	float3 position;
	uint lightType;
	float3 direction;
	float falloff;
	float3 diffuseColor;
	float angle;
	float3 ambientColor;
	uint dummy;
	float3 specularColor;
	uint dummy2;
};
