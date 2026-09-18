Shader "MaterialLab/ML_Bling-Phong"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _specularPow("Specular", float) = 50
        _AmbientLight("_AmbientLight", Color) = (1, 1, 1, 1)
        _AmbientStrength("_AmbientStrength", float) = 0.3
    }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque"
            "RenderPipeline" = "UniversalPipeline"
        }
        //LOD 100

        Pass
        {
            Tags{}
            HLSLPROGRAM
                #include "ML_Bling-Phong.hlsl"
                #pragma vertex vert;
                #pragma fragment frag;
            ENDHLSL
        }
    }
}
