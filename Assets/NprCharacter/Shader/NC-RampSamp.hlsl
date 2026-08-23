#ifndef HLSL_NC_RampSamp
#define HLSL_NC_RampSamp

void V1_RampSamper_float
(
    UnityTexture2D _RampMap,
    float _ShadowCoe,
    float _BrightArea,      //0 - 1
    UnitySamplerState _Sampler,
    out float3 output
)
{
    //Calculate uv
    float u = saturate(_BrightArea + _ShadowCoe);
    float v = 0.5;
    float2 uv = float2(u,v);

    //Samp
    float3 rampColor = SAMPLE_TEXTURE2D(_RampMap, _Sampler, uv);

    output = rampColor;
    return;
}

#endif


