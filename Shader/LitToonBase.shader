Shader "LitToon/LitToonBase"
{
    Properties
    {
        [MainTexture] _MainTex ("MainTexture", 2D) = "white" {}
        [MainColor] _MainColor ("Main Color", Color) = (1,1,1,1)
        _ShadowThreshold ("Shadow Threshold", Range(0, 1)) = 0.5
        _remapRange ("Remap Range", Range(0, 1)) = 1
        _SpecThreshold ("Specular Threshold", Range(0, 0.01)) = 0.002
        _RampMap ("Ramp Map", 2D) = "black" {}
        _DarkColor ("Dark Color", Color) = (0.2, 0.2, 0.2, 1)
        _LightColor ("Light Color", Color) = (1, 1, 1, 1)
        _SpecColor ("Specular Color", Color) = (1, 1, 1, 1)
        _SpecPower ("Specular Power", Range(0, 128)) = 16
    }

    SubShader
    {
        Tags 
        { 
            "RenderPipeline"="UniversalPipeline"
            "RenderType"="Opaque"
            "Queue"="Geometry"
        }
        //LOD 100
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
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
            //尽量对齐到float4,否则unity底层会自己填padding来对齐,会有空间浪费
            CBUFFER_START(UnityPerMaterial)
            half4 _MainColor;
            Float _ShadowThreshold;
            half3 _DarkColor;
            half3 _LightColor;
            half3 _SpecColor;
            half _SpecPower;
            half _SpecThreshold;
            half _remapRange;
            float4 _MainTex_ST;
            CBUFFER_END

            //接收阴影关键字
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _SHADOWS_SOFT

            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct Varings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : TEXCOORD2;
                float3 viewDirWS : TEXCOORD3;
                float4 shadowCoord : TEXCOORD4;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_RampMap);
            SAMPLER(sampler_RampMap);

            Varings vert (Attributes IN)
            {
                Varings OUT;
                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS.xyz);
                //OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                OUT.positionCS = positionInputs.positionCS;
                OUT.positionWS = positionInputs.positionWS;
                OUT.viewDirWS = GetCameraPositionWS() - positionInputs.positionWS;
                OUT.normalWS = normalInputs.normalWS;
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.shadowCoord = GetShadowCoord(positionInputs);
                return OUT;
            }

            half4 frag (Varings IN) : SV_Target
            {
                // light
                Light light = GetMainLight(IN.shadowCoord,IN.positionWS,float4(1,1,1,1));
                //采样纹理
                half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);  
                // Shadow
                float shadow = light.shadowAttenuation;
                float ndotL = dot(IN.normalWS, light.direction);
                half darkness = saturate(ndotL * shadow);
                half3 colorDark = half3(0.2, 0.2, 0.2);
                half3 colorLight = half3(1.0, 1.0, 1.0);
                
                
                half ifFlag = smoothstep(0.45,0.55,darkness - _ShadowThreshold);
                half remapIfFlag = smoothstep(-0.2,1,darkness - _ShadowThreshold);
                half3 remap = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(saturate(remapIfFlag),0.5)).rgb;
                //half3 diffuse = (darkness < _ShadowThreshold ? _DarkColor : _LightColor) * light.color.rgb * texColor.rgb;
                half3 diffuse = (ifFlag * _LightColor + (1 - ifFlag) * _DarkColor) * light.color.rgb * texColor.rgb;
                diffuse = diffuse / (2 - _remapRange - (remap));

                float3 halfDir = normalize(light.direction + IN.viewDirWS);
                half3 specMask = darkness;
                half spec = pow(specMask * dot(IN.normalWS, halfDir),_SpecPower);
                half3 specular = spec < _SpecThreshold ? 0 : _SpecColor.rgb;

                
                half4 finalColor = half4(diffuse + specular,1) * _MainColor;
                return finalColor;
            }
            ENDHLSL
        }

        //以下是这三个pass的官方代码，如果你需要自定义这些pass,你可以在这个基础上修改
        // Here are the official codes for these three passes. If you need to customize these passes, you can modify them based on this
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            //ZClip Off
            ZWrite On
            ZTest LEqual
            Cull[_Cull]

            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _ALPHATEST_ON
            #pragma shader_feature _GLOSSINESS_FROM_BASE_ALPHA

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment


            //由于这段代码中声明了自己的CBUFFER，与我们需要的不一样，所以我们注释掉他
            //Since this code declares its own CBFFER, which is different from what we need, we have commented it out
            //#include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }
        
        Pass {
            Name "DepthOnly"
        
            Tags {
                "LightMode" = "DepthOnly"
            }
        
            HLSLPROGRAM
            //由于这段代码中声明了自己的CBUFFER，与我们需要的不一样，所以我们注释掉他
            //Since this code declares its own CBFFER, which is different from what we need, we have commented it out
            //#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
        
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment
            ENDHLSL
        }
        
        Pass {
            Name "DepthNormals"
            Tags {
                "LightMode" = "DepthNormals"
            }
        
            HLSLPROGRAM
            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment
        
            //由于这段代码中声明了自己的CBUFFER，与我们需要的不一样，所以我们注释掉他
            //Since this code declares its own CBFFER, which is different from what we need, we have commented it out
            //#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitDepthNormalsPass.hlsl"
            ENDHLSL
        }
    }
    FallBack "Diffuse"
}