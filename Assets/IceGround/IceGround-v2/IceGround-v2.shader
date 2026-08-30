Shader "IG/IceGround-v2"
{
    Properties { 
		[MainTexture] _MainTex ("_MainTex", 2D) = "White"{}
        _NormalMap("_NormalMap", 2D) = "White"{}
        _3DMap ("_3DMap", 3D) = ""{}

        _IceColor("_IceColor", Color) = (1, 1, 1, 1)
        _NormalScale ("_NormalScale", float) = 1
    }
    
    SubShader
    {
        Tags 
        { 
            "RenderPipeline" = "UniversalPipeline" 
        } 
        
        Pass
        {
            Tags{ "LightMode" = "UniversalForward"}

            HLSLPROGRAM  // ← HLSL开始标志

            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            

            TEXTURE2D(_MainTex);       
            SAMPLER(sampler_MainTex);   

            TEXTURE2D(_NormalMap);       
            SAMPLER(sampler_NormalMap);   

            TEXTURE3D(_3DMap);       
            SAMPLER(sampler_3DMap);   
            

            struct Attributes {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
            };
            
            struct Varyings {
                float4 positionHCS : SV_POSITION;
                float3 normalWS : TEXCOORD0;
                float3 tangentWS : TEXCOORD1;
                float3 bitangentWS : TEXCOORD2;
                float2 uv : TEXCOORD3;
            };
            
		    CBUFFER_START(UnityPerMaterial) 
                float4 _MainTex_ST;
                float4 _Color;
                float _NormalScale;
            CBUFFER_END


            Varyings vert(Attributes i) {
                Varyings o;

                //Position Trans
                VertexPositionInputs positionInputs = GetVertexPositionInputs(i.positionOS.xyz);
                o.positionHCS = positionInputs.positionCS;

                //Normal Trans
                VertexNormalInputs normalInputs = GetVertexNormalInputs(i.normalOS, i.tangentOS);
                o.normalWS = normalize(normalInputs.normalWS);
                o.tangentWS = normalize(normalInputs.tangentWS);
                o.bitangentWS = normalize(normalInputs.bitangentWS);

                o.uv = TRANSFORM_TEX(i.uv, _MainTex);                       // uv的ST转换

                return o;
            }
            

            half4 frag(Varyings i) : SV_Target {
                half finalColor;
                half4 baseColor;
                
                baseColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);
                finalColor = baseColor;

                //TBN
                float3x3 TBN = float3x3(i.tangentWS, i.bitangentWS, i.normalWS);

                //Normal
                float4 normalTex = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, i.uv);
                float3 unpackedNormal = UnpackNormalScale(normalTex, _NormalScale);

                float3 normalWS = TransformTangentToWorld(unpackedNormal, TBN);
                normalWS = normalize(normalWS);

                //Lambert
                Light mainLight = GetMainLight();
                float3 mainLightDir = normalize(mainLight.direction);
                float lambert = saturate( dot(normalWS, mainLightDir));

                finalColor *= lambert;

                return finalColor;
            }

            ENDHLSL
        }
    }
}
