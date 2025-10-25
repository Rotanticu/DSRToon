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

#ifndef LOG2
#define LOG2 1.442695
#endif

#ifndef EPSILON
#define EPSILON 1e-6
#endif

// ========================================
// 基础数学函数
// ========================================

// 幂函数
// 计算x的平方
float pow2(float x)
{ return x * x; }
// 计算x的立方
float pow3(float x)
{ return x * x * x; }
// 计算x的四次方
float pow4(float x)
{ float x2 = x * x; return x2 * x2; }
// 计算x的五次方
float pow5(float x)
{ float x2 = x * x; return x2 * x2 * x; }
// 计算向量的平方长度
float lengthSqr(float2 p) 
{ 
    return dot(p,p); 
}
// 计算RGB颜色的亮度平均值
float average(float3 color)
{ return dot(color, float3(0.3333, 0.3333, 0.3333)); }

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

// 基础随机函数
// 1D随机数生成器，返回[0,1]范围的值
float simpleRand(float x) 
{
  return frac(sin(x) * 4358.5453123);
}
// 1D随机数生成器（余弦版本），返回[0,1]范围的值
float simpleRand2(float n) 
{
  return frac(cos(n*89.42) * 343.32);
}
// 高质量2D随机数生成器
// 期望输入值在[0,1]x[0,1]范围内，返回[0,1]范围的值
// 不要合并为单个函数，参考: http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0/
float rand(float2 uv) 
{
  float a = 12.9898, b = 78.233, c = 43758.5453;
  float dt = dot(uv.xy, float2(a,b)), sn = fmod(dt, PI);
  return frac(sin(sn) * c);
}
// 另一种2D随机数生成器
float rand2(float2 p) 
{ 
    return frac(sin(frac(sin(p.x) * 43.13311) + p.y) * 31.0011); 
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


// 余弦插值函数
// 在a和b之间进行余弦插值
float cosine(float a, float b, float x) 
{
  float f = (1.0 - cos(x * PI)) * 0.5;
  return a * (1.0 - f) + b * f;
}

// 双线性余弦插值
// 在四个角点之间进行双线性余弦插值
float bicosine(float tl, float tr, float bl, float br, float x, float y) 
{
  return cosine(cosine(tl,tr,x), cosine(bl,br,x), y);
}



// 双线性插值
// 在四个角点之间进行双线性插值
float bilinear(float tl, float tr, float bl, float br, float x, float y) 
{
  return lerp(lerp(tl,tr,x), lerp(bl,br,x), y);
}

// 三次插值函数（smoothstep）
// 在a和b之间进行三次插值，提供平滑过渡
float cubic(float a, float b, float x)
{
  float f = x*x*(3.0 - 2.0*x); // 3x^2 + 2x
  return a * (1.0 - f) + b * f;
}

// 双三次插值
// 在四个角点之间进行双三次插值
float bicubic(float tl, float tr, float bl, float br, float x, float y)
{
  return cubic(cubic(tl,tr,x), cubic(bl,br,x), y);
}

// 五次插值函数
// 在a和b之间进行五次插值，提供更平滑的过渡
float quintic(float a, float b, float x)
{
  float f = x*x*x*(x*(x*6.0 - 15.0)+10.0); // 6x^5 - 15x^4 + 10x^3
  return a * (1.0 - f) + b * f;
}

// 双五次插值
// 在四个角点之间进行双五次插值
float biquintic(float tl, float tr, float bl, float br, float x, float y)
{
  return quintic(quintic(tl,tr,x), quintic(bl,br,x), y);
}

// 双线性混合
// 在四个角点之间进行双线性混合（使用mix函数）
float bimix(float tl, float tr, float bl, float br, float x, float y)
{
  return lerp(lerp(tl,tr,x), lerp(bl,br,x), y);
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

// 方向向量变换
// 使用变换矩阵变换方向向量（不包含位移）
float3 transformDirection(float3 dir, float4x4 directionMatrix)
{
  return normalize(mul(directionMatrix, float4(dir, 0.0)).xyz);
}

// 逆方向向量变换
// 使用逆变换矩阵变换方向向量（不包含位移）
// http://en.wikibooks.org/wiki/GLSL_Programming/Applying_Matrix_Transformations
float3 inverseTransformDirection(float3 dir, float4x4 directionMatrix)
{
  return normalize(mul(float4(dir, 0.0), directionMatrix).xyz);
}

// 点在平面上的投影
// 将点投影到指定平面上
float3 projectOnPlane(float3 pos, float3 pointOnPlane, float3 planeNormal)
{
  float distance = dot(planeNormal, pos - pointOnPlane);
  return -distance * planeNormal + pos;
}

// 判断点在平面的哪一侧
// 返回1表示在法向量指向的一侧，-1表示在另一侧，0表示在平面上
float sideOfPlane(float3 pos, float3 pointOnPlane, float3 planeNormal)
{
  return sign(dot(pos - pointOnPlane, planeNormal));
}

// 直线与平面的交点
// 计算直线与平面的交点坐标
float3 linePlaneIntersect(float3 pointOnLine, float3 lineDirection, float3 pointOnPlane, float3 planeNormal)
{
  return lineDirection * (dot(planeNormal, pointOnPlane - pointOnLine) / dot(planeNormal, lineDirection)) + pointOnLine;
}

// ========================================
// 颜色函数
// ========================================

// 伽马校正函数
// 将伽马空间颜色转换为线性空间颜色
float4 GammaToLinear(float4 value, float gammaFactor)
{
  return float4(pow(value.xyz, gammaFactor), value.w);
}
// 将线性空间颜色转换为伽马空间颜色
float4 LinearToGamma(float4 value, float gammaFactor)
{
  return float4(pow(value.xyz, 1.0/gammaFactor), value.w);
}
// ============================================================================
// 颜色空间转换函数
// ============================================================================

/**
 * RGB转灰度值
 * @param c RGB颜色值
 * @return 灰度值 (0-1)
 */
float rgb2gray(float3 c)
{
    return dot(c, float3(0.3, 0.59, 0.11));
}

/**
 * RGB转亮度值
 * @param c RGB颜色值
 * @return 亮度值 (0-1)
 */
float rgb2l(float3 c)
{
    float fmin = min(min(c.r, c.g), c.b);
    float fmax = max(max(c.r, c.g), c.b);
    return (fmax + fmin) * 0.5; // Luminance
}

/**
 * RGB转HSL颜色空间
 * 参考: https://github.com/liovch/GPUImage/blob/master/framework/Source/GPUImageColorBalanceFilter.m
 * @param c RGB颜色值 (0-1)
 * @return HSL颜色值 (H: 0-1, S: 0-1, L: 0-1)
 */
float3 rgb2hsl(float3 c)
{
    float3 hsl;
    float fmin = min(min(c.r, c.g), c.b);
    float fmax = max(max(c.r, c.g), c.b);
    float delta = fmax - fmin;

    hsl.z = (fmax + fmin) * 0.5; // Luminance

    if (delta == 0.0)
    {
        // 灰度色，无色相
        hsl.x = 0.0; // Hue
        hsl.y = 0.0; // Saturation
    }
    else
    {
        // 有色彩数据
        if (hsl.z < 0.5)
        {
            hsl.y = delta / (fmax + fmin); // Saturation
        }
        else
        {
            hsl.y = delta / (2.0 - fmax - fmin); // Saturation
        }

        float deltaR = (((fmax - c.r) / 6.0) + (delta / 2.0)) / delta;
        float deltaG = (((fmax - c.g) / 6.0) + (delta / 2.0)) / delta;
        float deltaB = (((fmax - c.b) / 6.0) + (delta / 2.0)) / delta;

        if (c.r == fmax)
        {
            hsl.x = deltaB - deltaG; // Hue
        }
        else if (c.g == fmax)
        {
            hsl.x = (1.0 / 3.0) + deltaR - deltaB; // Hue
        }
        else if (c.b == fmax)
        {
            hsl.x = (2.0 / 3.0) + deltaG - deltaR; // Hue
        }

        if (hsl.x < 0.0)
        {
            hsl.x += 1.0; // Hue
        }
        else if (hsl.x > 1.0)
        {
            hsl.x -= 1.0; // Hue
        }
    }
    return hsl;
}

/**
 * HSL色相转RGB辅助函数
 * @param f1 第一个辅助值
 * @param f2 第二个辅助值
 * @param hue 色相值 (0-1)
 * @return RGB分量值
 */
float hue2rgb(float f1, float f2, float hue)
{
    if (hue < 0.0)
    {
        hue += 1.0;
    }
    else if (hue > 1.0)
    {
        hue -= 1.0;
    }
    
    float res;
    if ((6.0 * hue) < 1.0)
    {
        res = f1 + (f2 - f1) * 6.0 * hue;
    }
    else if ((2.0 * hue) < 1.0)
    {
        res = f2;
    }
    else if ((3.0 * hue) < 2.0)
    {
        res = f1 + (f2 - f1) * ((2.0 / 3.0) - hue) * 6.0;
    }
    else
    {
        res = f1;
    }
    return res;
}

/**
 * HSL转RGB颜色空间
 * @param hsl HSL颜色值 (H: 0-1, S: 0-1, L: 0-1)
 * @return RGB颜色值 (0-1)
 */
float3 hsl2rgb(float3 hsl)
{
    float3 rgb;
    if (hsl.y == 0.0)
    {
        rgb = hsl.z; // Luminance
    }
    else
    {
        float f2;
        if (hsl.z < 0.5)
        {
            f2 = hsl.z * (1.0 + hsl.y);
        }
        else
        {
            f2 = (hsl.z + hsl.y) - (hsl.y * hsl.z);
        }
        float f1 = 2.0 * hsl.z - f2;
        rgb.r = hue2rgb(f1, f2, hsl.x + (1.0 / 3.0));
        rgb.g = hue2rgb(f1, f2, hsl.x);
        rgb.b = hue2rgb(f1, f2, hsl.x - (1.0 / 3.0));
    }
    return rgb;
}

/**
 * HSV转RGB颜色空间
 * @param c HSV颜色值 (H: 0-1, S: 0-1, V: 0-1)
 * @return RGB颜色值 (0-1)
 */
float3 hsv2rgb(float3 c)
{
    float4 K = float4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    float3 p = abs(frac(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * lerp(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

#endif // COMMON_INCLUDED
