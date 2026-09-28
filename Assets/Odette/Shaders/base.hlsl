#ifndef HLSL_OdetteBase
#define HLSL_OdetteBase

void Odette_Base_MainTex_float
(
    float2 _UV,
    UnitySamplerState _Sampler,
    UnityTexture2D _Main,
    out float3 output
)
{
    output = SAMPLE_TEXTURE2D(_Main, _Sampler, _UV);
}

#endif