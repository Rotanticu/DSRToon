Shader "VFXTex/Ring"
{
    Properties
    {
        //[MainTexture] _MainTex ("MainTexture", 2D) = "white" {}
        //[MainColor]_MainColor ("Main Color", Color) = (1,1,1,1)
        _Frequency("Frequency", Range(0, 1000)) = 30.0
        _Softness("Softness", Range(0.00001, 0.99999)) = 0.5
        _Width("Width", Range(0, 0.99999)) = 0.1
        _TimeSpeed("TimeSpeed", Float) = 5.0
    }

    SubShader
    {
        Tags 
        { 
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "Queue"="Geometry"
        }
        //LOD 100
        Pass
        {
            Tags
			{
				"LightMode"="UniversalForward"
			}

            //Geometry
            ZWrite On
            ZTest LEqual
            Cull Back

            ////Transparent
            //ZWrite Off
            //Blend SrcAlpha OneMinusSrcAlpha // 传统透明度
            //Blend One OneMinusSrcAlpha // 预乘透明度
            //Blend OneMinusDstColor One // 软加法
            //Blend DstColor Zero // 正片叠底（相乘）
            //Blend OneMinusDstColor One // 滤色 //柔和叠加（soft Additive）
            //Blend DstColor SrcColor // 2x相乘 (2X Multiply)
            //Blend One One // 线性减淡
            //BlendOp Min Blend One One //变暗
            //BlendOp Max Blend One One //变亮


            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Varings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            //TEXTURE2D(_MainTex);
            //SAMPLER(sampler_MainTex);
            float _Frequency;
            float _Softness;
            float _Width;
            float _TimeSpeed;
            Varings vert (Attributes IN)
            {
                Varings OUT;
                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionCS = positionInputs.positionCS;
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag (Varings IN) : SV_Target
            {
                float t = sin(length(IN.uv - 0.5) * _Frequency + _Time.y * _TimeSpeed);
                float _PowerExponent = pow((1 - _Width) * 100,1/2.2);
                float soft = pow(saturate(t),  _PowerExponent);
                float hard = step(_Softness, soft);
                t = lerp(soft, hard, 1 - _Softness);
                return half4(t, t, t, 1);
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
        UsePass "Universal Render Pipeline/Lit/depthOnly"
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
    }
}