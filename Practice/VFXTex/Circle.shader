Shader "Custom/MyCustomURPShaderTemplate"
{
    Properties
    {
        _Radius("Radius", Range(0, 1)) = 0.5
        _Softness("Softness", Range(0, 1)) = 0.1
        [IntRange] _CircleType("Circle Type", Range(0, 2)) = 1
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

            float _Radius;
            float _Softness;
            int _CircleType;
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
                // float t = 1.1 - length(pin.mouse - pin.position);
                // float t = cRadius - length(pin.position);
                //  float t = cIntensity / (length(pin.position));
                // t = pow(t, cPowerExponent);
                // pout.color = vec3(t);
                float result;
                if (_CircleType < 0.5) 
                {
                    float power = pow(saturate(pow(1.6,_Radius) - length(IN.uv - 0.5)), saturate(1 - _Softness) * 100);
                    result = power;
                }
                else if (_CircleType < 1.5)
                {
                    float smooth = smoothstep(1 - max(_Softness, 0.00001), 1.0, saturate(1 + (_Radius / 2) - length(IN.uv - 0.5)));
                    result = smooth;
                }
                else
                {
                    float hard = step(0.5,saturate(0.5 + (_Radius / 2) - length(IN.uv - 0.5)));
                    result = hard;
                }
                //float result = lerp(lerp(power, smooth, _CircleType), hard, _CircleType - 1);
                return half4(result, result, result, 1);
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
        UsePass "Universal Render Pipeline/Lit/depthOnly"
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
    }
    FallBack "Diffuse"
}