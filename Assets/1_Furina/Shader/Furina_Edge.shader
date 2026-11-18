Shader "Furina/Edge"
{
    Properties
    {

		_outline( "描边粗细" , Range(0.0, 1.0)) = 0.4
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

		Pass
		{
			Tags{ "LightMode" = "UniversalForward" }
			Cull Front
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"
			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal :NORMAL;
				float3 tangent : TANGENT;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;

			};
			CBUFFER_START(UnityPerMaterial)
			float _outline;
			CBUFFER_END
			v2f vert(appdata v)
			{
				v2f o;
				VertexPositionInputs positionInputs = GetVertexPositionInputs(v.vertex.xyz);

				float3 normalWS = TransformObjectToWorldNormal(v.tangent);
				float3 normalCS = normalize(mul((float3x3)UNITY_MATRIX_VP, normalWS));

				//float aspect = UNITY_MATRIX_P._m11 / UNITY_MATRIX_P._m00;
				float4 nearUpperRight = mul(unity_CameraInvProjection, float4(1, 1, UNITY_NEAR_CLIP_VALUE, _ProjectionParams.y));//将近裁剪面右上角位置的顶点变换到观察空间
				float aspect = abs(nearUpperRight.y / nearUpperRight.x);//求得屏幕宽高比
				normalCS = float3(normalCS.x * aspect, normalCS.y, normalCS.z);

				float4 pos = positionInputs.positionCS;



				pos = pos + float4(normalCS.xy, 0, 0) * _outline * pos.w * 0.01;
				o.pos = pos;


				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				return half4(0,0,0,1);
			}
		ENDHLSL
		}

		Pass
		{
			Tags{ "LightMode" = "SRPDefaultUnlit" }
			Cull Back
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/core.hlsl"
			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal :NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;

			};
			CBUFFER_START(UnityPerMaterial)
			float _outlineLen;
			CBUFFER_END
			v2f vert(appdata v)
			{
				v2f o;
				float4 pos = mul(UNITY_MATRIX_MV, v.vertex);
				o.pos = mul(UNITY_MATRIX_P, pos);
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				return half4(1, 1, 1, 1);
			}
		ENDHLSL
		}
    }
}
