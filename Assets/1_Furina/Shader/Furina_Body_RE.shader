Shader "Furina/Furina_Body_RE"
{
    Properties {
        //面板参数
        [Space(20.0)]
        [Toggle]_IsFace( "是否是脸部" , float) = 0.0

        [Space(15.0)]
        [NoScaleOffset]_diffuse( "Diffuse" , 2d) = "white"{}
        _fresnel( "边缘光范围" , Range(0.0, 10.0)) = 1.7
        _edgeLight( "边缘光强度" , Range(0.0, 1.0)) = 0.02
        [Space(8.0)]
        _diffuseA( "Alpha(1透明, 2自发光)" , Range(0.0, 2.0)) = 0
        _Cutoff( "透明阈值" , Range(0.0, 1.0)) = 1.0
        _glow( "自发光强度" , Range(0, 2)) = 1
        _flicker( "发光闪烁速度" , float) = 0.8
        [Space(30.0)]

        [NoScaleOffset]_lightmap( "Lightmap/FaceLightmap" , 2d) = "white"{}
        _bright( "亮面范围" , float) = 0.99
        _grey( "灰面范围" , float) = 1.14
        _dark( "暗面范围" , float) = 0.5
        _AOStrength("AO强度", Range(0, 1)) = 0.5
        [Space(30.0)]

        [NoScaleOffset]_bumpMap( "Normalmap" , 2d) = "bump"{}
        _bumpScale( "法线强度" , float) = 1.0
        [Space(30.0)]

        [NoScaleOffset]_ramp( "Shadow_Ramp" , 2d) = "white"{}
        [Toggle]_dayOrNight("是否是白天" , float) = 0.0
        [Space(8.0)]
        _lightmapA10("a=1.0_Ramp条数" , Range(1, 5)) = 4
        _lightmapA7("a=0.7_Ramp条数" , Range(1, 5)) = 1
        _lightmapA5("a=0.5_Ramp条数" , Range(1, 5)) = 3
        _lightmapA3("a=0.3_Ramp条数" , Range(1, 5)) = 2
        _lightmapA0("a=0.0_Ramp条数" , Range(1, 5)) = 5
        [Space(30.0)]

        [NoScaleOffset]_metalMap( "MetalMap" , 2d) = "white"{}
        _gloss( "高光范围" , Range(1, 256.0)) = 1
        _glossStrength( "高光强度" , Range(0.0, 1.0)) = 1
        _metalMapColor( "金属反射颜色" , color) = (1.0, 1.0, 1.0, 1.0)
        [Space(30.0)]
    
        _outline( "描边粗细" , Range(0.0, 1.0)) = 0.4
        _outlineColor0( "描边颜色1" , color) = (1.0, 0.0, 0.0, 0.0)
        _outlineColor1( "描边颜色2" , color) = (0.0, 1.0, 0.0, 0.0)
        _outlineColor2( "描边颜色3" , color) = (0.0, 0.0, 1.0, 0.0)
        _outlineColor3( "描边颜色4" , color) = (1.0, 1.0, 0.0, 0.0)
        _outlineColor4( "描边颜色5" , color) = (0.5, 0.0, 1.0, 0.0)
    }

    SubShader
    {
        Tags { 
            "RenderPipeline" = "UniversalRenderPipeline"
            "RenderType"="Opaque" 
        }

        HLSLINCLUDE
        //导入库
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"  //默认库
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"  //光照库
        CBUFFER_START(UnityPerMaterial)  //常量缓冲区开头
            //声明面板参数
            float _IsFace;  //是否是脸部
            //diffuse
            float _fresnel;  //边缘光范围
            float _edgeLight;  //边缘光强度
            float _diffuseA;  //diffuseA
            float _Cutoff;  //透明阈值
            float _glow;  //自发光强度
            float _flicker;  //发光闪烁速度
            //lightmap/FaceLightmap
            float _bright;  //亮面范围
            float _grey;  //灰面范围
            float _dark;  //暗面范围
            float _AOStrength;  //AO强度
            //normal
            float _bumpScale;  //法线强度
            //ramp
            float _dayOrNight;  //是否是白天
            float _lightmapA10;  //1.0_Ramp条数
            float _lightmapA7;  //0.7_Ramp条数
            float _lightmapA5;  //0.5_Ramp条数
            float _lightmapA3;  //0.3_Ramp条数
            float _lightmapA0;  //0.0_Ramp条数
            //高光
            float _gloss;  //高光范围
            float _glossStrength;  //高光强度
            float3 _metalMapColor;  //金属反射颜色
            //描边
            float _outline;  //描边粗细
            float3 _outlineColor0;  //描边颜色1
            float3 _outlineColor1;  //描边颜色2
            float3 _outlineColor2;  //描边颜色3
            float3 _outlineColor3;  //描边颜色4
            float3 _outlineColor4;  //描边颜色5
        CBUFFER_END  //常量缓冲区结尾
            //声明贴图
            TEXTURE2D(_diffuse);  //Diffuse
            SAMPLER(sampler_diffuse);
            TEXTURE2D(_lightmap);  //Lightmap/FaceLightmap
            SAMPLER(sampler_lightmap);
            TEXTURE2D(_bumpMap);  //Normal
            SAMPLER(sampler_bumpMap);
            TEXTURE2D(_ramp);  //Shadow_Ramp
            SAMPLER(sampler_ramp);
            TEXTURE2D(_metalMap);  //MetalMap
            SAMPLER(sampler_metalMap);

        //旧
        float4 diffuse_ramp(float3 baseColor, float lambert, float AO, float4 lightmap)
        {

            //_Ramp映射到0.5-1
            float dayOrNight = _dayOrNight * 0.5;

            float lightmap_v_A10 =  (_lightmapA10 - 1) * 0.1 + 0.05 + dayOrNight;
            float lightmap_v_A7 =  (_lightmapA7 - 1) * 0.1 + 0.05 + dayOrNight;
            float lightmap_v_A5 =  (_lightmapA5 - 1) * 0.1 + 0.05 + dayOrNight;
            float lightmap_v_A3 =  (_lightmapA3 - 1) * 0.1 + 0.05 + dayOrNight;
            float lightmap_v_A0 =  (_lightmapA0 - 1) * 0.1 + 0.05 + dayOrNight;

            //根据lightmap选择ramp_v
            float lightmap_IsA0 = step(-0.05, lightmap.a);
            float lightmap_IsA3 = step(0.25, lightmap.a);
            float lightmap_IsA5 = step(0.45, lightmap.a);
            float lightmap_IsA7 = step(0.65, lightmap.a);
            float lightmap_IsA10 = step(0.95, lightmap.a);

            float ramp_v = lightmap_v_A0;
            ramp_v = lerp(ramp_v, lightmap_v_A3, lightmap_IsA3);
            ramp_v = lerp(ramp_v, lightmap_v_A5, lightmap_IsA5);
            ramp_v = lerp(ramp_v, lightmap_v_A7, lightmap_IsA7);
            ramp_v = lerp(ramp_v, lightmap_v_A10, lightmap_IsA10);

            //灰度重映射
            //lambert = lerp(_dark, _bright, lambert) * AO;
            float halflambert = smoothstep(0, _grey, lambert + _dark) * AO;

            //ramp_u的决定
            float ramp_u = halflambert;

            //采样ramp
            float3 color_ramp = SAMPLE_TEXTURE2D(_ramp, sampler_ramp, float2(ramp_u, ramp_v));

            //判断亮面
            float isBright = step(1, halflambert);

            //返回颜色
            half3 color = lerp(color_ramp , 1, isBright);
            
            //return half3(ramp_u, ramp_u, ramp_u);
            //float test = step(_grey, halflambert);
            //return half3(test, test, test);
            //return color_ramp ;
            return float4(color, isBright);
        }


        //ramp的采样
        float3 sample_ramp(float diffuse, float specular, float4 lightmap)
        {
            //_Ramp映射到0.5-1
            float dayOrNight = _dayOrNight * 0.5;

            float lightmap_v_A10 =  (_lightmapA10 - 1) * 0.1 + 0.05 + dayOrNight;
            float lightmap_v_A7 =  (_lightmapA7 - 1) * 0.1 + 0.05 + dayOrNight;
            float lightmap_v_A5 =  (_lightmapA5 - 1) * 0.1 + 0.05 + dayOrNight;
            float lightmap_v_A3 =  (_lightmapA3 - 1) * 0.1 + 0.05 + dayOrNight;
            float lightmap_v_A0 =  (_lightmapA0 - 1) * 0.1 + 0.05 + dayOrNight;

            //根据lightmap选择ramp_v
            float lightmap_IsA0 = step(-0.05, lightmap.a);
            float lightmap_IsA3 = step(0.25, lightmap.a);
            float lightmap_IsA5 = step(0.45, lightmap.a);
            float lightmap_IsA7 = step(0.65, lightmap.a);
            float lightmap_IsA10 = step(0.95, lightmap.a);

            float ramp_v = lightmap_v_A0;
            ramp_v = lerp(ramp_v, lightmap_v_A3, lightmap_IsA3);
            ramp_v = lerp(ramp_v, lightmap_v_A5, lightmap_IsA5);
            ramp_v = lerp(ramp_v, lightmap_v_A7, lightmap_IsA7);
            ramp_v = lerp(ramp_v, lightmap_v_A10, lightmap_IsA10);


            //ramp_u的决定 (BRDF)
            float ramp_u = lerp(diffuse, specular+diffuse, lightmap.r);

            //采样ramp
            float3 color_ramp = SAMPLE_TEXTURE2D(_ramp, sampler_ramp, float2(ramp_u, ramp_v));

            //判断亮面
            float isBright = smoothstep(_bright - 0.05, _bright, ramp_u);
            half3 blingphong = half3(ramp_u, ramp_u, ramp_u);
            
            //
            half3 result = lerp(color_ramp, blingphong, isBright);

            //return half3(ramp_u, ramp_u, ramp_u);
            //float test = step(_grey, halflambert);
            //return half3(test, test, test);
            //return color_ramp ;
            return result;
        }

        //环境光遮蔽的获取
        float AO(float4 lightmap){
            float AO = step(0.1, lightmap.g);
            AO = lerp(1, AO, _AOStrength);

            return AO;
        }

        //漫反射系数的计算
        float Diff(float NdotL, float AO)
        {
            //灰度重映射
            //lambert = lerp(_dark, _bright, lambert) * AO;
            float lambert= 1;
            float diffuse = smoothstep(0, _grey, NdotL + _dark) * AO;

            return diffuse;
        }

        //高光系数的计算
        float Spec(float NdotH, float4 lightmap)
        {
            NdotH = saturate(NdotH);
            NdotH += 0.1 * lightmap.b;
            float strength_highlight = lerp(20, 80, lightmap.b);
            float coe_highlight = pow(NdotH, strength_highlight);

            return coe_highlight;
        }

        float SDF(float3 lightDir){
            
            return 1;
        }

        half3 Emit(half4 baseColor){
            return baseColor.a * baseColor * _glow;
            }

        ENDHLSL



        Pass
        {
            Tags{"LightMode" = "UniversalForward"}

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag


            //输入结构
            struct a2v {
                float4 vertex : POSITION;  //获取顶点数据
                float2 texcoord0 : TEXCOORD0;  //获取uv0
                float3 normal : NORMAL;  //获取顶点法线
                float4 tangent : TANGENT;  //获取顶点切线
            };

            //输出结构
            struct v2f {
                float4 pos : SV_POSITION;  //顶点数据
                float2 uv0 : TEXCOORD0;  //uv0
                //矩阵
                float4 TtoW0 : TEXCOORD1;  //x切线,y副切线,z法线,w顶点
                float4 TtoW1 : TEXCOORD2;  //x切线,y副切线,z法线,w顶点
                float4 TtoW2 : TEXCOORD3;  //x切线,y副切线,z法线,w顶点
            };


           //顶点Shader
            v2f vert (a2v v) {
                v2f o;  //定义返回值
                o.pos = TransformObjectToHClip(v.vertex.xyz);  //MVP变换(模型空间>>世界空间>>视觉空间>>裁剪空间)
                o.uv0 = v.texcoord0;  //传递uv0(无变换)
                float3 nDirWS = TransformObjectToWorldNormal(v.normal);  //世界空间法线
                float3 tDirWS = TransformObjectToWorld(v.tangent.xyz);  //世界空间切线
                float3 bDirWS = cross(nDirWS, tDirWS) * v.tangent.w;  //世界空间副切线
                float3 posWS = TransformObjectToWorld(v.vertex.xyz);  //世界顶点位置
                //构建矩阵
                o.TtoW0 = float4(tDirWS.x, bDirWS.x, nDirWS.x, posWS.x);  //x切线,y副切线,z法线,w顶点
                o.TtoW1 = float4(tDirWS.y, bDirWS.y, nDirWS.y, posWS.y);  //x切线,y副切线,z法线,w顶点
                o.TtoW2 = float4(tDirWS.z, bDirWS.z, nDirWS.z, posWS.z);  //x切线,y副切线,z法线,w顶点
                return o;  //返回顶点Shader
            }

            //片元Shader
            half4 frag (v2f i) : SV_TARGET {
                //采样贴图
                float3 baseColor = SAMPLE_TEXTURE2D(_diffuse, sampler_diffuse, i.uv0).rgb;  //diffuseRGB通道
                float diffuseA = SAMPLE_TEXTURE2D(_diffuse,sampler_diffuse, i.uv0).a;  //diffuseA通道
                float4 lightmap = SAMPLE_TEXTURE2D(_lightmap, sampler_lightmap, i.uv0).rgba;  //lightmap
                //法线贴图
                float3 nDirTS = UnpackNormal(SAMPLE_TEXTURE2D(_bumpMap, sampler_bumpMap, i.uv0)).rgb;  //切线空间法线(采样法线贴图并解码)
                nDirTS.xy *= _bumpScale;  //法线强度
                nDirTS.z = sqrt(1.0 - saturate(dot(nDirTS.xy, nDirTS.xy)));  //计算法线z分量
                //准备向量
                float3 posWS = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);  //世界空间顶点
                //切线空间法线转世界空间法线
                float3 nDirWS = normalize(half3(dot(i.TtoW0.xyz, nDirTS), dot(i.TtoW1.xyz, nDirTS), dot(i.TtoW2.xyz, nDirTS)));

                Light mlight = GetMainLight();  //光源
                float3 lDirWS= normalize(mlight.direction);  //世界光源方向(平行光)
                float3 vDirWS = normalize(_WorldSpaceCameraPos.xyz - posWS.xyz);  //世界观察方向
                float3 nDirVS = normalize(mul((float3x3)UNITY_MATRIX_V, nDirWS));  //世界空间法线转观察空间法线
                float3 hDirWS = normalize(vDirWS + lDirWS) ;  //半角方向
                //向量点乘
                float NdotL = dot(nDirWS, lDirWS);  //兰伯特
                float NdotH = dot(nDirWS, hDirWS);  //Blinn-Phong
                float NdotV = dot(nDirWS, vDirWS);  //菲涅尔

                half3 color;

                //环境光遮蔽
                float coe_AO = AO(lightmap);
                
                //漫反射计算
                float diffuse = Diff(NdotL, coe_AO);

                //高光计算
                float specular = Spec(NdotH, lightmap);

                //ramp采样
                half3 color_ramp = sample_ramp(diffuse, specular, lightmap);

                //自发光
                half3 glow = Emit(half4(baseColor, diffuseA));

                if(_IsFace){
                    return half4(1,0,0,0);    
                }

                color = color_ramp * baseColor + glow;

                //return half4(lightmap.b, lightmap.b, lightmap.b, 1);
                //return half4(specular, specular, specular, 1);
                //return half4(coe_AO, coe_AO, coe_AO, 1);
                return half4(color, 1);
            }
            ENDHLSL
        }
    }
}
