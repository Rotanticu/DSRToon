Shader "VFXTex/Noise_Cell"
{
    Properties
    {
        _TimeSpeed("Time Speed", float) = 0
        _Intensity("Intensity", Float) = 1
        _PowerExponent("Power Exponent", Float) = 1
        _Size("Size", Float) = 30.0
        _RandomOffset("Random Offset", Range(0, 1)) = 1
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
            };

            float _TimeSpeed;
            float _Size;
            float _Intensity;
            float _PowerExponent;
            float _RandomOffset;
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
                float d = 1e30;
                float3 color = 1e30;
                float2 p = (IN.uv - 0.5) * _Size + _Time.y * _TimeSpeed;
                for (int xo=-1; xo <= 1; ++xo) 
                { 
                    for (int yo=-1; yo <= 1; ++yo) 
                    { 
                        float2 tp = floor(p) + float2(xo, yo); 
                        float temp = min(d, lengthSqr(p - tp - rand(tp) * _RandomOffset));
                        if (temp < d)
                        {
                            d = temp;
                            color = float3(rand(tp - 1),rand(tp),rand(tp + 1));
                        }
                    }
                } 
                float t = saturate(exp(-_PowerExponent * abs(2.0*d - 1.0)) * _Intensity);
                //return half4(t, t, t, 1);
                return half4(color * t, 1);
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
        UsePass "Universal Render Pipeline/Lit/depthOnly"
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
    }
    FallBack "Diffuse"
}