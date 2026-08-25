#ifndef HLSL_NC_SDF
#define HLSL_NC_SDF

void V1_SDFSampler_float
(
    UnityTexture2D _SDF,
    UnityTexture2D _ShadowMask,
    float2 uv,
    UnitySamplerState _Sampler,
    float3 headUpDir,
    float3 headRightDir,
    float3 headForwardDir,
    float3 _Light,
    out float output
)
{
    headUpDir = (0, 1 ,0);
    headRightDir = (1, 0, 0);
    headForwardDir = (0, 0, 1);

    float4 shadowMask = SAMPLE_TEXTURE2D(_ShadowMask, _Sampler, uv);

    //sdf模板
    half3 LpU = dot(_Light, headUpDir) / pow(length(headUpDir), 2) * headUpDir; // 计算光源方向在面部上方的投影
    half3 LpHeadHorizon = normalize(_Light - LpU); // 光照方向在头部水平面上的投影
    half value = acos(dot(LpHeadHorizon, headRightDir)) / 3.141592654; // 计算光照方向与面部右方的夹角
    half exposeRight = step(value, 0.5); // 判断光照是来自右侧还是左侧
    half valueR = pow(1 - value * 2, 3); // 右侧阴影强度
    half valueL = pow(value * 2 - 1, 3); // 左侧阴影强度
    half mixValue = lerp(valueL, valueR, exposeRight); // 混合阴影强度
    half sdfLeft = SAMPLE_TEXTURE2D(_SDF, _Sampler, half2(1 - uv.x, uv.y)).r; // 左侧距离场
    half sdfRight = SAMPLE_TEXTURE2D(_SDF, _Sampler, uv).r; // 右侧距离场
    half mixSdf = lerp(sdfRight, sdfLeft, exposeRight); // 采样SDF纹理
    half sdf = step(mixValue, mixSdf); // 计算硬边界阴影
    sdf = lerp(0, sdf, step(0, dot(LpHeadHorizon, headForwardDir))); // 计算右侧阴影
    sdf *= shadowMask.g; // 使用G通道控制阴影强度
    sdf = lerp(sdf, 1, shadowMask.a); // 使用A通道作为阴影遮罩

    output = sdf;
    return;
}

#endif


