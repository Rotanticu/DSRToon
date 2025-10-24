Shader "Custom/MyCustomURPShaderTemplate"
{
    Properties
    {
        _Vector("Vector", Vector) = (0, 0, 0, 0)
        _TimeSpeed("Time Speed", Float) = 0.1
        _Intensity("Intensity", Float) = 1
        _PowerExponent("Power Exponent", Float) = 1
        _Size("Size", Float) = 1
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

            //Geometry
            ZWrite On
            ZTest LEqual
            Cull Back


            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "NoiseLibrary.hlsl"
            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            float4 _Vector;
            float _TimeSpeed;
            float _Intensity;
            float _PowerExponent;
            float _Size;
            Varings vert (Attributes IN)
            {
                Varings OUT;
                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionCS = positionInputs.positionCS;
		        OUT.uv = IN.uv;
                OUT.viewDir = GetWorldSpaceViewDir(IN.positionOS.xyz);
                OUT.worldPos = positionInputs.positionWS;
                return OUT;
            }


            half4 frag (Varings IN) : SV_Target
            {
                // // http://glslsandbox.com/e#37373.0
                // float t = fworley(IN.uv, _Size, _TimeSpeed) * _Intensity;
                // t = pow(t, _PowerExponent);
                // return half4(t, t, t, 1);

                float t = pnoise((IN.uv * 6) + _Time.y * _TimeSpeed,4,6,1);
                return half4(t, t, t, 1);
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
        UsePass "Universal Render Pipeline/Lit/depthOnly"
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
    }
    FallBack "Diffuse"
}