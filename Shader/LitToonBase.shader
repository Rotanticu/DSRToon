Shader "LitToon/LitToonBase"
{
    Properties
    {
        [MainTexture] _MainTex ("MainTexture", 2D) = "white" {}
        _MainTexHSVTint ("Main Tex HSV Tint", Vector) = (0,0,0,1)
        [MainColor] _MainColor ("Main Color", Color) = (1,1,1,1)
        _ShadowThreshold ("Shadow Threshold", Range(0, 1)) = 0.1
        _ShadowThresholdSmooothRange ("Shadow Threshold Smoooth Range", Vector) = (0.45,0.55,0)
        _remapIntensity ("Remap Range", Range(0, 0.99)) = 0.5
        _SpecThreshold ("Specular Threshold", Range(0, 0.01)) = 0.002
        _RampMap ("Ramp Map", 2D) = "black" {}
        _DarkColor ("Dark Color", Color) = (0.2, 0.2, 0.2, 1)
        _LightColor ("Light Color", Color) = (1, 1, 1, 1)
        _SpecColor ("Specular Color", Color) = (1, 1, 1, 1)
        _SpecPower ("Specular Power", Range(0, 128)) = 16
        _HairSpecRingOffset ("Hair SpecRing Offset", Vector) = (0,0,0,0)
        _HairSpecScale ("Hair SpecRing  Scale", Range(0, 0.1)) = 0
        [Toggle] _USE_OBJECT_SPACE_BINORMAL ("USE_OBJECT_SPACE_BINORMAL", int) = 1
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
            half4 _MainTexHSVTint;
            half _ShadowThreshold;
            half4 _ShadowThresholdSmooothRange;
            half3 _DarkColor;
            half3 _LightColor;
            half3 _SpecColor;
            half _SpecPower;
            half4 _HairSpecRingOffset;
            half _HairSpecScale;
            half _SpecThreshold;
            half _remapIntensity;
            float4 _MainTex_ST;
            CBUFFER_END

            #pragma multi_compile_local __ _USE_OBJECT_SPACE_BINORMAL_ON
            //接收阴影关键字
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _SHADOWS_SOFT

            
            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
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
                float3 normalTS : TEXCOORD5;
				float3 lightDirTS : TEXCOORD6;
				float3 viewDirTS : TEXCOORD7;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            TEXTURE2D(_RampMap);
            SAMPLER(sampler_RampMap);

            Varings vert (Attributes IN)
            {
                Varings OUT;
                float3 cameraPositionWS = GetCameraPositionWS();
                OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
                VertexPositionInputs positionInputs = GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionCS = positionInputs.positionCS;
                OUT.positionWS = positionInputs.positionWS;
                float3 viewDirWS = cameraPositionWS - positionInputs.positionWS;
                OUT.viewDirWS = viewDirWS;
                VertexNormalInputs normalInputs = GetVertexNormalInputs(IN.normalOS,IN.tangentOS);
                OUT.normalWS = normalInputs.normalWS;
                OUT.shadowCoord = GetShadowCoord(positionInputs);

                
				// tangent、binormal、normal为模型坐标系下的表示
				// 转置摆放后（按行摆放，按列摆放的话为 切线空间->模型空间）即为 模型空间->切线空间 的矩阵
                #ifdef _USE_OBJECT_SPACE_BINORMAL_ON
                //hack:这个是错误的公式，但是我抄错代码，用Object空间之后发现效果更好，转为feture吧
                float3 binormal = cross(IN.normalOS, IN.tangentOS.xyz) * IN.tangentOS.w;
                #else
                //float3 binormal = real3(cross(normalInputs.normalWS, float3(normalInputs.tangentWS))) * real(IN.tangentOS.w) * GetOddNegativeScale();
                //上面这个是正确的公式，等价于normalInputs.bitangentWS
                float3 binormal = normalInputs.bitangentWS;
                #endif
				float3x3 rotation = float3x3(IN.tangentOS.xyz, binormal, IN.normalOS);
                // URP 中没有 ObjSpaceLightDir
				half3 objectSpaceLightDir = TransformWorldToObjectDir(_MainLightPosition.xyz);
				OUT.lightDirTS = mul(rotation, objectSpaceLightDir).xyz;
				// URP 中没有 ObjSpaceViewDir
				half3 objectSpaceViewDir = half3(TransformWorldToObject(cameraPositionWS) - IN.positionOS);
				OUT.viewDirTS = mul(rotation, objectSpaceViewDir).xyz;
                OUT.normalTS = half3(0, 0, 1);// = mul(rotation, IN.normalOS);
                return OUT;
            }

            half4 frag (Varings IN) : SV_Target
            {
                // light
                Light light = GetMainLight(IN.shadowCoord,IN.positionWS,float4(1,1,1,1));
                //采样主纹理
                half4 texColor = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uv);
                texColor.rgb = HsvToRgb(RgbToHsv(texColor) - 2 * _MainTexHSVTint.rgb);
                // 亮暗面
                float shadow = light.shadowAttenuation;
                float ndotL = dot(IN.normalWS, light.direction);
                half darkness = saturate(ndotL * shadow);
                
                //重映射亮暗边界
                //half3 diffuse = (darkness < _ShadowThreshold ? _DarkColor : _LightColor) * light.color.rgb * texColor.rgb;
                //用smoothstep函数代替条件判断，平滑的从亮部过渡到暗部
                half ifFlag = smoothstep(_ShadowThresholdSmooothRange.x,_ShadowThresholdSmooothRange.y,darkness - _ShadowThreshold);
                
                half3 diffuse = (ifFlag * _LightColor + (1 - ifFlag) * _DarkColor) * light.color.rgb * texColor.rgb;
                //使用remap贴图模仿PRR中的SSR效果
                //类似这样的原画https://yande.re/post/show/1230691
                half remapIfFlag = smoothstep(-0.2,1,darkness - _ShadowThreshold);
                half3 remap = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, float2(saturate(remapIfFlag),0.5)).rgb;
                //颜色减淡（Color Dodge）混合模式 试了一堆只有这个不会太亮或太暗
                //原公式f(a,b) = b / (1 - a) 为了能让参数有意义做了变形
                diffuse = diffuse / (2 - _remapIntensity - (remap));

                //return half4(diffuse,1);

                float3 halfDir = normalize(light.direction + IN.viewDirWS);
                half3 specMask = darkness;
                half spec = pow(specMask * dot(IN.normalWS, halfDir),_SpecPower);
                half3 specular = spec < _SpecThreshold ? 0 : _SpecColor.rgb;

                half3 tangentLightDir = normalize(IN.lightDirTS);
                float3 tangentHalfDir = normalize(normalize(IN.viewDirTS) + normalize(IN.lightDirTS));
                // Scale
				tangentHalfDir = tangentHalfDir - _HairSpecRingOffset.z * tangentHalfDir.x * half3(1, 0, 0);
				tangentHalfDir = normalize(tangentHalfDir);
				tangentHalfDir = tangentHalfDir - _HairSpecRingOffset.w * tangentHalfDir.y * half3(0, 1, 0);
				tangentHalfDir = normalize(tangentHalfDir);

                tangentHalfDir = normalize(tangentHalfDir + float3(_HairSpecRingOffset.x,_HairSpecRingOffset.y,0));
                half tangentSpec = dot(IN.normalTS, tangentHalfDir);
				half w = fwidth(tangentSpec) * 6.0;
				half3 tangentSpecular = lerp(half3(0, 0, 0), _SpecColor.rgb, smoothstep(-w, w, tangentSpec + _HairSpecScale - 1));
                specular = max(specular,tangentSpecular);
                specular = specular + tangentSpecular;
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