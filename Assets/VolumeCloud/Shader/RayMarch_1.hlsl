#ifndef HLSL_RAYMARCH
#define HLSL_RAYMARCH

void RayMarch_float(float3 ray_dir, float3 pos_start, float _StepSize, float _StepNum,
                                    UnityTexture3D cloud_noise, UnitySamplerState sampler_cloud, float density_scale,
                                    float3 offset,
                                    out float3 output)
{
    output = float3(0, 0, 0);
    
    float3 pos_current;
    pos_current = pos_start;
    
    float density = 0;
    
    for (int iii = 0; iii < _StepNum; iii++)
    {
        density += SAMPLE_TEXTURE3D(cloud_noise, sampler_cloud, pos_current + offset).r * density_scale;
        pos_current += ray_dir * _StepSize;
        
    }
    
    output.x = density;

    return;
}




#endif