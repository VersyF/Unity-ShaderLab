Shader "MaterialLab/HLSLShader"
{
    Properties { 
		[MainTexture] _MainTex ("_MainTex", 2D) = "white"{}
    }
    
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }
        
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        #include "ML_Lambert.hlsl"

        ENDHLSL

        Pass
        {
            HLSLPROGRAM 
            #pragma vertex vert
            #pragma fragment frag
            
            ENDHLSL
        }
    }
}
