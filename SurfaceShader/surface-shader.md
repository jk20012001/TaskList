# Surface Shader

Surface Shader使用统一渲染流程和结构，可以让用户以简洁的代码创建表面材质信息，指定用于组合的光照和着色模型。相比Legacy的Shader优点是更易书写和维护，有更好的版本兼容性，也更不容易产生渲染错误。并且可以从统一流程中获取很多公共特性，如统一的全场景光照和Debug View调试功能等。
Creator也更易扩展出多种常见的复杂材质提供给用户，未来还会支持Shader Graph自动生成Effect代码，可以极大提高Shader开发者的效率。
但代价是无法定制光照和着色运算的具体内容，一旦指定了光照和着色模式，流程将按照既定路径来进行，不支持临时屏蔽或更改一些内部计算。如有这样的需求，请使用Legacy Shader。

Surface Shader仍然是基于[Cocos Effect的语法](effect-syntax.md)，以前的材质参数、technique、pass及渲染状态等的定义完全可以复用。

## 相关概念

这里有几个概念需要说明一下：渲染用途、材质模型和光照模型。

## 代码框架

除了和Cocos Effect相同的CCEffect参数、technique和UBO内存布局等定义之外，再也无需考虑各种内部宏定义的处理、着色器输入输出变量、Instancing[^1]、繁琐的顶点变换、全局像素效果和每种渲染用途的细节计算等。

典型的Surface Shader代码通常由三个部分组成：

- `Macro Remapping`：将用户在Effect中声明或使用的宏名（部分）映射为Surface内部宏名。
- `Surface Functions`：用于声明表面材质信息相关的Surface函数。
- `Include Assembly`：用于组装每个顶点着色器（Vertex Shader）和片元着色器（Fragment Shader）的代码模块。

此处以内置着色器 `surfaces/standard.effect` 为例，说明 Surface Shader 的代码框架。



### Macro Remapping

Surface Shader内部计算时会用到一些宏开关，需要根据Effect中对应含义的宏名来指定。考虑到Effect中的宏名会直接显示在材质面板上，这样做的好处是Effect中的名称可以自由开放给用户而不影响Surface内部计算。

这些宏以`CC_SURFACES_`开头，以下是完整的宏列表：

| 宏名                                                  | 类型 | 含义                                                         |
| :---------------------------------------------------- | ---- | ------------------------------------------------------------ |
| CC_SURFACES_USE_VERTEX_COLOR                          | BOOL | 是否使用顶点色                                               |
| CC_SURFACES_USE_SECOND_UV                             | BOOL | 是否使用2uv                                                  |
| CC_SURFACES_USE_TWO_SIDED                             | BOOL | 是否使用双面法线                                             |
| CC_SURFACES_USE_TANGENT_SPACE                         | BOOL | 是否使用切空间（使用法线图或各向异性时必须开启）             |
| CC_SURFACES_LIGHTING_ANISOTROPIC                      | BOOL | 是否开启各向异性材质                                         |
| CC_SURFACES_LIGHTING_ANISOTROPIC_ENVCONVOLUTION_COUNT | UINT | 各向异性环境光卷积采样数，为0表示关闭此计算，仅当各向异性开启时有效 |
| CC_SURFACES_USE_REFLECTION_DENOISE                    | BOOL | 是否开启环境反射除噪                                         |
| CC_SURFACES_USE_LEGACY_COMPATIBLE_LIGHTING            | BOOL | 是否开启legacy兼容光照模式，可使渲染效果和legacy/standard.effect完全一致，便于升级 |

搜索`CCProgram macro-remapping`一段，可以看到内容有如下三部分组成：

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
由于Surface Shader精简了很多不必要的公共流程代码，如VS FS传参的定义等等，之前存在于旧流程中的~~`#if HAS_SECOND_UV`~~这样的代码也就不存在了。对于此类宏，必须要在此处预先定义**`#pragma define-meta MACRONAME`**，这样才可以显示在材质面板上。
定义好之后，下一行就可以使用标准GLSL预定义**`#define CC_SURFACES_MACRONAME MACRONAME`**

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

#### 3、内部功能性的宏：

  ```glsl
// functionality for each effect
#define CC_SURFACES_LIGHTING_ANISOTROPIC_ENVCONVOLUTION_COUNT 31
  ```

直接定义想要的值即可。

当然，以上这些宏也都可以直接定义为0或其他值，表示在此Effect中强制关闭或打开，禁止用户调节。

### Surface Function

每个材质函数的功能类似于Unreal Engine中输出一个材质参数到指定的材质节点。使用 `CCProgram` 来定义Surface材质函数，**注意VS和FS使用的函数块必须分开存放**。通常来讲所有的VS和所有的FS各使用一个即可，在我们的例子中`standard-vs`和`shadow-caster-vs`共用`surface-vertex`块，而`standard-fs`和`shadow-caster-fs`共用`surface-fragment`块。这样做的好处是所有的用户自定义动画与材质可以在各种渲染用途中维持统一。

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

预先定义`CC_SURFACES_VERTEX_MODIFY_WORLD_POS`宏，可以忽略掉内部默认函数，让Surface Shader使用你定义的函数来计算材质参数。

>用这种方式的好处是方便扩展多种不同的材质模型和代码版本升级，新版增加的函数可以用新的名称和参数，仍然可以调用旧版定义的函数获取计算结果，无需写重复代码，也不用担心升级后编译报错。

VS对应的函数列表如下：

| 预先定义宏 | 对应的渲染用途 | 对应的函数定义 |
| ---------- | -------------- | -------------- |
|            |                |                |
|            |                |                |
|            |                |                |

### Include Assembly



- 

## 进阶使用方法

可以在不同的Shader主函数中混用Surface Shader和Legacy Shader（要保证Varying顶点数据在两个阶段一致）



## 公共函数库[^1]

[^1]: 不支持自定义几何体实例化属性。

[^4]: 注意在示例代码中，UBO IncorrectUBOOrder 的总长度为 32 字节，实际上这个数据到今天也依然是平台相关的，看起来是由于 GLSL 标准的疏忽，更多相关讨论可以参考 [这里](https://bugs.chromium.org/p/chromium/issues/detail?id=988988)。
