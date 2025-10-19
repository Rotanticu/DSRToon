Shader "VFXTex/Star"
{
    Properties
    {
        _Radius("Radius", Range(0, 2)) = 1
        _Intensity("Intensity", Range(0, 10)) = 1
        _PowerExponent("Power Exponent", Range(0, 10)) = 1
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

            float _Radius;
            float _Intensity;
            float _PowerExponent;

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
                float2 center = float2(0.5, 0.5);
                float2 position = 2 * (IN.uv - center);
                float2 polar = UVToPolar(position, float2(0, 0));
                
                float star = min(abs(position.x), abs(position.y)) * _Radius;
                // 距离函数创建星形边界
                float t = _Intensity / abs(star - polar.x);
                
                // 使用幂函数控制边缘锐度
                t = saturate(pow(abs(t), _PowerExponent));
                
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
