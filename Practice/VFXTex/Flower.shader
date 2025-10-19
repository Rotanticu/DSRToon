Shader "VFXTex/Flower"
{
    Properties
    {
        [IntRange] _Petals("Petals", Range(0, 100)) = 3
        _Radius("Radius", Range(0, 10)) = 1
        _RadiusOffset("Radius Offset", Range(-1, 1)) = 0
        _Intensity("Intensity", Range(0, 1)) = 1
        _PowerExponent("Power Exponent", Range(0, 100)) = 1
        _TimeSpeed("Time Speed", Range(0, 100)) = 0
        _CenterOffset("Center Offset", Range(0, 5)) = 0
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

            float _Petals;
            float _Radius;
            float _RadiusOffset;
            float _Intensity;
            float _PowerExponent;
            float _TimeSpeed;
            float _CenterOffset;
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
                float2 splar = UVToPolar(position, 0); //xy互换决定旋转方向
                //花瓣效果
                float result = abs(sin((splar.y + _Time.y * _TimeSpeed - splar.x * _RadiusOffset) * PI * floor(_Petals)) * _Radius);
                result = _Intensity / abs(result - splar.x + _CenterOffset);
                result = saturate(pow(abs(result), _PowerExponent));
                return result;
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
        UsePass "Universal Render Pipeline/Lit/depthOnly"
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
    }
    FallBack "Diffuse"
}