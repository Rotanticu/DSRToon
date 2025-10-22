Shader "Custom/MyCustomURPShaderTemplate"
{
    Properties
    {
        _Vector("Vector", Vector) = (0, 0, 0, 0)
        _TimeSpeed("Time Speed", Float) = 0.1
        _NoiseOctave("Noise Octave", Int) = 6
        _NoiseFrequency("Noise Frequency", Float) = 1
        _NoisePersistence("Noise Persistence", Float) = 1
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
            int _NoiseOctave;
            float _NoiseFrequency;
            float _NoisePersistence;
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
                float2 p = IN.uv + _Time.y * _TimeSpeed;
                // float t = 0.0;
                // float maxAmplitude = EPSILON;
                // float amplitude = 1.0;
                // float frequency = _NoiseFrequency;
                // for (int i=0; i<10; i++)
                // {
                //   if (i >= _NoiseOctave) break;
                //   t += plerp(floor(p * frequency)) * amplitude;
                //   frequency *= 2.0;
                //   maxAmplitude += amplitude;
                //   amplitude *= _NoisePersistence;
                // }
                // t = t / maxAmplitude;
                //return t / maxAmplitude;
                float t = pnoise(floor(IN.uv * _NoiseFrequency) + _Time.y * _TimeSpeed,_NoiseOctave,_NoiseFrequency,_NoisePersistence);
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