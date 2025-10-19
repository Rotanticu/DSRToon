#ifndef NOISE_LIBRARY_INCLUDED
#define NOISE_LIBRARY_INCLUDED

// ========================================
// 噪声库 - Noise Library
// ========================================
// 这是一个用于学习Shader噪声效果的代码库
// 包含各种噪声函数的实现和应用示例

// 包含通用数学库
#include "Common.hlsl"

// ========================================
// 基础噪声函数
// ========================================

// 基础2D噪声
float noise2D(float2 p)
{
    float2 i = floor(p);
    float2 f = frac(p);
    
    // 四个角的值
    float a = rand2D(i);
    float b = rand2D(i + float2(1.0, 0.0));
    float c = rand2D(i + float2(0.0, 1.0));
    float d = rand2D(i + float2(1.0, 1.0));
    
    // 双线性插值
    float2 u = f * f * (3.0 - 2.0 * f);
    return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
}

// 基础3D噪声
float noise3D(float3 p)
{
    float3 i = floor(p);
    float3 f = frac(p);
    
    // 八个角的值
    float a = rand3D(i);
    float b = rand3D(i + float3(1.0, 0.0, 0.0));
    float c = rand3D(i + float3(0.0, 1.0, 0.0));
    float d = rand3D(i + float3(1.0, 1.0, 0.0));
    float e = rand3D(i + float3(0.0, 0.0, 1.0));
    float f_val = rand3D(i + float3(1.0, 0.0, 1.0));
    float g = rand3D(i + float3(0.0, 1.0, 1.0));
    float h = rand3D(i + float3(1.0, 1.0, 1.0));
    
    // 三线性插值
    float3 u = f * f * (3.0 - 2.0 * f);
    return lerp(lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y),
               lerp(lerp(e, f_val, u.x), lerp(g, h, u.x), u.y), u.z);
}

// 平滑噪声
float smoothNoise2D(float2 p)
{
    float2 i = floor(p);
    float2 f = frac(p);
    
    // 使用smoothstep进行插值
    float2 u = f * f * (3.0 - 2.0 * f);
    
    float a = rand2D(i);
    float b = rand2D(i + float2(1.0, 0.0));
    float c = rand2D(i + float2(0.0, 1.0));
    float d = rand2D(i + float2(1.0, 1.0));
    
    return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
}

// ========================================
// 分形布朗运动 (FBM)
// ========================================

// TODO: 在这里添加FBM函数
// - fbm2D()
// - fbm3D()
// - fbmWithOctaves()

// ========================================
// 特殊噪声类型
// ========================================

// TODO: 在这里添加特殊噪声函数
// - voronoiNoise()
// - cellularNoise()
// - ridgedNoise()
// - billowedNoise()

// ========================================
// 复合噪声
// ========================================

// TODO: 在这里添加复合噪声函数
// - turbulence()
// - marbleNoise()
// - woodNoise()
// - cloudNoise()

// ========================================
// 噪声应用函数
// ========================================

// TODO: 在这里添加噪声应用函数
// - noiseToGradient()
// - noiseToPattern()
// - noiseToTexture()

// ========================================
// 工具函数
// ========================================

// 噪声混合函数
float mixNoise(float noise1, float noise2, float factor)
{
    return lerp(noise1, noise2, factor);
}

// 噪声缩放函数
float scaleNoise(float noise, float scale)
{
    return noise * scale;
}

// 噪声偏移函数
float offsetNoise(float noise, float offset)
{
    return noise + offset;
}

// ========================================
// 示例和测试函数
// ========================================

// TODO: 在这里添加示例函数
// - testBasicNoise()
// - testFBMNoise()
// - testVoronoiNoise()

#endif // NOISE_LIBRARY_INCLUDED
