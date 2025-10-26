Shader "VFXTex/Noise_Tess"
{
    Properties
    {
        _TimeSpeed("Time Speed", Float) = 1.025
        _Offset("Offset", Float) = 0.5
        _NoiseFrequency("Noise Frequency", Range(0,1)) = 0.49
        [IntRange] _Octaves("Octaves", Range(1, 16)) = 16
        _NoiseScale("Noise Scale", Range(0.1, 10)) = 1
        _NoisePhase("Noise Phase", Range(0,1)) = 0.23
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

            Varings vert (Attributes IN)
            {
                Varings OUT;
                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionCS = positionInputs.positionCS;
		        OUT.uv = IN.uv;
                return OUT;
            }
            float _TimeSpeed;
            float _Offset;
            float _NoiseFrequency;
            float _Octaves;
            float _NoiseScale;
            float _NoisePhase;
            float4 tessNoise(float2 p) 
            {
                float4 base = float4(p, 0.0, 0.0);
                float4 rotation = float4(0.0, 0.0, 0.0, 0.0);
                float theta = frac(_Time.y*_TimeSpeed);
                float phase = .55;
                float frequency = .49 * lerp(1.0, 1.2, _NoiseFrequency);
                
                for (int i=0; i<_Octaves; i++) {
                    base += rotation;
                    rotation = frac(base.wxyz - base.zwxy + theta);
                    rotation *= (1.0 - rotation);
                    base *= frequency;
                    base += base.wxyz * phase;
                }
                return rotation * 2.0;
            }
            half4 frag (Varings IN) : SV_Target
            {
                float2 p = IN.uv;
                p *= pow(2.0, 13.0);
                float4 a = tessNoise(p);
                float4 n = (a.x+a.y+a.z+a.w) * 0.5;
                float3 color = float3(n.xyz);

                //float graph = n.x;
                return half4(color - _Offset, 1);
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
        UsePass "Universal Render Pipeline/Lit/depthOnly"
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
    }
    FallBack "Diffuse"
}