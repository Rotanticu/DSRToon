Shader "Custom/MyCustomURPShaderTemplate"
{
    Properties
    {
        _TimeSpeed("Time Speed", Float) = 0.1
        _Scale("Scale", Float) = 100
        _Frequency("Frequency", Float) = 10
        [IntRange] _Octaves("Octaves", Range(1, 360)) = 10
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

            Varings vert (Attributes IN)
            {
                Varings OUT;
                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionCS = positionInputs.positionCS;
		        OUT.uv = IN.uv;
                return OUT;
            }

            float _TimeSpeed;
            float _Scale;
            float _Frequency;
            int _Octaves;
            float2 _Offset;
            float combinedNoise(float2 p) 
            {
            float s = 0.5;
            float v = 0.0;
            for (int i=0; i<3; i++) 
            {
                v += s*snoise(p/s);
                s *= 0.4;
            }
            return v;
            }
            half4 frag (Varings IN) : SV_Target
            {
                //marbleNoiseFrag
                float2 pos = IN.uv / _Scale;
                float2 dpos = float2(pos.x - pos.y, pos.x + pos.y);//进行45度旋转和缩放变换
                dpos = mul(rotate2d(radians(_Time.y * _TimeSpeed)),dpos);//动态旋转
                dpos += 0.12 * combinedNoise(dpos);
                dpos += 0.25 * snoise(0.5*dpos*float2(0.5,1.0));
                float graph = 0.5 + sin(dpos.x * _Frequency) / 2.0;
                return half4(graph, graph, graph, 1);
            }
            ENDHLSL
        }
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
        UsePass "Universal Render Pipeline/Lit/depthOnly"
        UsePass "Universal Render Pipeline/Lit/DepthNormals"
    }
    FallBack "Diffuse"
}