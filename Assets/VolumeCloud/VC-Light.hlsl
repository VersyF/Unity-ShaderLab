#ifndef VC_HLSL_Light321
#define VC_HLSL_Light321

void VC_LightRayMarch_float
(
    UnityTexture3D volumeTex,
    UnitySamplerState volumeSampler,
    float3 rayOrigin,
    float3 rayDirection,
    float numSteps,
    float stepSize,
    float densityScale,
    float3 offset,
    float darknessThreshold,
    float lightAbsorb,
    
    float3 lightDir,
    float numLightSteps,
    float lightStepSize,
    float transmittance,
    out float3 output
)
{
    float density = 0;
    float transmission = 0;
    float lightAccumulation = 0;
    float finalLight = 0;
    
    

    //密度步进循环
    for (int i = 0; i < numSteps; i++)
    {
        rayOrigin += rayDirection * stepSize;
        
        float3 samplePos = rayOrigin + offset;
        float sampledDensity = SAMPLE_TEXTURE3D(volumeTex, volumeSampler, samplePos).r ;
        density += sampledDensity * densityScale;
        
        //光线步进
        float3 lightRayOrigin = samplePos;
        
        for (int j = 0; j < numLightSteps; j++)
        {
            lightRayOrigin += -lightDir * lightStepSize;
            float lightDensity = SAMPLE_TEXTURE3D(volumeTex, volumeSampler, lightRayOrigin).r;
            lightAccumulation += lightDensity;

        }
        //光线穿透率
        float lightTransmission = exp(-lightAccumulation);
        float shadow = lightTransmission * (1.0 - darknessThreshold) + darknessThreshold;
        
        
        finalLight += density * transmittance * shadow;
        transmittance *= exp(-density * lightAbsorb);
    }
    transmission = exp(-density);

    output = float3(finalLight, transmission, transmittance);
}

void VC_LightRayMarch_Backup_float
(
    UnityTexture3D _volumeTex,
    UnitySamplerState _sampler,
    float3 _startPos,
    float3 _rayDir,
    float _stepNum,
    float _stepScale,
    float _densityScale,
    float3 _offset,
    float _darknessThreshold,
    float _lightAbsorb,
    
    float3 _lightDir,
    float _lightStepNum,
    float _lightStepScale,
float transmittance,
    out float3 output
)
{
    float density = 0;
    
    
    float3 currentPos = _startPos;
    
    
    float finalLight = 0;
    
    
    
    //密度步进循环
    for (int i = 0; i < _stepNum; i++)
    {
        currentPos += _rayDir * _stepScale;
        float3 samplePos = currentPos + _offset;
        float currentCloudDensity = SAMPLE_TEXTURE3D(_volumeTex, _sampler, samplePos).r;
        density += currentCloudDensity * _densityScale;
        
        //光线步进
        
        float3 lightCurrentPos = samplePos;
        float lightAccumulation = 0;
        for (int j = 0; j < _lightStepNum; j++)
        {
            lightCurrentPos += -_lightDir * _lightStepScale;
            float lightDensity = SAMPLE_TEXTURE3D(_volumeTex, _sampler, lightCurrentPos).r;
            lightAccumulation += lightDensity;

        }
        //光线穿透率
        float lightTransmission = exp(-lightAccumulation);
        float darkness = lightTransmission * (1 - _darknessThreshold) + _darknessThreshold;
        
        
        finalLight += density * transmittance * darkness;
        transmittance *= exp(-density * _lightAbsorb);
    }
    float alpha = exp(-density);

    output = float3(finalLight, alpha, 0);
}

void raymarch_float(float3 rayOrigin, float3 rayDirection, float numSteps, float stepSize,
                     float densityScale, UnityTexture3D volumeTex, UnitySamplerState volumeSampler,
                     float3 offset, float numLightSteps, float lightStepSize, float3 lightDir,
                     float lightAbsorb, float darknessThreshold, float transmittance, out float3 result)
{
    float density = 0;
    float transmission = 0;
    float lightAccumulation = 0;
    float finalLight = 0;

    
    for (int i = 0; i < numSteps; i++)
    {
        rayOrigin += (rayDirection * stepSize);

		//The blue dot position
        float3 samplePos = rayOrigin + offset;
        float sampledDensity = SAMPLE_TEXTURE3D(volumeTex, volumeSampler, samplePos).r;
        density += sampledDensity * densityScale;

		//light loop
        float3 lightRayOrigin = samplePos;
		
        for (int j = 0; j < numLightSteps; j++)
        {
			//The red dot position
            lightRayOrigin += -lightDir * lightStepSize;
            float lightDensity = SAMPLE_TEXTURE3D(volumeTex, volumeSampler, lightRayOrigin).r;
			//The accumulated density from samplePos to the light - the higher this value the less light reaches samplePos
            lightAccumulation += lightDensity;
        }

		//The amount of light received along the ray from param rayOrigin in the direction rayDirection
        float lightTransmission = exp(-lightAccumulation);
		//shadow tends to the darkness threshold as lightAccumulation rises
        float shadow = darknessThreshold + lightTransmission * (1.0 - darknessThreshold);
		//The final light value is accumulated based on the current density, transmittance value and the calculated shadow value 
        finalLight += density * transmittance * shadow;
		//Initially a param its value is updated at each step by lightAbsorb, this sets the light lost by scattering
        transmittance *= exp(-density * lightAbsorb);
					
    }

    transmission = exp(-density);

    result = float3(finalLight, transmission, transmittance);
}

#endif