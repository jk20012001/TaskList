# Surface Shader

Surface Shader使用统一渲染流程和结构，可以让用户以简洁的代码创建表面材质信息，指定用于组合的光照和着色模型。相比旧版（Legacy Shader）的优点是更易书写和维护，有更好的版本兼容性，也更不容易产生渲染错误。并且可以从统一流程中获取很多公共特性，如统一的全场景光照和Debug View调试功能等。
Creator也更易扩展出多种常见的复杂材质提供给用户，未来还会支持Shader Graph自动生成Effect代码，可以极大提高Shader开发者的效率。
但代价是无法定制光照和着色运算的具体内容，一旦指定了光照和着色模式，流程将按照既定路径来进行，不支持临时屏蔽或更改一些内部计算。如有这样的需求，请使用Legacy Shader。

Surface Shader仍然是基于[Cocos Effect的语法](effect-syntax.md)，以前的材质参数、technique、pass及渲染状态等的定义完全可以复用。

## 相关概念

这里有几个概念需要说明一下：

### 1、渲染用途

说明了物体需要被渲染到哪里。

我们有很多渲染Pass用于渲染同一个物体到不同的纹理数据上，这些数据分别有内置的用途。比如说最常用的`渲染到场景`可以直接用于屏幕显示，或者把阴影投射物`渲染到阴影贴图`，或者`渲染到动态环境反射`来生成反射贴图等。

### 2、光照模型

说明物体表面的微观结构与固有光学属性是如何对光线产生影响和作用的。
比如说塑料会产生各向同性的圆形高光，头发会产生各向异性的条纹状高光，光线在皮肤上会发生散射，而在镜子这种更接近理想光学表面的物体上，绝大多数光线只会沿着反射角发生反射等。

### 3、表面材质模型

说明物体表面的一些物理参数（反照率、粗糙度等）是如何影响光照结果的。

通常材质与光照模型必须关联使用，我们会逐渐扩展常用的材质与光照模型

## 代码框架

除了和Cocos Effect相同的CCEffect参数、technique和UBO内存布局等定义之外，再也无需考虑各种内部宏定义的处理、着色器输入输出变量、Instancing[^1]、繁琐的顶点变换、全局像素效果和每种渲染用途的细节计算等。

典型的Surface Shader代码通常由三个部分组成：

- `Macro Remapping`：将用户在Effect中声明或使用的宏名（部分）映射为Surface内部宏名。
- `Surface Functions`：用于声明表面材质信息相关的Surface函数。
- `Shader Assembly`：用于组装每个顶点着色器（Vertex Shader）和片元着色器（Fragment Shader）的代码模块。

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
| CC_SURFACES_TRANSFER_LOCAL_POS                        | BOOL | 是否在FS中访问模型空间坐标                                   |
| CC_SURFACES_LIGHTING_ANISOTROPIC                      | BOOL | 是否开启各向异性材质                                         |
| CC_SURFACES_LIGHTING_ANISOTROPIC_ENVCONVOLUTION_COUNT | UINT | 各向异性环境光卷积采样数，为0表示关闭卷积计算，仅当各向异性开启时有效 |
| CC_SURFACES_USE_REFLECTION_DENOISE                    | BOOL | 是否开启环境反射除噪                                         |
| CC_SURFACES_USE_LEGACY_COMPATIBLE_LIGHTING            | BOOL | 是否开启legacy兼容光照模式，可使渲染效果和legacy/standard.effect完全一致，便于升级 |

>**这些宏可以不定义，系统内部会自动定义为默认值0**
**也可以直接定义为0或其他值，表示在此Effect中强制关闭或打开，禁止用户调节。**



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



### Surface Function

**每个材质函数的功能类似于DCC软件的材质编辑器中输出一个材质参数到指定的材质节点**。类似于：![surfacenode](surfacenode.png)

#### 1、定义

可以使用 `CCProgram` 或单独的chunk来定义Surface材质函数块。

**注意VS和FS使用的函数块必须分开**。通常来讲所有的VS共享一个，所有的FS共享一个。在我们的例子中`standard-vs`和`shadow-caster-vs`共用`surface-vertex`块，而`standard-fs`和`shadow-caster-fs`共用`surface-fragment`块。

>用这种方式的好处是所有的用户自定义动画与材质的代码只需要写一份，却可以在各种渲染用途中保持统一。

Surface Shader在内部提供了简单的默认函数，所以**这些函数并不是必须定义的**，**如果你想重载某函数，需要预定义该函数对应的宏来完成**。这些函数命名以`Surfaces+Shader阶段`打头，后跟功能描述。可以在[`editor/assets/chunks/surfaces/default-functions`](https://github.com/cocos/cocos-engine/tree/v3.5.1/editor/assets/chunks/surfaces/default-functions)中查看不同材质模型中各Surface函数的具体定义与实现，如：

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

#### 2、VS对应的函数列表

VS中的处理和材质模型关系相对比较小，所以这里都使用通用函数，函数参数均为`SurfacesStandardVertexIntermediate`结构体，存放的是VS输入输出的数据。用户无需再关心具体的顶点输入输出流程处理，只需要聚焦到某个数据是否需要及如何修改。

| 预先定义宏                             | 对应的函数定义                       | 对应的材质模型 | 功能说明                              |
| -------------------------------------- | ------------------------------------ | -------------- | ------------------------------------- |
| CC_SURFACES_VERTEX_MODIFY_LOCAL_POS    | vec3 SurfacesVertexModifyLocalPos    | Common         | 修改模型空间坐标                      |
| CC_SURFACES_VERTEX_MODIFY_WORLD_POS    | vec3 SurfacesVertexModifyWorldPos    | Common         | 修改世界空间坐标（世界空间动画）      |
| CC_SURFACES_VERTEX_MODIFY_CLIP_POS     | vec4 SurfacesVertexModifyClipPos     | Common         | 修改剪裁（NDC）空间坐标（修改深度等） |
| CC_SURFACES_VERTEX_MODIFY_UV           | void SurfacesVertexModifyUV          | Common         | 修改UV0和UV1（使用tiling等）          |
| CC_SURFACES_VERTEX_MODIFY_WORLD_NORMAL | vec3 SurfacesVertexModifyWorldNormal | Common         | 修改世界空间法线（世界空间动画）      |

#### 3、FS对应的函数列表

| 预先定义宏                                              | 对应的函数定义                                       | 对应的材质模型 | 功能说明                                                     |
| ------------------------------------------------------- | ---------------------------------------------------- | -------------- | ------------------------------------------------------------ |
| CC_SURFACES_FRAGMENT_MODIFY_ BASECOLOR_AND_TRANSPARENCY | vec4 SurfacesFragmentModify BaseColorAndTransparency | Common         | 修改基础色和透明值（a通道）                                  |
| CC_SURFACES_FRAGMENT_MODIFY_ WORLD_NORMAL               | vec3 SurfacesFragmentModify WorldNormal              | Common         | 修改像素法线（通常是法线贴图）                               |
| CC_SURFACES_FRAGMENT_MODIFY_ SHARED_DATA                | void SurfacesFragmentModify SharedData               | Common         | 如果某些贴图和计算需要在多个材质节点中使用，可在此函数中进行，直接修改这些参数，减少性能耗费 |
| CC_SURFACES_FRAGMENT_MODIFY_ WORLD_TANGENT_AND_BINORMAL | void SurfacesFragmentModify WorldTangentAndBinormal  | Standard PBR   | 修改世界切空间向量                                           |
| CC_SURFACES_FRAGMENT_MODIFY_ EMISSIVE                   | vec3 SurfacesFragmentModify Emissive                 | Standard PBR   | 修改自发光颜色                                               |
| CC_SURFACES_FRAGMENT_MODIFY_ PBRPARAMS                  | vec4 SurfacesFragmentModify PBRParams                | Standard PBR   | 修改PBR参数（ao, roughness, metallic, specularIntensity）    |
| CC_SURFACES_FRAGMENT_MODIFY_ ANISOTROPY_PARAMS          | vec4 SurfacesFragmentModify AnisotropyParams         | Standard PBR   | 修改各向异性参数（rotation, shape, unused, unused）          |
| CC_SURFACES_FRAGMENT_MODIFY_ BASECOLOR_AND_TOONSHADE    | void SurfacesFragmentModify BaseColorAndToonShade    | Toon           | 修改卡通渲染基础色                                           |
| CC_SURFACES_FRAGMENT_MODIFY_ TOON_STEP_AND_FEATHER      | vec4 SurfacesFragmentModify ToonStepAndFeather       | Toon           | 修改卡通渲染所需的参数                                       |
| CC_SURFACES_FRAGMENT_MODIFY_ TOON_SHADOW_COVER          | vec4 SurfacesFragmentModify ToonShadowCover          | Toon           | 修改卡通渲染所需的参数                                       |
| CC_SURFACES_FRAGMENT_MODIFY_ TOON_SPECULAR              | vec4 SurfacesFragmentModify ToonSpecular             | Toon           | 修改卡通渲染所需的参数                                       |

#### 4、VS输入值的获取

VS输入值都在`SurfacesStandardVertexIntermediate`结构体中，作为Surface函数参数传入

| Vertex Shader输入值 | 类型 | 使用时需要对应宏开启          | 含义                                 |
| ------------------- | ---- | ----------------------------- | ------------------------------------ |
| position            | vec4 | N/A                           | Local Position                       |
| normal              | vec3 | N/A                           | Local Normal                         |
| tangent             | vec4 | CC_SURFACES_USE_TANGENT_SPACE | Local Tangent and Mirror Normal Sign |
| color               | vec4 | CC_SURFACES_USE_VERTEX_COLOR  | Vertex Color                         |
| texCoord            | vec2 | N/A                           | UV0                                  |
| texCoord1           | vec2 | CC_SURFACES_USE_SECOND_UV     | UV1                                  |
| clipPos             | vec4 | N/A                           | Clip(NDC) Position                   |
| worldPos            | vec3 | N/A                           | World Position                       |
| worldNormal         | vec4 | N/A                           | World Normal and Two Side Sign       |
| worldTangent        | vec3 | CC_SURFACES_USE_TANGENT_SPACE | World Tangent                        |
| worldBinormal       | vec3 | CC_SURFACES_USE_TANGENT_SPACE | World Binormal                       |

#### 5、FS输入值的获取

FS的输入值目前作为宏来使用，大部分输入值在内部做了容错处理，可以无视对应宏条件随意访问

| Fragment Shader输入值 | 类型  | 使用时需要对应宏开启           | 含义               |
| --------------------- | ----- | ------------------------------ | ------------------ |
| FSInput_worldPos      | vec3  | N/A                            | World Position     |
| FSInput_worldNormal   | vec3  | N/A                            | World Normal       |
| FSInput_faceSideSign  | float | N/A                            | Two Side Sign      |
| FSInput_texcoord      | vec2  | N/A                            | UV0                |
| FSInput_texcoord1     | vec2  | N/A                            | UV1                |
| FSInput_vertexColor   | vec4  | N/A                            | Vertex Color       |
| FSInput_worldTangent  | vec3  | N/A                            | World Tangent      |
| FSInput_mirrorNormal  | float | N/A                            | Mirror Normal Sign |
| FSInput_localPos      | vec4  | CC_SURFACES_TRANSFER_LOCAL_POS | Local Position     |



### Shader Assembly

#### 1、组装



## Debug View

使用Surface Shader框架后，内置的Debug View功能即可生效，通过在界面上选择对应的Debug模式即可同屏查看模型、材质、光照及其他计算数据，在渲染效果异常的时候可以快速定位问题。

此功能预计在3.6开放。



## 进阶使用方法

1. 自行添加vs输出与fs输入：VS新定义varying变量之后在某个Surface函数中计算并输出该值
                                                 FS新定义varying变量之后在某个Surface函数中获取并使用该值
2. 甚至可以在不同的Shader主函数中混用Surface Shader和Legacy Shader（但是要保证Varying顶点数据在两个阶段一致）。




## 公共函数库

可以在`chunks的common`文件夹下找到不同分类的函数库头文件。

库中的函数不依赖任何内部数据（引擎相关uniform和贴图等），可以当作工具函数直接使用。

Surface内部已经自动包含了常用的公共函数头文件，根据类型可分为：

| 文件夹名 | 函数用途                                 |
| -------- | ---------------------------------------- |
| color    | 色彩相关功能（颜色空间、tonemapping等）  |
| data     | 数据相关功能（压缩解压缩等）             |
| debug    | Debug View相关功能                       |
| effect   | 场景特效相关功能（水、雾等）             |
| lighting | 光照相关功能（brdf、bsdf、衰减、烘焙等） |
| math     | 数学库（坐标变换、数值判定和运算等）     |
| mesh     | 模型相关功能（材质转换、模型动画等）     |
| shadow   | 阴影相关功能（pcf、hcs等）               |
| texture  | 贴图相关功能（采样、mip计算等）          |






[^1]: 不支持自定义几何体实例化属性。
