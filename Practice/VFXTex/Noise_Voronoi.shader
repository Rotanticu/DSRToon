Shader "VFXTex/Noise_Voronoi"
{
    Properties
    {
        _TimeSpeed("Time Speed", Range(0, 1)) = 0.00001
        _Size("Size", Float) = 30.0
        _Intensity("Intensity", Float) = 1
        _NoiseFrequency("Noise Frequency", Float) = 48.0
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
            float _NoiseFrequency;
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
                //voronoiNoiseFrag: 
                float time = _Time.y * _TimeSpeed;
                float2 p = IN.uv * _Size + time;
                float lum = saturate(iqnoise(p, _Intensity, _NoiseFrequency));
                return half4(lum, lum, lum, 1);


                // float graph = iqnoise(p.xx * 48.0 * _NoiseFrequency, 1.0, 0.0);
                // const float amp = 0.05;
                // const float lambda = 0.5;
                // const float period = 0.2;
                // float r = sqrt(pow2(IN.uv.x) + pow2(IN.uv.y));
                // float phase = 2.0 * PI * (time/period - r/lambda);
                // if (phase >= 0.0 && phase < 2.0*PI)
                // {
                //     float lum = (amp * sin(phase)) / sqrt(r);
                //     return half4(lum, lum, lum, 1);
                // } else
                // {
                //     return half4(0.0, 0.0, 0.0, 0);
                // }
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
        UsePass "Universal Render Pipeline/Lit/depthOnly"
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
    }
    FallBack "Diffuse"
}