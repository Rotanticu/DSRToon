Shader "Custom/MyCustomURPShaderTemplate"
{
    Properties
    {
        _TimeSpeed("Time Speed", Float) = 0.1
        _Scale("Scale", Float) = 1
        [IntRange] _Octaves("Octaves", Range(1, 360)) = 40
        _Offset("Offset", Vector) = (0.5, 0.5, 0.5, 0.5)
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
            float _Scale;
            int _Octaves;
            float2 _Offset;

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
                //mandelbrot曼德布洛特集合
                int j=0;
                float2 x = ((IN.uv * 2 - 1) - _Offset) * _Scale;
                float y = 1.5 - IN.uv.x * 0.5;
                float2 z = 0.0;

                for (int i=0; i<_Octaves; i++)
                {
                    j++;
                    if (length(z) > 2.0) break;
                    z = float2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + x * y;//复数形式的迭代公式：z = z² + c
                }

                float h = fmod(_Time.y * _TimeSpeed, _Octaves) / _Octaves;
                float3 color = hsv2rgb(float3(h, 1.0, 1.0));

                float t = float(j) / _Octaves;
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