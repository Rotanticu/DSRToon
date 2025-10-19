# Shader效果学习记录

> 记录Shader开发中的核心技巧和数学原理

---

## 📚 基础技巧汇总

### 🎯 UV中心点处理
**原理**: HLSL的UV是从左下角开始，范围 `[0,1]`  
**用途**: 做中心对称效果

```hlsl
float2 center = float2(0.5, 0.5);  // 可以改成其他坐标，那就是以这个坐标为中心
float2 position = 2 * (uv - center);  // (0~1 - 0.5) * 2 = (-1~1)
```

### ⭕ 圆形效果
**原理**: 到坐标的距离就是个渐变的圆形

```hlsl
length(IN.uv - 0.5)
```

### 🔘 环形效果
**原理**: 圆形的输出作为sin的输入就是环形效果  
**参数**: `_Frequency` 决定环的数量

```hlsl
sin(length(IN.uv - 0.5) * _Frequency)
```

---

## 🧮 极坐标系统

### 📐 坐标转换
**原理**: 把平面坐标系的 `(x,y)` 转为角度和长度

| 输入 | 输出 | 范围 |
|------|------|------|
| `x,y` | `(0,1)` | `radius(0~√0.5), angle(-PI~PI)` |
| `splar.x` | `radius = length(uv)` | `(0~√0.5)` |
| `splar.y` | `angle = atan2(uv - center)` | `(-PI~PI)` |

### 🔄 角度归一化
**我的 `UVToPolar` 函数做了归一化**:
```hlsl
angle / 2 * PI  // 结果范围: (-0.5~0.5)
```

**如果需要角度制**:
- `angle * PI` → `(-PI~PI)`
- `angle * PI2` → `(-2PI~2PI)`

---

## 🎨 视觉效果实现

### ✨ 放射效果
**原理**: 极坐标的角度作为sin的输入就是放射效果  
**参数**: `_Frequency` 决定放射数量（最好限制为整数，否则会有跳变）

```hlsl
sin((splar.y) * PI2 * _Frequency)
// 注意: angle需要以-PI~PI的范围，否则会有跳变
// 如果已经是角度制就不需要乘PI2
```

### 🌸 花瓣效果
**原理**: 在放射效果的基础上对 `_Frequency` 做 `floor`，通过距离函数创建花瓣边界  
**特点**: `_Radius` 在sin外面，只决定长度不决定数量

```hlsl
float t = abs(sin((splar.y) * PI * floor(_Petals)) * _Radius);
t = _Intensity / abs(t - splar.x);
```

### 🌸 波浪环效果
**原理**: 在花瓣效果的基础加一个`_CenterOffset`，就能改变收敛的位置变成环 
**特点**: `_CenterOffset` 在sin外面，决定收敛位置

```hlsl
float t = abs(sin((splar.y) * PI * floor(_Petals)) * _Radius);
t = _Intensity / abs(t - splar.x + _CenterOffset);
```

### 🌪️ 螺旋效果
**原理**: 花瓣效果的基础上减去极坐标的长度，就能变成螺旋效果

```hlsl
float t = abs(sin((splar.y) * PI * floor(_Petals) - splar.x) * _Radius);
t = _Intensity / abs(t - splar.x);
```

### ⭐ 十字星效果
**原理**: 使用`min`函数创建尖角，通过距离函数控制星形边界  
**特点**: `min(abs(x), abs(y))` 产生真正的尖角，不是圆角

```hlsl
float star = min(abs(position.x), abs(position.y)) * _Radius;
float t = _Intensity / abs(star - polar.x);
```

## 噪声

### RandomNoise 
类型: 纯随机噪声
特点: 每个点完全随机，无连续性
用途: 生成颗粒感、噪点、杂乱效果
**原理**:先让uv点乘一个特定的flaot2,再和PI取余数，结果丢进sin再乘c取小数点后的值 范围0~1
https://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0/
写成多行可以不让精度溢出效果更好
```hlsl
const float a = 12.9898, b = 78.233, c = 43758.5453;
float dt = dot(uv.xy, float2(a, b));
float sn = fmod(dt, PI);
return frac(sin(sn) * c);
```
### CELLNOISE - 单元噪声
**类型:** 基于网格的噪声
**特点:** 在每个网格单元内返回恒定值
**用途:** 生成砖块纹理、网格效果、随机色块

### BOOLEANNOISE - 布尔噪声
**类型:** 二值噪声
**特点:** 只有0和1两个值，产生黑白效果
**用途:** 创建图案、掩码、点状效果

### COHERENTNOISE - 相干噪声
**类型:** 基础噪声，基于Perlin/Value噪声
**特点:** 连续平滑的噪声，相邻点之间有关联性
**用途:** 生成平滑的自然纹理，如云、烟雾、地形

### PERLINNOISE - Perlin噪声（经典噪声）
**类型:** 梯度噪声的经典实现
**特点:** 由Ken Perlin在1983年发明的经典噪声算法，使用梯度向量和平滑插值
**用途:** 自然地形生成 云层、烟雾效果 程序化纹理生成 几乎是所有程序化生成的基础
### GRADIENTNOISE - 梯度噪声
**类型:** 基于梯度向量的噪声
**特点:** 使用梯度向量插值，比Value噪声更自然
**用途:** Perlin噪声的核心，自然纹理生成
### MARBLENOISE - 大理石噪声
**类型:** 基于Perlin噪声的变形效果
**特点:** 通过对噪声进行正弦变换，产生大理石的条纹效果
**用途:** 大理石纹理 木纹效果 波纹、条纹图案 液体流动效果

### TESSNOISE - 棋盘噪声
**类型:** 规则图案噪声
**特点:** 产生棋盘格或镶嵌图案
**用途:** 地板纹理、图案设计

### VORONOINOISE - Voronoi噪声
**类型:** 基于特征点距离的噪声
**特点:** 产生类似细胞、裂纹的图案
**用途:** 石头纹理、细胞结构、破碎效果、水面

### FBMNOISE - FBM噪声 FBM噪声2 FBM噪声3
**类型:** 多层叠加噪声
**特点:** 通过叠加多个不同频率和振幅的噪声
**用途:** 复杂的自然纹理（云、地形、木纹、大理石）

### TURBULENTNOISE - 湍流噪声
**类型:** 对噪声取绝对值后叠加
**特点:** 产生类似湍流、火焰的锐利效果
**用途:** 火焰、闪电、能量效果、大理石纹理
### SPARKNOISE - 火花噪声
**类型:** 特殊效果噪声
**特点:** 产生闪烁、火花的效果
**用途:** 粒子效果、火花、星星、魔法效果
### SEAMLESSNOISE - 无缝噪声
**类型:** 可平铺的噪声
**特点:** 边缘可以无缝连接，适合循环纹理
**用途:** 游戏中的平铺纹理、背景

