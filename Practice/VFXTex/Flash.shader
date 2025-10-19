Shader "VFXTex/Flash"
{
    Properties
    {
        [IntRange] _Frequency("Frequency", Range(0, 100)) = 10
        _PowerExponent("Power Exponent", Range(0.00001, 1000)) = 1
        _TimeSpeed("Time Speed", Range(0, 100)) = 0
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
            #include "Common.hlsl"
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

            float _Frequency;
            float _PowerExponent;
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
                float2 center = (0.5, 0.5);
                float2 position = 2 * (IN.uv - center);
                float radius = length(position);
                float angle = atan2(position.x, position.y);
                float hit = sin(angle * _Frequency + _Time.y * _TimeSpeed);
                //float hit = sin((angle + rcp(radius)) * _Frequency + _Time.y * _TimeSpeed); //越往外radius越大，加上1/radius就能做出螺旋效果 
                hit = pow(saturate(hit), _PowerExponent);
                return half4(hit,hit,hit, 1.0);
                
                // float2 polar = UVToPolar(2 * IN.uv, 1);//2*(uv-0.5)
                // float t = sin((polar.y + _Time.y * _TimeSpeed) * _Frequency * PI2);
                // t = pow(saturate(t), _PowerExponent);
                // return half4(t, t, t, 1);
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
        UsePass "Universal Render Pipeline/Lit/depthOnly"
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
    }
    FallBack "Diffuse"
}