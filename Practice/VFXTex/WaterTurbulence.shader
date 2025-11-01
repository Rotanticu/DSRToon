Shader "VFXTex/WaterTurbulence"
{
    Properties
    {
        _TimeSpeed("Time Speed", Range(0, 100)) = 0.00001
        _Size("Size", Float) = 30.0
        _Intensity("Intensity", Float) = 1
        [IntRange] _Iterations("Iterations", Range(1, 10)) = 2
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
            float _Iterations;
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
                float2 p = IN.uv * _Size;
                float2 i = p;
                float c = 0.0;
                float inten = _Intensity;
                float time = _Time.y * _TimeSpeed;
                float r = length(p + float2(sin(time), sin(time*0.433+2.))*3.);
                for (float n=0.0; n<_Iterations; n++)
                {
                    float t = r-time * (1.0 - (1.9/(n+1.)));
                    t = r-time/(n+.6);//r-time*(1.+.5/float(n+1.)));
                    i -= p + float2(
                        cos(t-i.x-r)+sin(t+i.y),
                        sin(t-i.y)+cos(t+i.x)+r);

                    c += 1./length(float2(sin(i.x+t)/inten,cos(i.y+t)/inten));
                }
                c /= float(_Iterations);
                c = clamp(c-1.1, 0.0, 1.0);
                return half4(c, c, c, 1);
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
        UsePass "Universal Render Pipeline/Lit/depthOnly"
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
    }
    FallBack "Diffuse"
}