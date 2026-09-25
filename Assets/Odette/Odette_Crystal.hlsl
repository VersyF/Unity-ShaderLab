#define PI 3.14159265358979323846f
void Crystal_float
(
    float3 _view,
    float3 _normal,
    out float2 output
)
{
    
    float polar = acos(dot(normalize(_view), normalize(_normal)));
    float coe = saturate(polar / (PI * 0.5f));
    
    float azimuth = acos(dot(normalize(_view.xy), normalize(float2(1, 0))));
    float2 azimuthVec = float2(cos(azimuth), sin(azimuth));
    normalize(azimuthVec);
    
    float2 res = azimuthVec * coe;
    output = res / 2 + 0.5f;
}