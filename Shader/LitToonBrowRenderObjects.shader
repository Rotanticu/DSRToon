Shader "LitToon/LitToonBrowRenderObjects"
{
    Properties
    {
        [MainTexture] _MainTex ("MainTexture", 2D) = "white" {}
        [MainColor]_MainColor ("Main Color", Color) = (1,1,1,1)
    }

    SubShader
    {
        Tags 
        { 
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "Queue"="Geometry"
        }
        Pass
        {
            Tags
			{
				"LightMode"="UniversalForward"
			}

            Stencil
            {
                Ref [_Stencil]
                Comp [_StencilComp]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
                Pass [_StencilOp]
                Fail [_StencilOpFail]
                ZFail [_StencilOpZFail]
            }

            

            //Transparent
            ZWrite Off
            ZTest LEqual
            Cull Back
            Blend SrcAlpha OneMinusSrcAlpha // 传统透明度




            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            //尽量对齐到float4,否则unity底层会自己填padding来对齐,会有空间浪费
            //CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            half4 _MainColor;
            //CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                half dotViewDirForwardDir : TEXCOORD2; // 方向向量 
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            Varings vert (Attributes IN)
            {
                Varings OUT;
                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionCS = positionInputs.positionCS;
                OUT.positionWS = positionInputs.positionWS;
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                float3 viewDirWS = GetCameraPositionWS() - positionInputs.positionWS;
                OUT.dotViewDirForwardDir = dot(viewDirWS, TransformObjectToWorld(half3(0,0,1))); // 计算方向向量
                return OUT;
            }

            half4 frag (Varings IN) : SV_Target
            {
                //采样纹理
                half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv) * _MainColor; 
                texColor.a = saturate(lerp(0, texColor.a, IN.dotViewDirForwardDir));
                return texColor; //将纹理颜色和主颜色相乘
            }
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}