#ifndef NOISE_LIBRARY_INCLUDED
#define NOISE_LIBRARY_INCLUDED

// ========================================
// 噪声库 - Noise Library
// ========================================
// 这是一个用于学习Shader噪声效果的代码库
// 包含各种噪声函数的实现和应用示例

// 包含通用数学库
#include "Common.hlsl"

#ifndef NOISE_OCTAVE_MAX
#define NOISE_OCTAVE_MAX 10
#endif

uniform int cNoiseOctave;
uniform float cNoiseFrequency;
//uniform float cNoiseAmplitude;
uniform float cNoisePersistence;
//uniform bool cNoiseGraphEnable;


// Value Noise 向量随机数生成器
// 由Inigo Quilez开发 - iq/2013
// https://www.shadertoy.com/view/lsf3WH
float2 vrand(float2 p)
{
  p = float2(dot(p,float2(127.1,311.7)), dot(p,float2(269.5,183.3)));
  return -1.0 + 2.0 * frac(sin(p)*43758.5453123);
}

// Value Noise 实现
// 生成渐变噪声，基于网格点的随机值插值
float vnoise(float2 p)
{
  float2 i = floor(p);
  float2 f = frac(p);
  float2 u = f*f*(3.0-2.0*f);
  return lerp(lerp(dot(vrand(i+float2(0.0,0.0)), f-float2(0.0,0.0)),
                 dot(vrand(i+float2(1.0,0.0)), f-float2(1.0,0.0)), u.x),
             lerp(dot(vrand(i+float2(0.0,1.0)), f-float2(0.0,1.0)),
                 dot(vrand(i+float2(1.0,1.0)), f-float2(1.0,1.0)), u.x), u.y);
}

// Perlin噪声插值
// 使用余弦插值生成Perlin噪声
float plerp(float2 p)
{
  float2 i = floor(p);
  float2 f = frac(p);
  return bicosine(rand(i+float2(0.0,0.0)),
                  rand(i+float2(1.0,0.0)),
                  rand(i+float2(0.0,1.0)),
                  rand(i+float2(1.0,1.0)), f.x, f.y);
//   float4 v = float4(rand(float2(i.x,       i.y)),
//                 rand(float2(i.x + 1.0, i.y)),
//                 rand(float2(i.x,       i.y + 1.0)),
//                 rand(float2(i.x + 1.0, i.y + 1.0)));
//   return cosine(cosine(v.x, v.y, f.x), cosine(v.z, v.w, f.x), f.y);
}

// 分形Perlin噪声
// 使用多个八度生成分形噪声
float pnoise(float2 p)
{
  float t = 0.0;
  for (int i=0; i<NOISE_OCTAVE_MAX; i++)
{
    if (i >= cNoiseOctave) break;
    float freq = pow(2.0, float(i));
    float amp = pow(cNoisePersistence, float(cNoiseOctave - i));
    t += plerp(float2(p.x / freq, p.y / freq)) * amp;
  }
  return t;
}

// 参数化Perlin噪声
// 可自定义八度数、频率和持续性的Perlin噪声
float pnoise(float2 p, int octave, float frequency, float persistence)
{
  float t = 0.0;
  float maxAmplitude = EPSILON;
  float amplitude = 1.0;
  for (int i=0; i<NOISE_OCTAVE_MAX; i++)
{
    if (i >= octave) break;
    t += plerp(p * frequency) * amplitude;
    frequency *= 2.0;
    maxAmplitude += amplitude;
    amplitude *= persistence;
  }
  return t / maxAmplitude;
}

// 脊状噪声
// 生成脊状效果的噪声，常用于地形生成
float rpnoise(float2 p, int octave, float frequency, float persistence)
{
  float t = 0.0;
  float maxAmplitude = EPSILON;
  float amplitude = 1.0;
  for (int i=0; i<NOISE_OCTAVE_MAX; i++)
{
    if (i >= octave) break;
    t += ((1.0 - abs(plerp(p * frequency))) * 2.0 - 1.0) * amplitude;
    frequency *= 2.0;
    maxAmplitude += amplitude;
    amplitude *= persistence;
  }
  return t / maxAmplitude;
}

// 分段噪声
// 在指定区域内进行噪声混合
float psnoise(float2 p, float2 q, float2 r)
{
  return pnoise(float2(p.x,       p.y      )) *        q.x  *        q.y +
         pnoise(float2(p.x,       p.y + r.y)) *        q.x  * (1.0 - q.y) +
         pnoise(float2(p.x + r.x, p.y      )) * (1.0 - q.x) *        q.y +
         pnoise(float2(p.x + r.x, p.y + r.y)) * (1.0 - q.x) * (1.0 - q.y);
}

// 伪随机数生成器
// PRNG (https://www.shadertoy.com/view/4djSRW)
float prng(float2 seed)
{
  seed = frac(seed * float2(5.3983, 5.4427));
  seed += dot(seed.yx, seed.xy + float2(21.5351, 14.3137));
  return frac(seed.x * seed.y * 95.4337);
}

// https://www.shadertoy.com/view/Xd23Dh
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// This is a procedural pattern that has 2 parameters, that generalizes cell-noise, 
// perlin-noise and voronoi, all of which can be written in terms of the former as:
//
// cellnoise(x) = pattern(0,0,x)
// perlin(x) = pattern(0,1,x)
// voronoi(x) = pattern(1,0,x)
//
// From this generalization of the three famouse patterns, a new one (which I call 
// \"Voronoise\") emerges naturally. It's like perlin noise a bit, but within a jittered 
// grid like voronoi):
//
// voronoise(x) = pattern(1,1,x)
//
// Not sure what one would use this generalization for, because it's slightly slower 
// than perlin or voronoise (and certainly much slower than cell noise), and in the 
// end as a shading TD you just want one or another depending of the type of visual 
// features you are looking for, I can't see a blending being needed in real life.  
// But well, if only for the math fun it was worth trying. And they say a bit of 
// mathturbation can be healthy anyway!
// Use the mouse to blend between different patterns:
// cell noise   u=0,v=0
// voronoi      u=1,v=0
// perlin noise u=0,v=1
// voronoise    u=1,v=1
// More info here: http://iquilezles.org/www/articles/voronoise/voronoise.htm
// psudo-random number generator
float iqhash(float2 p)
{
  float2 q = float2(dot(p, float2(127.1,311.7)), dot(p, float2(269.5,183.3)));
  return abs(frac(sin(q.x*q.y)*43758.5453123)-0.5)*2.0;
}
float2 iqhash2(float2 p)
{
  float2 q = float2(dot(p, float2(127.1,311.7)), dot(p, float2(269.5,183.3)));
  return -1.0 + 2.0 * frac(sin(q)*43758.5453123);
}


float3 iqhash3( float2 p )
{
  float3 q = float3(dot(p,float2(127.1,311.7)), 
                dot(p,float2(269.5,183.3)), 
                dot(p,float2(419.2,371.9)) );
  return frac(sin(q)*43758.5453);
}

float iqnoise( in float2 x, float u, float v )
{
  float2 p = floor(x);
  float2 f = frac(x);
  float k = 1.0+63.0*pow(1.0-v,4.0);
  float va = 0.0;
  float wt = 0.0;
  for( int j=-2; j<=2; j++ )
{
    for( int i=-2; i<=2; i++ )
{
      float2 g = float2( float(i),float(j) );
      float3 o = iqhash3( p + g )*float3(u,u,1.0);
      float2 r = g - f + o.xy;
      float d = dot(r,r);
      float ww = pow( 1.0-smoothstep(0.0,1.414,sqrt(d)), k );
      va += o.z*ww;
      wt += ww;
    }
  }
  return va/wt;
}

// https://www.shadertoy.com/view/MdX3Rr by inigo quilez
float2x2 iqfbmM = float2x2(0.8,-0.6,0.6,0.8);
float iqfbm( in float2 p )
{
  float f = 0.0;
  f += 0.5000*pnoise( p ); p = mul(iqfbmM, p*2.02);
  f += 0.2500*pnoise( p ); p = mul(iqfbmM, p*2.03);
  f += 0.1250*pnoise( p ); p = mul(iqfbmM, p*2.01);
  f += 0.0625*pnoise( p );
  return f/0.9375;
}


// simplex noise

float mod289(float x)
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float2 mod289(float2 x)
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float3 mod289(float3 x)
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float4 mod289(float4 x)
{
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

float permute(in float x)
{
  return mod289(((x*34.0)+1.0)*x);
}

float2 permute(in float2 x)
{
  return mod289(((x*34.0)+1.0)*x);
}

float3 permute(in float3 x)
{
  return mod289(((x*34.0)+1.0)*x);
}

float4 permute(in float4 x)
{
  return mod289(((x*34.0)+1.0)*x);
}

float4 taylorInvSqrt(in float4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

float snoise(in float2 v)
{
  const float4 C = float4(0.211324865405187, // (3.0-sqrt(3.0))/6.0
                      0.366025403784439, // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626, // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
// First corner
  float2 i = floor(v + dot(v, C.yy) );
  float2 x0 = v - i + dot(i, C.xx);

// Other corners
  float2 i1;
  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  //i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? float2(1.0, 0.0) : float2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  float4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

// Permutations
  i = mod289(i); // Avoid truncation effects in permutation
  float3 p = permute( permute( i.y + float3(0.0, i1.y, 1.0 ))
+ i.x + float3(0.0, i1.x, 1.0 ));

  float3 m = max(0.5 - float3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

// Gradients: 41 points uniformly over a line, mapped onto a diamond.
// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  float3 x = 2.0 * frac(p * C.www) - 1.0;
  float3 h = abs(x) - 0.5;
  float3 ox = floor(x + 0.5);
  float3 a0 = x - ox;

// Normalise gradients implicitly by scaling m
// Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

// Compute final noise value at P
  float3 g;
  g.x = a0.x * x0.x + h.x * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}


float snoise(float3 v)
{
const float2  C = float2(1.0/6.0, 1.0/3.0);
const float4  D = float4(0.0, 0.5, 1.0, 2.0);

// First corner
float3 i  = floor(v + dot(v, C.yyy) );
float3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
float3 g = step(x0.yzx, x0.xyz);
float3 l = 1.0 - g;
float3 i1 = min( g.xyz, l.zxy );
float3 i2 = max( g.xyz, l.zxy );

// x0 = x0 - 0.0 + 0.0 * C.xxx;
// float3 x1 = x0 - i1 + 1.0 * C.xxx;
// float3 x2 = x0 - i2 + 2.0 * C.xxx;
// float3 x3 = x0 - 1.0 + 3.0 * C.xxx;
float3 x1 = x0 - i1 + C.xxx;
float3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
float3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

// Permutations
    i = mod289(i); 
	float4 p = permute( permute( permute( 
           i.z + float4(0.0, i1.z, i2.z, 1.0 ))
         + i.y + float4(0.0, i1.y, i2.y, 1.0 )) 
         + i.x + float4(0.0, i1.x, i2.x, 1.0 ));

// Gradients: 7x7 points over a square, mapped onto an octahedron.
// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
float n_ = 0.142857142857; // 1.0/7.0
float3  ns = n_ * D.wyz - D.xzx;

float4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

float4 x_ = floor(j * ns.z);
float4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

float4 x = x_ *ns.x + ns.yyyy;
float4 y = y_ *ns.x + ns.yyyy;
float4 h = 1.0 - abs(x) - abs(y);

float4 b0 = float4( x.xy, y.xy );
float4 b1 = float4( x.zw, y.zw );

//float4 s0 = float4(lessThan(b0,0.0))*2.0 - 1.0;
//float4 s1 = float4(lessThan(b1,0.0))*2.0 - 1.0;
float4 s0 = floor(b0)*2.0 + 1.0;
float4 s1 = floor(b1)*2.0 + 1.0;
float4 sh = -step(h, float4(0.0, 0.0, 0.0, 0.0));

float4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
float4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

float3 p0 = float3(a0.xy,h.x);
float3 p1 = float3(a0.zw,h.y);
float3 p2 = float3(a1.xy,h.z);
float3 p3 = float3(a1.zw,h.w);

//Normalise gradients
float4 norm = taylorInvSqrt(float4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
p0 *= norm.x;
p1 *= norm.y;
p2 *= norm.z;
p3 *= norm.w;

// Mix final noise value
float4 m = max(0.6 - float4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), float4(0.0, 0.0, 0.0, 0.0));
m = m * m;
return 42.0 * dot( m*m, float4( dot(p0,x0), dot(p1,x1), dot(p2,x2), dot(p3,x3) ) );
}

// float4 grad4(float j, float4 ip)
//{
//   const float4 ones = float4(1.0, 1.0, 1.0, -1.0);
//   float4 p,s;
//   p.xyz = floor(frac(float3(j) * ip.xyz) * 7.0) * ip.z - 1.0;
//   p.w = 1.5 - dot(abs(p.xyz), ones.xyz);
//   s = float4(lessThan(p,float4(0.0)));
//   p.xyz = p.xyz + (s.xyz*2.0-1.0)*s.www;
//   return p;
// }

// float snoise(in float4 v)
//{
//   const float4 C = float4(0.138196601125011, // (5-sqrt(5))/20 G4
//                       0.276393202250021, // 2 * G4
//                       0.414589803375032, // 3 * G4
//                      -0.447213595499958); // -1 + 4 * G4

//   // First corner
//   float4 i = floor(v + dot(v, C.yyyy));
//   float4 x0 = v - i + dot(i, C.xxxx);

//   // Other corners

//   // Rank sorting originally contributed by Bill Licea-Kane, AMD (formerly ATI)
//   float4 i0;
//   float3 isX = step(x0.yzw, x0.xxx);
//   float3 isYZ = step(x0.zww, x0.yyz);
//   // i0.x = dot(isX, float3(1.0));
//   i0.x = isX.x + isX.y + isX.z;
//   i0.yzw = 1.0 - isX;
//   // i0.y += dot(isYZ.xy, float2(1.0));
//   i0.y += isYZ.x + isYZ.y;
//   i0.zw += 1.0 - isYZ.xy;
//   i0.z += isYZ.z;
//   i0.w += 1.0 - isYZ.z;

//   // i0 now contains the unique values 0,1,2,3 in each channel
//   float4 i3 = clamp(i0, 0.0, 1.0);
//   float4 i2 = clamp(i0-1.0, 0.0, 1.0);
//   float4 i1 = clamp(i0-2.0, 0.0, 1.0);

//   // x0 = x0 - 0.0 + 0.0 * C.xxxx
//   // x1 = x0 - i1 + 1.0 * C.xxxx
//   // x2 = x0 - i2 + 2.0 * C.xxxx
//   // x3 = x0 - i3 + 3.0 * C.xxxx
//   // x4 = x0 - 1.0 + 4.0 * C.xxxx
//   float4 x1 = x0 - i1 + C.xxxx;
//   float4 x2 = x0 - i2 + C.yyyy;
//   float4 x3 = x0 - i3 + C.zzzz;
//   float4 x4 = x0 + C.wwww;

//   // Permutations
//   i = mod289(i);
//   float j0 = permute(permute(permute(permute(i.w) + i.z) + i.y) + i.x);
//   float4 j1 = permute(permute(permute(permute(
//       i.w + float4(i1.w, i2.w, i3.w, 1.0))
//     + i.z + float4(i1.z, i2.z, i3.z, 1.0))
//     + i.y + float4(i1.y, i2.y, i3.y, 1.0))
//     + i.z + float4(i1.z, i2.z, i3.z, 1.0))
//   ))));

//   // Gradients: 7x7x6 points over a cube, mapped onto a 4-cross polytope
//   // 7x7x6 = 294, which is close to the ring size 17*17=289.
//   float4 ip = float4(1.0/294.0, 1.0/49.0, 1.0/7.0, 0.0);

//   float4 p0 = grad4(j0,   ip);
//   float4 p1 = grad4(j1.x, ip);
//   float4 p2 = grad4(j1.y, ip);
//   float4 p3 = grad4(j1.z, ip);
//   float4 p4 = grad4(j1.w, ip);

//   // Normalize gradients
//   float4 norm = taylorInvSqrt(float4(dot(p0,p0), dot(p1,p1), dot(p2,p2), dot(p3,p3)));
//   p0 *= norm.x;
//   p1 *= norm.y;
//   p2 *= norm.z;
//   p3 *= norm.w;
//   p4 *= taylorInvSqrt(dot(p4,p4));

//   // Mix contributions from the five corners
//   float3 m0 = max(0.6 - float3(dot(x0,x0), dot(x1,x1), dot(p2,x2)), 0.0);
//   float3 m1 = max(0.6 - float2(dot(x3,x3), dot(x4,x4)), 0.0);
//   m0 = m0*m0;
//   m1 = m1*m1;
//   return 49.0 * (dot(m0*m0), float3(dot(p0,x0), dot(p1,x1), dot(p2,x2))) + 
//     dot(m1*m1, float2(dot(p3,x3), dot(p4,x4)));
// }

// 缩放和偏移函数
// 对输入值进行缩放和偏移变换
float scaleShift(float x, float a, float b)
{ return x*a+b; }
float2 scaleShift(float2 x, float a, float b)
{ return x*a+b; }
float3 scaleShift(float3 x, float a, float b)
{ return x*a+b; }
// Hash函数族
// 1D哈希函数，返回[0,1]范围的值
float hash1(float x)
{
    return frac(sin(x)*12345.0);
}   
// 2D哈希函数，返回[0,1]范围的值
float hash1(float2 st)
{
    return frac(sin(dot(st.xy, float2(12.9898, 78.233)))*43758.5453123);
}
// 3D哈希函数，返回[0,1]范围的值
float hash1(float3 v)
{
    return frac(sin(dot(v.xyz ,float3(12.9898,78.233,144.7272))) * 43758.5453);
}
// 2D向量哈希函数，返回[0,1]范围的向量
float2 hash2(float2 st)
{
    st = float2(dot(st,float2(127.1,311.7)),
              dot(st,float2(269.5,183.3)));
    return frac(sin(st)*43758.5453123);
}
// 3D向量哈希函数，返回[0,1]范围的向量
float3 hash3(float3 st)
{
    st = float3(dot(st,float3(127.1,311.7,217.3)), 
              dot(st,float3(269.5,183.3,431.1)), 
              dot(st,float3(365.6,749.9,323.7)));
    return frac(sin(st)*43758.5453123);
}
// 随机数函数族（范围[-1,1]）
// 1D随机数，返回[-1,1]范围的值
float random1(float x)
{
    return scaleShift(hash1(x), 2.0, -1.0);
}
// 2D随机数，返回[-1,1]范围的值
float random1(float2 st)
{
    return scaleShift(hash1(st), 2.0, -1.0);
}
// 3D随机数，返回[-1,1]范围的值
float random1(float3 v)
{
    return scaleShift(hash1(v), 2.0, -1.0);
}
// 向量随机数函数族（范围[-1,1]）
// 2D向量随机数，返回[-1,1]范围的向量
float2 random2(float2 p)
{
    return scaleShift(hash2(p), 2.0, -1.0);
}
// 3D向量随机数，返回[-1,1]范围的向量
float3 random3(float3 v)
{
    return scaleShift(hash3(v), 2.0, -1.0);
}

#endif // NOISE_LIBRARY_INCLUDED
