Shader "VFXTex/Gradation"
{
    Properties
    {
        _DirectionX("Direction X", Range(0, 1)) = 0
        _DirectionY("Direction Y", Range(0, 1)) = 0
        _PowerExponent("Power Exponent", Range(0, 100)) = 15.0
        _Threshold("Threshold", Range(0, 1)) = 0.5
        _Tolerance("Tolerance", Range(0, 1)) = 0.01
        _Offset("Offset", Range(-1, 1)) = 0
        _Width("Width", Range(0, 1)) = 1
        _Random("Random", Range(0, 1)) = 0
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
            float _DirectionX;
            float _DirectionY;
            float _PowerExponent;
            float _Threshold;
            float _Tolerance;
            float _Offset;
            float _Random;
            float _Width;
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
                float2 _Direction = float2(_DirectionX, _DirectionY);
                float len = length(_Direction);
                float t = 0.0;
                if (len == 0.0) {
                    return half4(0.0, 0.0, 0.0, 0.0);
                } 
                else {
                    float2 n = normalize(_Direction);
                    float2 pos = IN.uv + _Direction;
                    t = (dot(pos, n) * 0.5 + _Offset) / len;
                    float widthSize = rcp(pow(0.9, (1.0 - _Width) * 100.0));
                    widthSize = floor(IN.uv.x * widthSize) / widthSize;
                    float random = (rand(float2(widthSize,0.0)) + EPSILON) * _Random;
                    t = rcp(1.0 - random) * (t - random);
                    t = pow(t, _PowerExponent);
                }
                t = smoothstep(_Threshold - _Tolerance, _Threshold + _Tolerance, t);
                return half4(t, t, t, 1.0);
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
        UsePass "Universal Render Pipeline/Lit/depthOnly"
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
    }
    FallBack "Diffuse"
}