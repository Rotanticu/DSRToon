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