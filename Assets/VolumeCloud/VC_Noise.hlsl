#ifndef VC_HLSL_Noise
#define VC_HLSL_NOISE

void VC_NoiseRayMarch_float
(
    UnityTexture3D _NoiseTex,
    UnitySamplerState _samp,
    float _stepNum,
    float _stepScale,
    float _densityScale,
    float3 _startPos,
    float3 _rayDir,
    float3 _offset,
    out float output
)
{
    float3 currentPos = _startPos;
    float accumulation = 0;
    
    for (int i = 0; i < _stepNum; i++)
    {
        currentPos += _rayDir * _stepScale;
        accumulation += SAMPLE_TEXTURE3D(_NoiseTex, _samp, currentPos + _offset).r * _densityScale;
        
    }
    
    output = accumulation;

}


void raymarchv2_float(float3 rayOrigin, float3 rayDirection, float numSteps, float stepSize,
                       float densityScale, UnityTexture3D volumeTex, UnitySamplerState volumeSampler,
                       float3 offset, out float result)                                             //¹Ù·½°æ±¾
{
    float density = 0;
    float transmission = 0;
	
    for (int i = 0; i < numSteps; i++)
    {
        rayOrigin += (rayDirection * stepSize);
					
		//Calculate density
        float sampledDensity = SAMPLE_TEXTURE3D(volumeTex, volumeSampler, rayOrigin + offset).r;
        density += sampledDensity;
					
    }

    result = density * densityScale;
}

#endif