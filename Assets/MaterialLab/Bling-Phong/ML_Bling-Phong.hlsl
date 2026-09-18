#ifndef ML_HLSL_BF
#define ML_HLSL_BF

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

TEXTURE2D (_MainTex);
SAMPLER(sampler_MainTex);

CBUFFER_START(UnityPerMaterial)
    float4 _MainTex_ST;
    half3 _AmbientLight;
    float _specularPow;
    float _AmbientStrength;
CBUFFER_END

struct a2v
{
    float4 positionOS : POSITION;
    float2 uv : TEXCOORD0;
    float3 normalOS : NORMAL;
    
};

struct v2f
{
    float4 positionCS : SV_Position;
    float2 uv : TEXCOORD0;
    float3 normalWS : TEXCOORD1;
    float3 positionWS : TEXCOORD2;
    
};

v2f vert(a2v IN)
{
    v2f OUT;
    VertexPositionInputs vertexPos = GetVertexPositionInputs(IN.positionOS);
    VertexNormalInputs vertexNormal = GetVertexNormalInputs(IN.normalOS);
    
    OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
    OUT.positionCS = vertexPos.positionCS;
    OUT.normalWS = vertexNormal.normalWS;
    OUT.positionWS = vertexPos.positionWS;

    return OUT;
}

half4 frag(v2f IN) : SV_TARGET
{
    Light light = GetMainLight();
    float3 lightDir = light.direction;
    
    //HalfLambert
    float lambert = (dot(lightDir, IN.normalWS));
    lambert = saturate(lambert * 0.5 + 0.5);
    
    half3 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
    
    //Bling-Phong Highlight
    float3 cameraWS = _WorldSpaceCameraPos;
    float3 viewDirRe = cameraWS - IN.positionWS;
    viewDirRe = normalize(viewDirRe);
    
    float3 H = normalize(viewDirRe + lightDir);
    float spec = pow(saturate(dot(H, IN.normalWS)), _specularPow);
    
    return half4(_AmbientLight * _AmbientStrength + mainTex * light.color * (lambert + spec), 1);
    
}

#endif