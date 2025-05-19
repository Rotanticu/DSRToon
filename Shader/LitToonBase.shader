Shader "Custom/MyCustomURPShaderTemplate"
{
    Properties
    {
        [MainTexture] _MainTex ("MainTexture", 2D) = "white" {}
        [MainColor]_MainColor ("Main Color", Color) = (1,1,1,1)
        _Metallic ("Metallic", Range(0, 1)) = 0
        _Smoothness ("Smoothness", Range(0, 1)) = 0.5

        //Option Enum
        [Header(Option)]
        [Enum(UnityEngine.Rendering.BlendOp)]_BlendOp("BlendOp", Float) = 0.0
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("SrcBlend", Float) = 1.0
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("DstBlend", Float) = 0.0
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlendAlpha("SrcBlendAlpha", Range(0, 1)) = 1.0
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlendAlpha("DstBlendAlpha", Range(0, 1)) = 0.0
        [Header(ZTest)]
        [ToggleUI]_ZWrite("ZWrite", Float) = 1.0
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("ZTest", Float) = 4.0
        [ToggleUI]_ZClip("ZClip", Float) = 1.0
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull", Float) = 2.0
        [Header(Mask)]
        //[Enum(UnityEngine.Rendering.ColorWriteMask)]_ColorMask("ColorMask", Float) = 15.0
        //[ToggleUI]_AlphaToMask("AlphaToMask", Float) = 0.0

        //Stencil enum
        [Header(Stencil)]
        [IntRange]_Stencil ("Stencil ID", Range(0,255)) = 0
        [IntRange]_StencilWriteMask ("Stencil Write Mask", Range(0,255)) = 255
        [IntRange]_StencilReadMask ("Stencil Read Mask", Range(0,255)) = 255
        [Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp("StencilComp", Float) = 0.0
        [Enum(UnityEngine.Rendering.StencilOp)]_StencilOp("StencilOp", Float) = 0.0
        [Enum(UnityEngine.Rendering.StencilOp)]_StencilOpFail("StencilOpFail", Float) = 0.0
        [Enum(UnityEngine.Rendering.StencilOp)]_StencilOpZFail("StencilOpZFail", Float) = 0.0
        [Enum(UnityEngine.Rendering.StencilOp)]_StencilOpZFailFront("StencilOpZFailFront", Float) = 0.0
        [Enum(UnityEngine.Rendering.CompareFunction)]_StencilCompFront("StencilCompFront", Float) = 0.0
        [Enum(UnityEngine.Rendering.StencilOp)]_StencilOpFront("StencilOpFront", Float) = 0.0
        [Enum(UnityEngine.Rendering.CompareFunction)]_StencilCompBack("StencilCompBack", Float) = 0.0
        [Enum(UnityEngine.Rendering.StencilOp)]_StencilOpBack("StencilOpBack", Float) = 0.0
        [Enum(UnityEngine.Rendering.StencilOp)]_StencilOpZFailBack("StencilOpZFailBack", Float) = 0.0
        //[HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
    }

    SubShader
    {
        Tags 
        { 
            "RenderPipeline"="UniversalPipeline"
            // "RenderType"="Background"
            "RenderType"="Opaque"
            // "RenderType"="Transparent"
            // "RenderType"="TransparentCutout"
            // "RenderType"="Overlay"

            //"Queue" = "Background"
            "Queue"="Geometry"
            //"Queue" = "AlphaTest"
            //"Queue" = "Transparent"
            //"Queue" = "TransparentCutout"
            //"Queue" = "Overlay"
            //"IgnoreProjector" = "True"
        }
        //LOD 100
        Pass
        {
            Tags
			{
				"LightMode"="UniversalForward"
			}

            // BlendOp [_BlendOp]
            // Blend [_SrcBlend][_DstBlend], [_SrcBlendAlpha][_DstBlendAlpha]
            // ZWrite [_ZWrite]
            // ZTest [_ZTest]
            // ZClip [_ZClip]
            // Cull [_Cull]
            // ColorMask [_ColorMask]
            // AlphaToMask [_AlphaToMask]

            // Stencil
            // {
            //     Ref [_Stencil]
            //     Comp [_StencilComp]
            //     ReadMask [_StencilReadMask]
            //     WriteMask [_StencilWriteMask]
            //     Pass [_StencilOp]
            //     Fail [_StencilOpFail]
            //     ZFail [_StencilOpZFail]
            //     ZFailFront [_StencilOpZFailFront]
            //     CompFront [_StencilCompFront]
            //     PassFront [_StencilOpFront]
            //     CompBack [_StencilCompBack]
            //     PassBack [_StencilOpBack]
            //     ZFailBack [_StencilOpZFailBack]
            // }

            //Geometry
            ZWrite On
            ZTest LEqual
            Cull Back

            ////Transparent
            //ZWrite Off
            //Blend SrcAlpha OneMinusSrcAlpha // 传统透明度
            //Blend One OneMinusSrcAlpha // 预乘透明度
            //Blend OneMinusDstColor One // 软加法
            //Blend DstColor Zero // 正片叠底（相乘）
            //Blend OneMinusDstColor One // 滤色 //柔和叠加（soft Additive）
            //Blend DstColor SrcColor // 2x相乘 (2X Multiply)
            //Blend One One // 线性减淡
            //BlendOp Min Blend One One //变暗
            //BlendOp Max Blend One One //变亮




            HLSLPROGRAM
            #pragma target 3.5
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            //尽量对齐到float4,否则unity底层会自己填padding来对齐,会有空间浪费
            CBUFFER_START(UnityPerMaterial)
            half4 _MainColor;
            float _Metallic;
            float _Smoothness;
            float4 _MainTex_ST;
            CBUFFER_END


            //GPU Instancing 和SRP Batcher冲突 根据需要确定是否开启
            #pragma multi_compile_instancing
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
            
            UNITY_INSTANCING_BUFFER_START(PerInstance)
            //UNITY_DEFINE_INSTANCED_PROP(float4, _MainColor)
            UNITY_INSTANCING_BUFFER_END(PerInstance)

            //接收阴影关键字
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
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
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            Varings vert (Attributes IN)
            {
                Varings OUT;
                UNITY_SETUP_INSTANCE_ID(IN);
                UNITY_TRANSFER_INSTANCE_ID(IN, OUT);
                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS.xyz);
                //OUT.positionCS = TransformObjectToHClip(IN.positionOS);
                OUT.positionCS = positionInputs.positionCS;
                OUT.positionWS = positionInputs.positionWS;
                OUT.viewDirWS = GetCameraPositionWS() - positionInputs.positionWS;
                OUT.normalWS = normalInputs.normalWS;
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                return OUT;
            }

            half4 frag (Varings IN) : SV_Target
            {
                //GPU Instancing
                UNITY_SETUP_INSTANCE_ID(IN);
                //half4 mainColor = UNITY_ACCESS_INSTANCED_PROP(PerInstance, _MainColor);

                // light
                float4 shadowCoord = TransformWorldToShadowCoord(IN.positionWS.xyz);
                Light light = GetMainLight(shadowCoord);
                float3 lightDirWS = light.direction;
                float3 lightColor = light.color;
                float lightIntensity = light.distanceAttenuation;

                //采样纹理
                half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);  
                // Diffuse lighting
                //half3 diffuse = LightingLambert(light.color, light.direction, IN.normalWS);
                float3 normal = normalize(IN.normalWS);
                float NdotL = saturate(dot(normal, lightDirWS));
                half3 diffuse = _MainColor.xyz * texColor.xyz *lightColor * NdotL;

                // Specular lighting (Blinn-Phong)
                //half3 specular = LightingSpecular(light.color, light.direction, normalize(IN.normalWS), normalize(IN.viewDirWS), _SpecularColor, _Smoothness);
                float metallic = _Metallic;
                float smoothness = _Smoothness;
                float3 viewDir = IN.viewDirWS;
                float3 halfDir = normalize(lightDirWS + viewDir);
                float NdotH = saturate(dot(normal, halfDir));
                float specularIntensity = pow(NdotH, smoothness * 100.0);
                half3 specular = lightColor * lightIntensity * specularIntensity * metallic;

                //逐顶点光源
                //half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
                //逐像素光源
                // uint pixelLightCount = GetAdditionalLightsCount();
                // for (uint lightIndex = 0; lightIndex < pixelLightCount; ++lightIndex)
                // {
                //     Light light = GetAdditionalLight(lightIndex, IN.positionWS);
                //     diffuse += LightingLambert(light.color, light.direction, IN.normalWS);
                //     specular += LightingSpecular(light.color, light.direction, normalize(IN.normalWS), normalize(IN.viewDirWS), _SpecularColor, _Smoothness);
                // }
                
                // Shadow
                float shadow = light.shadowAttenuation;

                half4 finalColor = half4(diffuse + specular,texColor.a) * shadow;

                return finalColor;
            }
            ENDHLSL
        }

        //LitInput.hlsl中包括了Cbuffer的定义，通常来说会和你自定义的Cbuffer冲突，导致SRP Batcher失败,因此最好不要引入LitInput.hlsl
        //但是以下三个pass在官方代码中都引入了LitInput.hlsl
        //提前define UNIVERSAL_LIT_INPUT_INCLUDED可以让你绕过以下三个官方Pass中对LitInput.hlsl引入
        //如果你需要引入LitInput.hlsl，你可以注释掉#define UNIVERSAL_LIT_INPUT_INCLUDED
        //LitInput.Hlsl includes the definition of Cbuffer, which usually conflicts with your custom Cbuffer, causing SRP Batcher to fail. Therefore, it is best not to introduce LitInput.Hlsl
        //However, the following three passes have all introduced LitInput.Hlsl in the official code
        //Defining UNIVERSAL_LIT-INPUT_INCLUDED in advance allows you to bypass the introduction of LitInput.Hlsl in the following three official passes
        //If you need to introduce LitInput.Hlsl, you can comment out # define UNIVERSAL_LIT-INPUT_INCLUDED
        HLSLINCLUDE
        #define UNIVERSAL_LIT_INPUT_INCLUDED
        #define UNIVERSAL_SIMPLE_LIT_DEPTH_NORMALS_PASS_INCLUDED
        ENDHLSL
        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
        UsePass "Universal Render Pipeline/Lit/depthOnly"
        UsePass "Universal Render Pipeline/Lit/DepthNormals"

        //以下是这三个pass的官方代码，如果你需要自定义这些pass,你可以在这个基础上修改
        // Here are the official codes for these three passes. If you need to customize these passes, you can modify them based on this
        // Pass
        // {
        //     Name "ShadowCaster"
        //     Tags{"LightMode" = "ShadowCaster"}

        //     //ZClip Off
        //     ZWrite On
        //     ZTest LEqual
        //     Cull[_Cull]

        //     HLSLPROGRAM
        //     // Required to compile gles 2.0 with standard srp library
        //     #pragma prefer_hlslcc gles
        //     #pragma exclude_renderers d3d11_9x
        //     #pragma target 2.0

        //     // -------------------------------------
        //     // Material Keywords
        //     #pragma shader_feature _ALPHATEST_ON
        //     #pragma shader_feature _GLOSSINESS_FROM_BASE_ALPHA

        //     //--------------------------------------
        //     // GPU Instancing
        //     #pragma multi_compile_instancing

        //     #pragma vertex ShadowPassVertex
        //     #pragma fragment ShadowPassFragment


        //     //由于这段代码中声明了自己的CBUFFER，与我们需要的不一样，所以我们注释掉他
        //     //Since this code declares its own CBFFER, which is different from what we need, we have commented it out
        //     //#include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"

        //     #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        //     #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
        //     #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
        //     ENDHLSL
        // }
        
        // Pass {
        //     Name "DepthOnly"
        
        //     Tags {
        //         "LightMode" = "DepthOnly"
        //     }
        
        //     HLSLPROGRAM
        //     //由于这段代码中声明了自己的CBUFFER，与我们需要的不一样，所以我们注释掉他
        //     //Since this code declares its own CBFFER, which is different from what we need, we have commented it out
        //     //#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
        //     #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
        
        //     #pragma vertex DepthOnlyVertex
        //     #pragma fragment DepthOnlyFragment
        //     ENDHLSL
        // }
        
        // Pass {
        //     Name "DepthNormals"
        //     Tags {
        //         "LightMode" = "DepthNormals"
        //     }
        
        //     HLSLPROGRAM
        //     #pragma vertex DepthNormalsVertex
        //     #pragma fragment DepthNormalsFragment
        
        //     //由于这段代码中声明了自己的CBUFFER，与我们需要的不一样，所以我们注释掉他
        //     //Since this code declares its own CBFFER, which is different from what we need, we have commented it out
        //     //#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
        //     #include "Packages/com.unity.render-pipelines.universal/Shaders/LitDepthNormalsPass.hlsl"
        //     ENDHLSL
        // }
    }
    FallBack "Diffuse"
}