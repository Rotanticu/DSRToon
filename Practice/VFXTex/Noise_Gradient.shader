Shader "VFXTex/Gradient_Noise"
{
    Properties
    {
        _TimeSpeed("Time Speed", Float) = 0.1
        _NoiseScale("Noise Scale", Float) = 10
        _IsColor("IsColor", Range(0, 1)) = 1
        _Delta("Delta", Float) = 0.01
        [IntRange] _GradientType("Gradient Type", Range(0, 12)) = 0
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
				"Lightfmode"="UniversalForward"
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
            float _NoiseScale;
            float _IsColor;
            float _Delta;
            int _GradientType;
            // http://g3d.cs.williams.edu/websvn/filedetails.php?repname=g3d&path=%2FG3D10%2Fdata-files%2Fshader%2Fgradient.glsl
            float3 hueGradient(float t) 
            {
                float3 p = abs(frac(t+float3(1.0,2.0/3.0,1.0/3.0))*6.0 - 3.0);
                return clamp(p-1.0, 0.0, 1.0);
            }
            float3 techGradient(float t) 
            {
                return pow(t+0.01, float3(120.0, 10.0, 180.0));
            }
            float3 fireGradient(float t) 
            {
                return max(pow(min(t*1.02,1.0), float3(1.7,25.0,100.0)),
                0.06 * pow(max(1.0 - abs(t-0.35), 0.0), 5.0));
            }
            float3 desertGradient(float t) 
            {
                float s = sqrt(clamp(1.0 - (t - 0.4) / 0.6, 0.0, 1.0));
                float3 sky = sqrt(lerp(float3(1, 1, 1), float3(0, 0.8, 1.0), smoothstep(0.4, 0.9, t)) * float3(s, s, 1.0));
                float3 land = lerp(float3(0.7, 0.3, 0.0), float3(0.85, 0.75 + max(0.8 - t * 20.0, 0.0), 0.5), pow2(t / 0.4));
                return clamp((t > 0.4) ? sky : land, 0.0, 1.0) * clamp(1.5 * (1.0 - abs(t - 0.4)), 0.0, 1.0);
            }
            float3 electricGradient(float t) 
            {
                return clamp( float3(t * 8.0 - 6.3, pow2(smoothstep(0.6, 0.9, t)), pow(t, 3.0) * 1.7), 0.0, 1.0);
            }
            float3 neonGradient(float t) 
            {
                return clamp(float3(t * 1.3 + 0.1, pow2(abs(0.43 - t) * 1.7), (1.0 - t) * 1.7), 0.0, 1.0);
            }
            float3 heatmapGradient(float t)
            {
                return clamp((pow(t, 1.5) * 0.8 + 0.2) * float3(smoothstep(0.0, 0.35, t) + t * 0.5, smoothstep(0.5, 1.0, t), max(1.0 - t * 1.7, t * 7.0 - 6.0)), 0.0, 1.0);
            }

            float3 rainbowGradient(float t)
            {
                float3 c = 1.0 - pow(abs(t - float3(0.65, 0.5, 0.2)) * float3(3.0, 3.0, 5.0), float3(1.5, 1.3, 1.7));
                c.r = max((0.15 - pow2(abs(t - 0.04) * 5.0)), c.r);
                c.g = (t < 0.5) ? smoothstep(0.04, 0.45, t) : c.g;
                return clamp(c, 0.0, 1.0);
            }

            float3 brightnessGradient(float t)
            {
                return (t * t);
            }

            float3 grayscaleGradient(float t)
            {
                return (t);
            }

            float3 stripeGradient(float t)
            {
                return fmod(floor(t * 32.0), 2.0) * 0.2 + 0.8;
            }

            float3 ansiGradient(float t)
            {
                return fmod(floor(t * float3(8.0, 4.0, 2.0)), 2.0);
            }
            float3 normal(float3 v, float delta) 
            {
                float2 coefficient = float2(
                    snoise(v + float3(delta, 0.0, 0.0)) - snoise(v - float3(delta, 0.0, 0.0)),
                    snoise(v + float3(0.0, delta, 0.0)) - snoise(v - float3(0.0, delta, 0.0))) / delta * 0.5;
                float3 req = float3(-coefficient.x, -coefficient.y, 1.0);
                return req / length(req);
            }

            half4 frag (Varings IN) : SV_Target
            {
                float2 uv = IN.uv * _NoiseScale;
                float3 p = normal(float3(uv, _Time.y * _TimeSpeed), _Delta);
                p = (p + 1.0) * 0.5;
                float3 gray = rgb2gray(p);
                float3 color = lerp(gray, (_GradientType == 0) ? hueGradient(gray) : (_GradientType == 1) ? techGradient(gray) : (_GradientType == 2) ? fireGradient(gray) : (_GradientType == 3) ? desertGradient(gray) : (_GradientType == 4) ? electricGradient(gray) : (_GradientType == 5) ? neonGradient(gray) : (_GradientType == 6) ? heatmapGradient(gray) : (_GradientType == 7) ? rainbowGradient(gray) : (_GradientType == 8) ? brightnessGradient(gray) : (_GradientType == 9) ? grayscaleGradient(gray) : (_GradientType == 10) ? stripeGradient(gray) : (_GradientType == 11) ? ansiGradient(gray) : (_GradientType == 12) ? p : gray, _IsColor);
                return half4(color, 1);
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
        UsePass "Universal Render Pipeline/Lit/depthOnly"
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
    }
    FallBack "Diffuse"
}