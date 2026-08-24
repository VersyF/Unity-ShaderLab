#ifndef HLSL_IceGround
#define HLSL_IceGround

//纹理采样方面
void IceGround_Texture_float
(
    float3 _PixelPos,
    float3 _CameraPos,
    float _OffScale,
    float _LoopNum,
    float _Lerp,
    float _Atten,
    float2 _UV,
    UnityTexture2D _MainTex,
    UnitySamplerState _SamplerState,
    out float3 output
)
{
    float3 baseColor = SAMPLE_TEXTURE2D(_MainTex, _SamplerState, _UV);
    float3 color0 = 0;
    
    float3 color_cache;
    float2 viewDir = -float2(_PixelPos.x - _CameraPos.x, _PixelPos.z - _CameraPos.z);        //这里不能normalize！因为需要距离
    for (int i = 0; i < _LoopNum; i++)
    {
        _UV += viewDir * _OffScale;
        color_cache = SAMPLE_TEXTURE2D(_MainTex, _SamplerState, _UV);
        color0 += color_cache * exp(-i * _Atten) ;                                                           //衰减系数乘在自变量，控制衰减速度；放在外面会影响颜色本身
        
        
    }
    color0 /= _LoopNum;
    
    output = saturate(lerp(baseColor, color0, _Lerp)) ;
    
    return;
}

void IceGround_HighLight_float
(
    
    out float3 output
)
{
   
}

#endif