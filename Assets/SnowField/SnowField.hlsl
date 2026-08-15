#ifndef HLSL_SnowField
#define HLSL_SnowField

void SnowField_ViewHighLight_float
(
    float3 _ViewDir,
    float3 _PixelPos,
    float3 _Normal,
    float _BlingScale,
    out float output
)
{
    
    output = dot(_Normal, normalize(_ViewDir));
    output = exp((output - 1) * _BlingScale);

}

void SnowField_SampleNormal_float
(
    UnityTexture2D _MainTex,
    UnitySamplerState _Sampler,
    float2 _UV,
    out float3 output
)
{
    float4 packedNormal = SAMPLE_TEXTURE2D(_MainTex, _Sampler, _UV);
    float3 normal = UnpackNormalmapRGorAG(packedNormal);
    output = normal;
}

void SnowField_MainTex_float
(
    UnityTexture2D _MainTex,
    float3 _BaseNormal,
    UnitySamplerState _Sampler,
    float2 _UV,
    float3 _Light,
    float _Darkness,
    out float3 output
)
{
    output = SAMPLE_TEXTURE2D(_MainTex, _Sampler, _UV);
    float light = dot(_BaseNormal, _Light);
    output = lerp(output, output * (1 - _Darkness), -light);
}

#endif