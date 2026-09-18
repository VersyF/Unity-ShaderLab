#ifndef ML_Lambert
#define ML_Lambert
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

TEXTURE2D(_MainTex);
SAMPLER(sampler_MainTex);

CBUFFER_START(UnityPerMaterial)
    float4 _MainTex_ST;
CBUFFER_END

// 输入结构
struct Attributes
{
    float4 positionOS : POSITION;
    float2 uv : TEXCOORD0;
    float3 normal : NORMAL;
};

// 输出结构
struct Varyings
{
    float4 positionHCS : SV_POSITION;
    float2 uv : TEXCOORD0;
    float3 normalWS : TEXCOORD1;
};

// 顶点着色器
Varyings vert(Attributes IN)
{
    Varyings OUT;
    OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
    OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
    
    VertexNormalInputs vertexNor = GetVertexNormalInputs(IN.normal);
    OUT.normalWS = vertexNor.normalWS;
    return OUT;
}

// 片元着色器
half4 frag(Varyings IN) : SV_Target
{
    Light mainLight = GetMainLight();
    float3 lightDir = mainLight.direction;
    float lambert = saturate(dot(lightDir, IN.normalWS));
    
    half3 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
    
    return half4(mainTex * mainLight.color * lambert, 1);
}

#endif