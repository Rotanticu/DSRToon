#ifndef COMMON_INCLUDED
#define COMMON_INCLUDED

// ========================================
// 通用数学库 - Common Math Library
// ========================================
// 这是一个用于Shader开发的通用数学函数库
// 包含基础数学常量、工具函数和坐标转换

// ========================================
// 数学常量
// ========================================

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

// ========================================
// 基础数学函数
// ========================================

// 幂函数
float pow2(float x) { return x * x; }
float pow3(float x) { return x * x * x; }
float pow4(float x) { float x2 = x * x; return x2 * x2; }
float pow5(float x) { float x2 = x * x; return x2 * x2 * x; }

// 颜色工具
float average(float3 color) { return dot(color, float3(0.3333, 0.3333, 0.3333)); }

// ========================================
// 坐标转换函数
// ========================================

// UV转极坐标
float2 UVToPolar(float2 uv, float2 center) 
{ 
    float2 delta = uv - center;
    float radius = length(delta); // 0~√0.5
    float angle = atan2(delta.x, delta.y) * RECIPROCAL_PI2; // -0.5~0.5
    return float2(radius, angle);
}

// 极坐标转UV
float2 PolarToUV(float2 polar, float2 center)
{
    float radius = polar.x;
    float angle = polar.y * PI2; // 转换回弧度
    float2 delta = float2(sin(angle), cos(angle)) * radius;
    return center + delta;
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
// 插值函数
// ========================================

// 平滑插值 (smoothstep的改进版本)
float smoothstep3(float x)
{
    return x * x * (3.0 - 2.0 * x);
}

// 更平滑的插值
float smoothstep5(float x)
{
    return x * x * x * (x * (x * 6.0 - 15.0) + 10.0);
}

// ========================================
// 距离函数
// ========================================

// 欧几里得距离
float distance2D(float2 a, float2 b)
{
    return length(a - b);
}

// 曼哈顿距离
float manhattanDistance(float2 a, float2 b)
{
    float2 diff = abs(a - b);
    return diff.x + diff.y;
}

// 切比雪夫距离
float chebyshevDistance(float2 a, float2 b)
{
    float2 diff = abs(a - b);
    return max(diff.x, diff.y);
}

#endif // COMMON_INCLUDED
