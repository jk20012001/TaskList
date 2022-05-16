# Surface Shader

Surface Shader是一种使用统一渲染流程的结构，可以让用户以简洁的代码创建材质信息，组合光照和着色模型。相比Legacy的Shader更易书写和维护，有更好的版本兼容性，也更不容易产生渲染错误，并且可以从统一流程中获取很多公共特性，如Debug View功能等。未来还会支持Shader Graph自动生成代码。

Surface Shader仍然是基于[Cocos Effect的语法](effect-syntax.md)，以前的材质参数、technique、pass及渲染状态等的定义完全可以复用。

> **注意**：推荐使用 Visual Studio Code 编写 Cocos Effect，并在应用商店中安装 Cocos Effect 扩展，提供编写时的语法高亮提示。

## 代码框架

除了和Cocos Effect相同的CCEffect参数、technique和UBO内存布局等定义之外，**Surface Shader** 代码通常由三个部分组成：

- `Macro Remapping`：将用户在Effect中声明或使用的宏名（部分）映射为Surface内部宏名。
- `Surface Functions`：用于声明材质相关的Surface函数。
- `Include Assembly`：用于组装每个顶点着色器（Vertex Shader）和片元着色器（Fragment Shader）的代码模块。

此处以内置着色器 `surfaces/standard.effect` 为例，说明 Surface Shader 的代码框架。



### Macro Remapping

Surface Shader内部计算时会用到一些宏开关，需要根据Effect中对应含义的宏名来指定。考虑到Effect中的宏名会直接显示在材质面板上，这样做的好处是Effect中的名称可以自由开放给用户而不影响Surface内部计算。

这些宏以CC_SURFACES_开头，以下是完整的宏列表：

| 宏名                                                  | 含义                                                         |
| ----------------------------------------------------- | ------------------------------------------------------------ |
| CC_SURFACES_USE_VERTEX_COLOR                          | 是否使用顶点色                                               |
| CC_SURFACES_USE_SECOND_UV                             | 是否使用2uv                                                  |
| CC_SURFACES_USE_TWO_SIDED                             | 是否使用双面法线                                             |
| CC_SURFACES_USE_TANGENT_SPACE                         | 是否使用切空间（使用法线图或各向异性时必须开启）             |
| CC_SURFACES_LIGHTING_ANISOTROPIC                      | 是否开启各向异性材质                                         |
| CC_SURFACES_LIGHTING_ANISOTROPIC_ENVCONVOLUTION_COUNT | 各向异性环境光卷积采样数，为0表示关闭此计算，仅当各向异性开启时有效 |
| CC_SURFACES_USE_REFLECTION_DENOISE                    | 是否开启环境反射除噪                                         |
| CC_SURFACES_USE_LEGACY_COMPATIBLE_LIGHTING            | 是否开启legacy兼容光照模式，可使渲染效果和legacy/standard.effect完全一致，便于升级 |

找到CCProgram macro-remapping一段，可以看到内容有如下三部分组成：

```glsl
CCProgram macro-remapping %{
  // ui displayed macros not used in this effect file
  #pragma define-meta HAS_SECOND_UV
  #pragma define-meta USE_TWOSIDE
  #pragma define-meta USE_REFLECTION_DENOISE
  #define CC_SURFACES_USE_SECOND_UV HAS_SECOND_UV
  #define CC_SURFACES_USE_TWO_SIDED USE_TWOSIDE
  #define CC_SURFACES_USE_REFLECTION_DENOISE USE_REFLECTION_DENOISE

  // if disabled, simulate convoluted IBL without convolution
  #pragma define-meta USE_COMPATIBLE_LIGHTING
  #define CC_SURFACES_USE_LEGACY_COMPATIBLE_LIGHTING USE_COMPATIBLE_LIGHTING

  // ui displayed macros used in this effect file
  #pragma define-meta IS_ANISOTROPY
  #define CC_SURFACES_LIGHTING_ANISOTROPIC IS_ANISOTROPY
#if IS_ANISOTROPY || USE_NORMAL_MAP
  #define CC_SURFACES_USE_TANGENT_SPACE 1
#endif
  #define CC_SURFACES_USE_VERTEX_COLOR USE_VERTEX_COLOR
  
  #define CC_SURFACES_LIGHTING_ANISOTROPIC_ENVCONVOLUTION_COUNT 31
}%
```

#### 1、在Surface函数中未使用过的宏：

  ```glsl
  // ui displayed macros not used in this effect file
  #pragma define-meta HAS_SECOND_UV
  #pragma define-meta USE_TWOSIDE
  #pragma define-meta USE_REFLECTION_DENOISE
  #pragma define-meta IS_ANISOTROPY
  #pragma define-meta USE_COMPATIBLE_LIGHTING
      
  #define CC_SURFACES_USE_SECOND_UV HAS_SECOND_UV
  #define CC_SURFACES_USE_TWO_SIDED USE_TWOSIDE
  #define CC_SURFACES_USE_REFLECTION_DENOISE USE_REFLECTION_DENOISE
  #define CC_SURFACES_LIGHTING_ANISOTROPIC IS_ANISOTROPY
  #define CC_SURFACES_USE_LEGACY_COMPATIBLE_LIGHTING USE_COMPATIBLE_LIGHTING   
  ```
由于Surface Shader精简了很多不必要的公共流程代码，如VS FS传参的定义等等，之前存在于旧流程中的*~~#if HAS_SECOND_UV~~*这样的代码也就不存在了。对于此类宏，必须要在此处预先定义**#pragma define-meta MACRONAME**，这样才可以显示在材质面板上。
定义好之后，下一行就可以使用标准GLSL预定义**#define CC_SURFACES_MACRONAME MACRONAME**

#### 2、在Surface函数中使用过的宏：

  ```glsl
// ui displayed macros used in this effect file
#define CC_SURFACES_USE_VERTEX_COLOR USE_VERTEX_COLOR
#if IS_ANISOTROPY || USE_NORMAL_MAP
  #define CC_SURFACES_USE_TANGENT_SPACE 1
#endif
  ```

这部分简单多了，直接按照**#define CC_SURFACES_MACRONAME MACRONAME**定义即可。
不过CC_SURFACES_USE_TANGENT_SPACE宏要特别注意，通常开了法线贴图或各向异性，都要开启该宏，否则可能会出现编译错误。

3、内部功能性的宏：

  ```glsl
// functionality for each effect
#define CC_SURFACES_LIGHTING_ANISOTROPIC_ENVCONVOLUTION_COUNT 31
  ```

直接定义想要的值即可。

当然，以上这些宏也都可以直接定义为0或其他值，表示在此Effect中强制关闭或打开，禁止用户调节。

### Surface Function

材质函数的功能类似于UnrealEngine中输出一个材质参数到指定的材质节点。使用 `CCProgram` 来定义Surface材质函数，**注意VS和FS使用的函数块必须分开存放**。通常来讲所有的VS和所有的FS各使用一个即可，在我们的例子中standard-vs和shadow-caster-vs共用surface-vertex块，而standard-fs和shadow-caster-fs共用surface-fragment块。这样做的好处是所有的用户自定义动画与材质可以在各种渲染用途中维持统一。

**这些函数并不是必须定义的**，Surface Shader在内部提供了一个简单的默认函数，**如果你想重载它，需要预定义每个函数对应的宏来完成**。如：

  ```glsl
#define CC_SURFACES_VERTEX_MODIFY_WORLD_POS
vec3 SurfacesVertexModifyWorldPos(in SurfacesStandardVertexIntermediate In)
{
  vec3 worldPos = In.worldPos;
  worldPos.x += sin(cc_time.x * worldPos.z);
  worldPos.y += cos(cc_time.x * worldPos.z);
  return worldPos;
}
  ```

预先定义CC_SURFACES_VERTEX_MODIFY_WORLD_POS宏，可以忽略掉内部默认函数，让Surface Shader使用你定义的函数来计算材质参数。

VS对应的函数列表如下：

| 对应宏 | 函数定义 |
| ------ | -------- |
|        |          |
|        |          |
|        |          |



```glsl
CCProgram shader-name %{
  <required: precision settings>
  <optional: include>  
  <optional: ubo>
  <optional: custom attribute>
  <optional: >
  vec4 entry(){
    // 需要返回一个 vec4 类型数据
  }
}%
```

### Include Assembly

通过预处理宏，可在 Cocos Effect 编译时控制代码分支和组合，以实现高效便捷的 Shader 代码管理。

更多详细内容请参考：

- [预处理宏定义](macros.md)
- [GLSL 语法](glsl.md)

## CCVertInput[^1]

- 为对接骨骼动画与数据解压流程，我们提供了 `CCVertInput` 工具函数，它有 `general` 和 `standard` 两个版本，内容如下：

  ```glsl
  // 位于 ‘input.chunk’ 的通用顶点着色器输入
  #define CCVertInput(position) \
    CCDecode(position);         \
    #if CC_USE_MORPH            \
      applyMorph(position);     \
    #endif                      \
    #if CC_USE_SKINNING         \
      CCSkin(position);         \
    #endif                      \
    #pragma // 空 ‘pragma’ 技巧，在编译时消除尾随分号
  
  // 位于 ‘input-standard.chunk’ 的标准顶点着色器输入
  #define CCVertInput(In) \
    CCDecode(In);         \
    #if CC_USE_MORPH      \
      applyMorph(In);     \
    #endif                \
    #if CC_USE_SKINNING   \
      CCSkin(In);         \
    #endif                \
    #pragma // 空 ‘pragma’ 技巧，在编译时消除尾随分号

  ```

- 如果只需要获取 **顶点位置信息**，可以使用 **general** 版本，那么顶点着色器函数开头的代码示例如下：

  ```glsl
  #include <input>
  vec4 vert () {
    vec3 position;
    CCVertInput(position);
    // ... 对位置信息做自定义操作
  }
  ```

  如果还需要法线等信息，可使用 `standard` 版本，像下面这样写：

  ```glsl
  #include <input-standard>
  vec4 vert () {
    StandardVertInput In;
    CCVertInput(In);
    // ... 此时 ‘In.position’ 初始化完毕，并且可以在顶点着色器中使用
  }
  ```

上面的示例代码中，`StandardVertInput` 对象 `In` 会返回模型空间的顶点位置（`position`）、法线（`normal`）和切空间（`tangent`）信息，并对骨骼动画模型做完蒙皮计算。

`StandardVertInput` 结构体的定义如下：

```glsl
struct StandardVertInput {
  highp vec4 position;
  vec3 normal;
  vec4 tangent;
};
```

> **注意**：引用头文件后，不要在 Shader 内重复声明这些 attributes（`a_position`、`a_normal`、`a_tangent` 等）。对于其他顶点数据（如 uv 等）还是需要声明 attributes 后再使用。

如果要对接引擎动态 Mesh 合批和几何体实例化（GPU Instancing），需要包含 `cc-local-batch` 头文件，通过 `CCGetWorldMatrix` 工具函数获取世界矩阵，示例如下：

```glsl
mat4 matWorld;
CCGetWorldMatrix(matWorld);

mat4 matWorld, matWorldIT;
CCGetWorldMatrixFull(matWorld, matWorldIT);
```

更多关于 Cocos Effect 内置的 uniform 内容，请参考 [Cocos Effect 内置 Uniform](uniform.md)。

## CCFragOutput

Cocos Effect 提供了 `CCFragOutput` 工具函数用以简化片元着色器的输出，可用于直接返回片元着色器所需要的值，代码示例如下：

```glsl
#include <output>
vec4 frag () {
  vec4 o = vec4(0.0);
  // ... 编写片元着实代码
  return CCFragOutput(o);
}
```

`CCFragOutput` 会根据管线状态来决定是否需要做 `ToneMap` 转码处理，这样中间的颜色计算就不必区分当前渲染管线是否为 HDR 流程。

代码示例如下：

```glsl
vec4 CCFragOutput (vec4 color) {
  #if CC_USE_HDR
    color.rgb = ACESToneMap(color.rgb);
  #endif
  color.rgb = LinearToSRGB(color.rgb);
  return color;
}
```

**特别注意**：

如果采用 `CCFragOutput` 作为片元输出，中间的颜色运算必须转到 `Linear` 空间，因为 `CCFragOutput` 认为传入的参数是在 `Linear` 空间的，总是会进行 `LinearToSRGB` 转码。

`CCFragOutput` 函数一般不需要自己实现，它只起到与渲染管线对接的作用，且对于这种含有光照计算的输出，因为计算结果已经在 HDR 范围，所以应该包含 `output-standard` 而非 `output` 头文件。

如需包含标准的 PBR 光照计算，可使用 `StandardSurface` 结构体与函数 `CCStandardShadingBase` 一起构成 PBR 着色流程。

`StandardSurface` 结构体内容如下：

```glsl

struct StandardSurface {
  // albedo
  vec4 albedo;
  // these two need to be in the same coordinate system
  vec3 position;
  vec3 normal;
  // emissive
  vec3 emissive;
  // light map
  vec3 lightmap;
  float lightmap_test;
  // PBR params
  float roughness;
  float metallic;
  float occlusion;
};
```

代码示例如下：

```glsl
#include <shading-standard-base>
#include <output-standard>
void surf (out StandardSurface s) {
  // fill in your data here
}
vec4 frag () {
  StandardSurface s; surf(s);
  vec4 color = CCStandardShadingBase(s);
  return CCFragOutput(color);
}
```

也可以参考 `bultin-standard.effect` 中，使用 `surf` 函数与 `CC_STANDARD_SURFACE_ENTRY()` 宏组合。

`CC_STANDARD_SURFACE_ENTRY()` 是一个 wrapper，会根据渲染状态，利用 `surf` 函数构建出一个可用于片元的 `main` 函数，代码示例如下：

```glsl
CCProgram shader-fs %{
  #include <standard-surface-entry>

  void surf (out StandardSurface s) {
    // fill in your data here
  }

  CC_STANDARD_SURFACE_ENTRY()
}%
```

## 自定义几何体实例化属性

通过 **几何体实例化** 特性（GPU Geomerty Instancing）可使 GPU 批量绘制模型相同且材质相同的渲染对象。如果我们想在不打破这一特性的情况下单独修改某个对象的显示效果，就需要通过自定义几何体实例化属性。

实例化属性相关的变量声明、定义、使用，都需要依赖 `USE_INSTANCING` 预处理宏定义，否则在切换 `USE_INSTANCING` 开关时会发生编译错误。代码示例如下：

```glsl
#if USE_INSTANCING // when instancing is enabled
  #pragma format(RGBA8) // normalized unsigned byte
  in vec4 a_instanced_color;
#endif
```

> **注意**：
>- 这里的 `format` 用于指定此属性的具体数据格式，参数可以为引擎 `GFXFormat` 中的任意枚举名[^2]；如未声明则默认为 32 位 >float 类型。
>- 所有实例化属性都是从利用顶点着色器（vs）的 attribute 输入，如果要在片元着色器（fs）中使用，需要先在 vs 中声明，再传递给 fs。
>- 请确保代码在所有分支都能正常执行，无论 `USE_INSTANCING` 是否启用。

实例化属性的值在运行时会初始化为 0，可在脚本中通过 `MeshRenderer.setInstancedAttribute` 接口进行设置，示例代码如下：

```ts
const comp = node.getComponent(MeshRenderer);
comp.setInstancedAttribute('a_instanced_color', [100, 150, 200, 255]); // should match the specified format
```

> **注意**：如果在 **MeshRenderer** 组件上更换了材质，那么所有的实例化属性值都会被重置，需要重新设置。

## WebGL 1.0 向下兼容支持

由于 WebGL 1.0 仅支持 GLSL 100 标准语法，因此在 Cocos Effect 编译时会提供 GLSL 300 ES 转 GLSL 100 的向下兼容代码（fallback shader），开发者基本不需关心这层变化。

需要注意的是目前的自动向下兼容策略仅支持一些基本的格式转换，如果使用了 GLSL 300 ES 独有的函数（例如 `texelFetch`、`textureGrad`）或一些特有的扩展（`extensions`），推荐根据 `__VERSION__` 宏定义判断 GLSL 版本，自行实现更稳定精确的向下兼容，代码示例如下：

```glsl
#if __VERSION__ < 300
#ifdef GL_EXT_shader_texture_lod
  vec4 color = textureCubeLodEXT(envmap, R, roughness);
#else
  vec4 color = textureCube(envmap, R);
#endif
#else
  vec4 color = textureLod(envmap, R, roughness);
#endif
```

Cocos Effect 在编译时会解析所有已经是常量的宏控制流，生成不同版本的 GLSL Shader 代码。

## 关于 UBO 内存布局

Cocos Effect 规定，所有非 sampler 类型的 uniform 都应以 UBO（Uniform Buffer Object/Uniform Block）形式声明。

以内置着色器 `builtin-standard.effect` 为例，其 uniform block 声明如下：

```glsl
uniform Constants {
    vec4 tilingOffset;
    vec4 albedo;
    vec4 albedoScaleAndCutoff;
    vec4 pbrParams;
    vec4 miscParams;
    vec4 emissive;
    vec4 emissiveScaleParam;
  };
```

并且所有的 UBO 应当遵守以下规则：
1. 不应出现 vec3 成员；
2. 对数组类型成员，每个元素 size 不能小于 vec4；
3. 不允许任何会引入 padding 的成员声明顺序。

Cocos Effect 在编译时会对上述规则进行检查，以便在导入错误（implicit padding 相关）时及时提醒修改。

这可能听起来有些过分严格，但背后有非常务实的考量：<br>
首先，UBO 是渲染管线内要做到高效数据复用的唯一基本单位，离散声明已不是一个选项；<br>
其次，WebGL2 的 UBO 只支持 std140 布局，它遵守一套比较原始的 padding 规则[^3]：

- 所有 vec3 成员都会补齐至 vec4：

  ```glsl
  uniform ControversialType {
    vec3 v3_1; // offset 0, length 16 [IMPLICIT PADDING!]
  }; // total of 16 bytes
  ```

- 任意长度小于 vec4 类型的数组和结构体，都会将元素补齐至 vec4：

  ```glsl
  uniform ProblematicArrays {
    float f4_1[4]; // offset 0, stride 16, length 64 [IMPLICIT PADDING!]
  }; // total of 64 bytes
  ```

- 所有成员在 UBO 内的实际偏移都会按自身所占字节数对齐[^4]：

  ```glsl
  uniform IncorrectUBOOrder {
    float f1_1; // offset 0, length 4 (aligned to 4 bytes)
    vec2 v2; // offset 8, length 8 (aligned to 8 bytes) [IMPLICIT PADDING!]
    float f1_2; // offset 16, length 4 (aligned to 4 bytes)
  }; // total of 32 bytes
  
  uniform CorrectUBOOrder {
    float f1_1; // offset 0, length 4 (aligned to 4 bytes)
    float f1_2; // offset 4, length 4 (aligned to 4 bytes)
    vec2 v2; // offset 8, length 8 (aligned to 8 bytes)
  }; // total of 16 bytes
  ```

这意味着大量的空间浪费，且某些设备的驱动实现也并不完全符合此标准[^5]，因此目前 Cocos Effect 选择限制这部分功能的使用，以帮助排除一部分非常隐晦的运行时问题。

>**再次提醒：uniform 的类型与 inspector 的显示和运行时参数赋值时的程序接口可以不直接对应，通过 [property target](pass-parameter-list.md#Properties) 机制，可以独立编辑任意 uniform 的具体分量。**

[^1]: 不包含粒子、Sprite、后期效果等不基于 Mesh 渲染的 Shader。

[^2]: 注意 WebGL 1.0 平台下不支持整型 attributes，如项目需要发布到此平台，应使用默认浮点类型。

[^3]: [OpenGL 4.5, Section 7.6.2.2, page 137](http://www.opengl.org/registry/doc/glspec45.core.pdf#page=159)

[^4]: 注意在示例代码中，UBO IncorrectUBOOrder 的总长度为 32 字节，实际上这个数据到今天也依然是平台相关的，看起来是由于 GLSL 标准的疏忽，更多相关讨论可以参考 [这里](https://bugs.chromium.org/p/chromium/issues/detail?id=988988)。

[^5]: **Interface Block - OpenGL Wiki**：<https://www.khronos.org/opengl/wiki/Interface_Block_(GLSL)#Memory_layout>
