#ifndef HLSL_RAYMARCH
#define HLSL_RAYMATCH

void RayMarch2_float(float3 ray_dir, float3 pos_start, float _StepSize, float _StepNum,
                                    UnityTexture3D cloud_noise, UnitySamplerState sampler_cloud, float density_scale,
                                    float3 offset,
                                    float _LightNum, float _LightStep, float3 _LightDir, float _LightAbsorb, float _DarknessThreshold, float _LightTransmittance,
                                    out float3 output)
{
    output = float3(0, 0, 0);
    
    //初始化步进参数
    float3 pos_current = pos_start;
    float density = 0;
    
    //初始化光照参数
    float light_final = 0;
    float light_accumulation = 0;
    float light_acception = 0;
    float light_shadow = 0;
    
    //密度采样步进
    for (int iii = 0; iii < _StepNum; iii++)
    {
        //采样当前密度 
        density += SAMPLE_TEXTURE3D(cloud_noise, sampler_cloud, pos_current + offset).r * density_scale;
        
        //向光源步进
        float3 light_sample_pos = pos_current;
        //light_accumulation = 0;
        
        for (int jjj = 0; jjj < _LightNum; jjj++)
        {
            light_accumulation += SAMPLE_TEXTURE3D(cloud_noise, sampler_cloud, light_sample_pos).r;
            light_sample_pos = light_sample_pos - _LightDir * _LightStep;
            
        }
        light_acception = exp(-light_accumulation);
        light_shadow = _DarknessThreshold + (1 - _DarknessThreshold) * light_acception;
        
        //密度(发光体浓度) * 光线遮挡情况 * 透射率
        light_final += density * light_shadow * _LightTransmittance;
        
        //每步进一次，透射率就对应降低一点，根据密度值，符合e幂衰减规律
        _LightTransmittance *= exp(-density * _LightAbsorb);
        
        //移动到下一个检测点
        pos_current += ray_dir * _StepSize;
        
    }
    
    output.y = exp(-density);
    output.x = light_final;

    return;
}


#endif