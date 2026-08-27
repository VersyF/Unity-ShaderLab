#ifndef HLSL_NC_RampSamp
#define HLSL_NC_RampSamp

// 官方版本的RampShadowID函数
float RampShadowID(float input, float useShadow2, float useShadow3, float useShadow4, float useShadow5, 
    float shadowValue1, float shadowValue2, float shadowValue3, float shadowValue4, float shadowValue5)
{
    // 根据input值将模型分为5个区域
    float v1 = step(0.6, input) * step(input, 0.8); // 0.6-0.8区域
    float v2 = step(0.4, input) * step(input, 0.6); // 0.4-0.6区域
    float v3 = step(0.2, input) * step(input, 0.4); // 0.2-0.4区域
    float v4 = step(input, 0.2);                    // 0-0.2区域

    // 根据开关控制是否使用不同材质的值
    float blend12 = lerp(shadowValue1, shadowValue2, useShadow2);
    float blend15 = lerp(shadowValue1, shadowValue5, useShadow5);
    float blend13 = lerp(shadowValue1, shadowValue3, useShadow3);
    float blend14 = lerp(shadowValue1, shadowValue4, useShadow4);

    // 根据区域选择对应的材质值
    float result = blend12;                // 默认使用材质1或2
    result = lerp(result, blend15, v1);    // 0.6-0.8区域使用材质5
    result = lerp(result, blend13, v2);    // 0.4-0.6区域使用材质3
    result = lerp(result, blend14, v3);    // 0.2-0.4区域使用材质4
    result = lerp(result, shadowValue1, v4); // 0-0.2区域使用材质1

    return result;
}

void V1_RampSamper_float
(
    UnityTexture2D _RampMap,
    float _ShadowCoe,
    float _LightMapAlpha,
    float _BrightArea,      //0 - 1
    UnitySamplerState _Sampler,
    float _UseRamp2,
    float _UseRamp3,
    float _UseRamp4,
    float _UseRamp5,
    out float3 output
)
{
    //Calculate uv
    float u = saturate(_BrightArea + _ShadowCoe);
    float v = RampShadowID(_LightMapAlpha, _UseRamp2, _UseRamp3, _UseRamp4, _UseRamp5, 1, 2, 3, 4, 5);
    float2 uv = float2(u,v);

    //Samp
    float3 rampColor = SAMPLE_TEXTURE2D(_RampMap, _Sampler, uv);

    output = rampColor;
    return;
}

#endif


