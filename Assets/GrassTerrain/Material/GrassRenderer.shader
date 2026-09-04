Shader "GrassTerrain/GrassRender1"
{
    Properties { 
		_WindMap("_WindMap", 2D) = "white"{}

    }
    
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        
        Pass
        {
            Cull Off
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            // 变量声明
            struct GrassBlade{
                float3 position;
            };
            StructuredBuffer<GrassBlade> GrassBladeBuffer;
            StructuredBuffer<float3> VertexBuffer;
            StructuredBuffer<float4> ColorBuffer;
            StructuredBuffer<int> TriangleBuffer;
            
            float _GrassWidth;
            float _GrassHeight;
            half4 _GrassColor;

            TEXTURE2D(_WindMap);
            SAMPLER(sampler__WindMap);
          

            // 结构体定义
            struct Attributes {
                uint vertexID : SV_VertexID;
                uint instanceID : SV_InstanceID;
            };
            
            struct Varyings {
                float4 positionHCS : SV_POSITION;
            };
            
            // 顶点着色器
            Varyings vert(Attributes i) {
                Varyings o;
                
                int vertexIndex = TriangleBuffer[i.vertexID];
                float3 positionOS = VertexBuffer[vertexIndex];
                positionOS.z *= _GrassWidth;
                positionOS.y *= _GrassHeight;
                float4 vertexColor = ColorBuffer[vertexIndex];
                float3 centerWS = GrassBladeBuffer[i.instanceID].position;

                //UV
                half2 uvWS = half2(centerWS.x, centerWS.z);

                //采样windMap
                half4 color_wind = SAMPLE_TEXTURE2D(_WindMap, sampler__WindMap, uvWS);
                half4 color_wind2 = SAMPLE_TEXTURE2D(_WindMap, sampler__WindMap, uvWS);

                //旋转方向
                float3 dir_rotate = normalize(float3(color_wind.r * 2 - 1, color_wind.g, color_wind.b * 2 - 1));

                //BillBoard
                float3 viewVec = GetCameraPositionWS();
                //这里需要用cameraPosition - worldPosition，因为是Dispatch渲染，没有默认物体
                //viewVec = TransformWorldToObject(float4(viewVec,1)).xyz;
                viewVec = float3(viewVec.x - centerWS.x, 1, viewVec.z - centerWS.z);
                viewVec = normalize(viewVec);
                float3 tangentVec = normalize(cross(float3(0,1,0), viewVec));
                float3x3 billMatrix = float3x3(
                    viewVec.x, 0, tangentVec.x,
                    viewVec.y, 1, tangentVec.y,
                    viewVec.z, 0, tangentVec.z
                    );
                
                    positionOS = mul(billMatrix, positionOS);

                float3 positionWS =  centerWS  + positionOS;
                o.positionHCS = TransformWorldToHClip(positionWS);

                return o;
            }
            
            // 片元着色器
            half4 frag(Varyings i) : SV_Target {

                return _GrassColor;
            }
            ENDHLSL
        }
    }
}
