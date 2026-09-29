Shader "Odette/Hair"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _OutLineScale("_OutLineScale", float) = 1
        _OutLineColor("OutLineColor", Color) = (0, 0, 0, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline" = "UniversalRenderPipeline"}

        Pass
        {
            Cull Front
            ZWrite Off
            ZTest Off
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
                
            CBUFFER_START(UnityPerMaterial) 
                float4 _OutLineColor;
                float _OutLineScale;
            CBUFFER_END

            
            // 结构体定义
            struct Attributes { 
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
            };
            
            struct Varyings { 
                float4 positionHCS : SV_POSITION;
            };
            

            // 顶点着色器
            Varyings vert(Attributes IN) {
                Varyings OUT;
                float4 positionVert = IN.positionOS;
                positionVert += float4(IN.normalOS * _OutLineScale, 0);
                OUT.positionHCS = TransformObjectToHClip(positionVert.xyz); 
                return OUT;
            }
            
            // 片元着色器
            half4 frag(Varyings IN) : SV_Target {
                return _OutLineColor;  
            }
            ENDHLSL
        
        }

        Pass
        {
            Cull Back
            HLSLPROGRAM  // ← HLSL开始标志
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            // 变量声明
            TEXTURE2D(_MainTex); 
            SAMPLER(sampler_MainTex); 
            
            CBUFFER_START(UnityPerMaterial) 
                float4 _MainTex_ST;
            CBUFFER_END

            struct Attributes { 
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };
            
            struct Varyings {
                float4 positionHCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            
		    

            // 顶点着色器
            Varyings vert(Attributes IN) {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz); 
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);   
                return OUT;
            }
            
            // 片元着色器
            half4 frag(Varyings IN) : SV_Target {
                return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv); 
            }
            ENDHLSL

        }
    }
}
