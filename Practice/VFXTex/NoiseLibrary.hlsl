#ifndef NOISE_LIBRARY_INCLUDED
#define NOISE_LIBRARY_INCLUDED

// ========================================
// 噪声库 - Noise Library
// ========================================
// 这是一个用于学习Shader噪声效果的代码库
// 包含各种噪声函数的实现和应用示例

// ========================================
// 基础数学函数
// ========================================

// 常量定义 - 使用条件编译防止重复定义
#ifndef PI
#define PI 3.14159265359
#endif

#ifndef PI2
#define PI2 6.28318530718
#endif

#ifndef RECIPROCAL_PI
#define RECIPROCAL_PI 0.31830988618
#endif

#ifndef RECIPROCAL_PI2
#define RECIPROCAL_PI2 0.15915494309
#endif

#ifndef EPSILON
#define EPSILON 1e-6
#endif

// 工具函数
float pow2(float x) { return x * x; }
float pow3(float x) { return x * x * x; }
float pow4(float x) { float x2 = x * x; return x2 * x2; }
float pow5(float x) { float x2 = x * x; return x2 * x2 * x; }
float average(float3 color) { return dot(color, float3(0.3333, 0.3333, 0.3333)); }
float2 UVToPolar(float2 uv,float2 center) 
{ 
    float2 delta = uv - center;
    float radius = length(delta);//0~√0.5
    float angle = atan2(delta.x, delta.y) * RECIPROCAL_PI2;//-0.5~0.5
    return float2(radius, angle);
}
// ========================================
// 基础随机函数
// ========================================

// 基础随机函数 - 来自EffectTextureMaker
float rand(float2 uv)
{
    const float a = 12.9898, b = 78.233, c = 43758.5453;
    float dt = dot(uv.xy, float2(a, b));
    float sn = fmod(dt, PI);
    return frac(sin(sn) * c);
}

// 2D随机函数
float rand2D(float2 p)
{
    return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453);
}

// 3D随机函数
float rand3D(float3 p)
{
    return frac(sin(dot(p, float3(12.9898, 78.233, 37.719))) * 43758.5453);
}

// ========================================
// 基础噪声函数
// ========================================

// TODO: 在这里添加基础噪声函数
// - noise2D()
// - noise3D()
// - smoothNoise()

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
