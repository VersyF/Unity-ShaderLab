#ifndef VC_HLSL_Sphere
#define VC_HLSL_Sphere

void SphereRayMarch_float
(
	float3 startPos,
	float3 rayDir,
	float stepScale,
	float stepNum,
	float4 sphereData,
	float densityScale,
	out float dens
)
{
	float accumulate = 0;
	float3 currentPos = startPos;
	for(int i = 0; i < stepNum; i++)
	{
		currentPos += rayDir * stepScale;
		float dist = distance(currentPos, sphereData.xyz);
		accumulate += saturate(sphereData.w - dist);


	}
	dens = accumulate * densityScale;
}

#endif