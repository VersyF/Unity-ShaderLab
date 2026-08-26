#ifndef HLSL_NC_ShadowCoe
#define HLSL_NC_ShadowCoe

void LambertShadow_float
(
    float3 _LightDirOS,
    float3 _NormalOS,
    out float output
)
{
    output = saturate(dot(-_LightDirOS, _NormalOS) / 2 + 0.5);
    return;
}

void V2_LightMap_float
(
    UnityTexture2D _LightMap,
    float3 _VertexColor,
    UnitySamplerState _Sampler,
    float2 uv,
    float3 _LightDirOS,
    float3 _NormalOS,
    out float2 output
)
{
    float4 amb = SAMPLE_TEXTURE2D(_LightMap, _Sampler, uv);
    float lambert = saturate(dot(-_LightDirOS, _NormalOS) / 2 + 0.5);
    output.x = 0.5 * amb.g + 0.5 * lambert;
    output.y = amb.a;           //output y分量存储LightMap 的 Alpha 值
    return;
}

#endif


