#ifndef HLSL_NC_ShadowCore
#define HLSL_NC_ShadowCore

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
    UnitySamplerState _Sampler,
    float2 uv,
    float3 _LightDirOS,
    float3 _NormalOS,
    out float output
)
{
    float amb = SAMPLE_TEXTURE2D(_LightMap, _Sampler, uv).g;
    float lambert = saturate(dot(-_LightDirOS, _NormalOS) / 2 + 0.5);
    output = 0.5 * amb + 0.5 * lambert;
    return;
}

#endif


