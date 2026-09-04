Shader "Terrain/Terrain1"
{
    Properties { 
		_GrassColor("GrassColor", Color) = (0, 1, 0.2)
        _GrassHighLightColor("_GrassHighLightColor", Color) = (1, 1, 1)
        _StoneColor("_StoneColor", Color) = (0.2, 0.2, 0.2)
        _StoneUVScale("_StoneUVScale",Range(0,2)) = 1
        _StoneDotNum("_StoneDotNum", Range(0, 1)) = 1
        _EdgeGreen("EdgeGreen", Range(0, 8)) = 1

        ////风力相关变量
        _UvScale_Wind("_UvScale_Wind", Range(0,1)) = 0.5
        //风速 - 影响纹理移动速度，和风力影响程度
        _WindSpeed("_WindSpeed", Range(0,2)) = 1
        _WindStrength("_WindStrength", Range(0,5)) = 1
        _WindPow("_WindPow", Range(0,5)) = 2
        //风向
        _WindDir_X("_WindDir_X", Range(-1,1)) = 0.5
        _WindDir_Y("_WindDir_Y", Range(-1,1)) = 0.5

        [WindMap] _WindMap("WindMap",2D) = "white"{}
        [DotMap] _DotMap("DotMap", 2D) = "white"{}
    }
    
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        
        Pass
        {
            Cull Back
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            
            // 变量声明
            float3 _GrassColor;
            float3 _GrassHighLightColor;
            float3 _StoneColor;
            float _StoneUVScale;
            float _StoneDotNum;
            float _EdgeGreen;
            //风力变量
            float _UvScale_Wind;
            float _WindSpeed;
            float _WindStrength;
            float _WindPow;
            float _WindDir_X;
            float _WindDir_Y;


            TEXTURE2D(_WindMap);
            TEXTURE2D(_DotMap);

            SAMPLER(sampler_WindMap);
            SAMPLER(sampler_DotMap);

            float4 _DotMap_ST;

            // a2v输入结构
            struct Attributes {             
                float3 position : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD;
            };

             // v2f输出结构
            struct Varyings {               
                float4 positionHCS : SV_POSITION;
                float3 normal : TEXCOORD1;
                float4 uvWS : TEXCOORD2;
                float2 uvOS : TEXCOORD3;                
            };

            //绕轴旋转，目前是固定Y轴
            //旋转之后大小会变吗
            float3 Rotation(float3 src, float angle)
            {
                angle = radians(angle);

                float s = sin(angle);
                float c = cos(angle);

                float4x4 rotationM = float4x4(
                        c, 0, s, 0,
                        0, 1, 0, 0,
                        -s, 0, c, 0,
                        0, 0, 0, 1
                    );
                return mul(rotationM, float4(src, 1)).xyz;

            }
            
            // 顶点着色器
            Varyings vert(Attributes i) {
                Varyings o;
                //position
                o.positionHCS = TransformObjectToHClip(i.position);
                o.normal = TransformObjectToWorldNormal(i.normal);

                //基于世界坐标计算uv
                float3 positionWS = TransformObjectToWorld(i.position);
                float2 uvWS = float2(positionWS.x, positionWS.z);

                //随时间的偏移
                float2 offset1 = normalize(float2(_WindDir_X , _WindDir_Y )) * _Time.z * _WindSpeed;
                float2 offset2 = normalize(Rotation(float3(_WindDir_X * 1.5, 0,  _WindDir_Y * 1.5 ), 30)).xz * _Time.z * _WindSpeed * 1.5;

                o.uvWS.xy = uvWS + offset1;
                o.uvWS.zw = uvWS + offset2;

                o.uvOS = TRANSFORM_TEX(i.uv, _DotMap);
                return o;
            }
            
            // 片元着色器
            half4 frag(Varyings i) : SV_Target {
                float3 normalWS = normalize(i.normal);
                
                //采样WindMap
                //双层噪声叠加，添加不同系数，主方向占更高比例
                half4 color_wind_1 = SAMPLE_TEXTURE2D(_WindMap, sampler_WindMap, i.uvWS.xy * _UvScale_Wind);
                half4 color_wind_2 = SAMPLE_TEXTURE2D(_WindMap, sampler_WindMap, i.uvWS.zw * _UvScale_Wind * 0.5);
                half4 color_wind = pow((color_wind_1 * 0.5 + color_wind_2 * 0.5), _WindPow) ;

                //采样噪点图
                //要展现草地被吹向n方向，uv采样要减n方向
                half4 color_dot = SAMPLE_TEXTURE2D(_DotMap, sampler_DotMap, i.uvOS - float2(_WindDir_X , _WindDir_Y ) * color_wind.r * _WindStrength * 0.01);
                half4 color_dot_2 = SAMPLE_TEXTURE2D(_DotMap, sampler_DotMap, i.uvOS - float2(_WindDir_X * 1.5 , _WindDir_Y * 1.5) * color_wind.r * _WindStrength * 0.015);
                half4 color_dot_3 = SAMPLE_TEXTURE2D(_DotMap, sampler_DotMap, i.uvOS * _StoneUVScale);
                float color_dot_light = (color_dot.r * 0.2126 +color_dot.g* 0.7152 + color_dot.b * 0.0722);

                //做法线偏移
                float3 normal_offset_dir = normalize(float3(_WindDir_X, 0, _WindDir_Y)) * color_wind * 0.5;
                normalWS += normal_offset_dir * _WindStrength;

                //GrassColor
                half4 color_grass_highlight = half4(_GrassHighLightColor *  saturate(0.25 - color_dot_2.r) * pow(color_wind.r, 1) * 7, 1);
                half4 color_grass = half4(_GrassColor * saturate(color_dot_light * 0.5 + 0.5), 1);
                color_grass += color_grass_highlight;
                
                //Stone Color
                half4 color_stone = half4((step(color_dot_3.r, _StoneDotNum) * 0.5 + 0.5)  * _StoneColor, 1);

                //Diffuse Coe
                Light mainLight = GetMainLight();
                float diffuseCoe = max(0, dot(mainLight.direction , normalWS));
                //diffuseCoe = diffuseCoe * 0.4 + 0.5;
                half4 color_diffuse = half4(color_grass.rgb * diffuseCoe, 1);

                //根据法线朝向混合地皮颜色和岩石颜色
                float upCoe = pow(  saturate(normalWS.y), _EdgeGreen);
                half4 color = half4(color_diffuse.rgb * upCoe + color_stone.xyz * (1 - upCoe), 1);
                
                //return half4(normalWS,1);
                //return color_wind;
                //return color_dot;
                //return color_grass_highlight;
                return color;
            }
            ENDHLSL
        }
    }
}
