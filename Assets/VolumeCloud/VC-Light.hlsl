#ifndef VC_HLSL_Light
#define VC_HLSL_Light

void VC_LightRayMarch_float
(
    UnityTexture3D _volumeTex,
    UnitySamplerState _sampler,
    float3 _startPos,
    float3 _rayDir,
    float _stepNum,
    float _stepScale,
    float _densityScale,
    float3 _offset,
    
    float3 _lightDir,
    float _lightStepNum,
    float _lightStepScale,
    out float3 output
)
{
    float3 currentPos = _startPos + _offset;
    float cloudDensity = 0;
    
    float transmittance = 1;
    float finalLight = 0;
    
    for (int i = 0; i < _stepNum; i++)
    {
        currentPos += _rayDir * _stepScale;
        float currentCloudDensity = SAMPLE_TEXTURE3D(_volumeTex, _sampler, currentPos ).r;
        cloudDensity += currentCloudDensity;
        
        float lightDensity = 0;
        float3 lightCurrentPos = currentPos;
        for (int j = 0; j < _lightStepNum; j++)
        {
            lightCurrentPos += -_lightDir * _lightStepScale;
            lightDensity += SAMPLE_TEXTURE3D(_volumeTex, _sampler, lightCurrentPos).r;

        }
        
        float darkness = exp(-lightDensity);
        
        transmittance *= exp(-cloudDensity);
        finalLight += cloudDensity * transmittance * darkness;
    }

    output = float3(finalLight, transmittance, 0);
}

#endif