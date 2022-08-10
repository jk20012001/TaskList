#ifndef Include_Once_Grammar
#define Include_Once_Grammar
//该头文件中包含HLSL中使用的类或函数在C++中的定义,仅仅用于VC中的语法着色和快速输入提示或纠正,绝对不能参与HLSL编译
#ifdef WIN32
#pragma once
#include "windows.h"
#undef IN
#undef OUT

//先是基本数据类型
#ifndef _BASE_TYPE_DEFINED
#define _BASE_TYPE_DEFINED

struct _VECTOR2 { float x, y;float operator [](uint index) { return 0; } };
struct _VECTOR3 : _VECTOR2 { float z;};
struct _VECTOR4 : _VECTOR3 { float w;};

struct _GRAMMARVECTOR2 : _VECTOR2
{float r,g; _GRAMMARVECTOR2(float v1, float v2); _VECTOR2 rr,gg,xx,yy,	rg,gr,xy,yx;};
struct _GRAMMARVECTOR3 : _GRAMMARVECTOR2
{float b; _GRAMMARVECTOR3(float v1, float v2, float v3); _VECTOR2 bb,zz,	rb,br,xz,zx,	gb,bg,yz,zy;	_VECTOR3 rrr,ggg,bbb,xxx,yyy,zzz,	rgb,rbg,xyz,xzy,	grb,gbr,yxz,yzx,	brg,bgr,zxy,zyx;};
struct _GRAMMARVECTOR4 : _GRAMMARVECTOR3
{
	float a;  _GRAMMARVECTOR4(float v1, float v2, float v3, float v4);
	_VECTOR2 ra, ar, xw, wx, ga, ag, yw, wy, ba, ab, zw, wz, aa, ww;
	_VECTOR3	rrr, ggg, bbb, xxx, yyy, zzz, rgb, rbg, xyz, xzy, grb, gbr, yxz, yzx, brg, bgr, zxy, zyx;
	_VECTOR3	rba, rab, xzw, xwz, rga, rag, xyw, xwy, gba, gab, yzw, ywz, gra, gar, yxw, ywx, bra, bar, zxw, zwx, bga, bag, zyw, zwy,
		arg, agr, wxy, wyx, agb, abg, wyz, wzy, arb, abr, wxz, wzx, aaa, www;
	_VECTOR4	rgba, rgab, xyzw, xywz, rbga, rbag, xzyw, xywy, ragb, rabg, xwyz, xwzy,
		grba, grab, yxzw, yxwz, gbra, gbar, yzxw, yzwx, garb, gabr, ywxz, ywzx,
		brga, brag, zxyw, zxwy, bgra, bgar, zyxw, zywx, barg, bagr, zwxy, zwyx,
		argb, arbg, wxyz, wxzy, agrb, agbr, wyxz, wyzx, abrg, abgr, wzxy, wzyx,
		rrrr, gggg, bbbb, aaaa, xxxx, yyyy, zzzz, wwww;
};

typedef _GRAMMARVECTOR2 fixed2;
typedef _GRAMMARVECTOR2 half2;
typedef _GRAMMARVECTOR2 float2;
typedef _GRAMMARVECTOR2 int2;
typedef _GRAMMARVECTOR2 uint2;

typedef _GRAMMARVECTOR3 fixed3;
typedef _GRAMMARVECTOR3 half3;
typedef _GRAMMARVECTOR3 float3;
typedef _GRAMMARVECTOR3 int3;
typedef _GRAMMARVECTOR3 uint3;

typedef _GRAMMARVECTOR4 fixed4;
typedef _GRAMMARVECTOR4 half4;
typedef _GRAMMARVECTOR4 float4;
typedef _GRAMMARVECTOR4 int4;
typedef _GRAMMARVECTOR4 uint4;

struct float3x3 { _VECTOR3 operator [](uint index); };
struct float3x4 { _VECTOR3 operator [](uint index); };
struct float4x3 { _VECTOR4 operator [](uint index); };
struct float4x4 { _VECTOR4 operator [](uint index); };
typedef float4x4 Matrix;
typedef float4x4 matrix;
typedef float4x4 Matrix4;
typedef float3x3 Matrix3;
typedef float4x4 matrix4;
typedef float3x3 matrix3;

typedef float fixed;
typedef float half;
typedef float* sampler1D;
typedef float* sampler2D;
typedef float* samplerCUBE;
typedef int* sampler;
#endif

//通用数据类型
typedef UINT uint;
typedef float anytype_scalar; //任意类型的标量值
typedef _GRAMMARVECTOR4 anytype; //任意类型,包括向量与标量值
typedef _GRAMMARVECTOR4 VECType; //任意类型,仅向量
typedef _GRAMMARVECTOR4 floatVECType; //浮点向量
typedef _GRAMMARVECTOR4 f16VECType; //浮点16bit向量
typedef uint4 UINTVECType; //UINT向量
typedef int4 INTVECType; //INT向量
typedef __int64 type64bit; //64位数据,可为浮点,整型或其他

//再是关键字
#define interface class
#define SV_Position 128
#define SV_VertexId 32
#define SV_PrimitiveId 32
#define SV_InstanceId 32

#define SV_GSInstanceId 32
#define SV_RenderTargetArrayIndex 8
#define SV_ViewportArrayIndex  8

#define SV_IsFrontFace 8
#define SV_Target 32
#define SV_Target0 32
#define SV_Target1 32
#define SV_Target2 32
#define SV_Target3 32
#define SV_Target4 32
#define SV_Target5 32
#define SV_Target6 32
#define SV_Target7 32
#define SV_Depth 32
#define SV_DepthGreaterEqual 8 //这两个用于取代SV_Depth输出,可以在输出oDepth的情况下,仍然使用EarlyZ
#define SV_DepthLessEqual 8
#define SV_SampleIndex 8 //UINT型,ps输入参数,表示当前ps是在哪个子采样点上执行的,值范围从0到AA总数量-1
#define SV_Coverage 8 //UINT型,每个bit表示一个sample的输出掩码,1为允许写入,0为不允许,通常最多一个byte有效(8bit对应8AA)
										//配合EvaluateAttributeXXX函数来获取子像素的覆盖值

#define SV_DispatchThreadID 32
#define SV_GroupThreadID 16
#define SV_GroupID 16
#define SV_GroupIndex 16

#define SV_DomainLocation 32
#define SV_InsideTessFactor 32
#define SV_OutputControlPointID 32
#define SV_TessFactor 32

#define technique
#define pass
#define in
#define out
#define inout
#define unroll(MaxLoopCount)
#define loop
#define allow_uav_condition
#define flatten
#define branch
#define if_f if
#define if_d if
#define switch_f switch
#define switch_d switch
#define for_f(maxloopcount) for
#define for_d for
#define for_opt for
#define One 0
#define Zero 1

//下来是用途及自定义变量关键字
//根据FVF的VB元素分量存放顺序定义,Declaration中无此限制
#define POSITION 128
#define POSITION0 128
#define POSITIONT 128
#define BLENDWEIGHT 128
#define BLENDINDICES 32
#define NORMAL 128
#define NORMAL0 128
#define PSIZE 32
#define PSIZE0 32
#define COLOR 32
#define COLOR0 32
#define COLOR1 32
#define COLOR2 32
#define TEXCOORD 64
#define TEXCOORD0 64
#define TEXCOORD1 64
#define TEXCOORD2 64
#define TEXCOORD3 64
#define TEXCOORD4 64
#define TEXCOORD5 64
#define TEXCOORD6 64
#define TEXCOORD7 64
#define TANGENT 128
#define TANGENT0 128
#define BINORMAL 128
#define BINORMAL0 128

#define szDesc
#define uniform
#define Linear
#define LINEAR
#define CLAMP
#define compile
#define vs_1_0
#define vs_2_0
#define vs_3_0
#define ps_1_1
#define ps_1_4
#define ps_2_0
#define ps_3_0
#define es200
#define es300
#define VertexShader
#define PixelShader

char *Texture, *MipFilter, *MinFilter, *MagFilter;

//结构体

struct sampler_state
{
	unsigned int Texture, MinFilter, MagFilter, MipFilter;
};

typedef struct tagSampleStater
{
	unsigned int Filter;
}Sampler_State;

//采样函数
anytype tex1D(Sampler_State ss, float fTextureCoord);
anytype tex1Dbias(Sampler_State ss, float4 v4TextureCoord); //Mip相关数据在w分量中
anytype tex1Dlod(Sampler_State ss, float4 v4TextureCoord); //Mip相关数据在w分量中
anytype tex1Dgrad(Sampler_State ss, float fTextureCoord, float ddx, float ddy);

anytype tex2D(Sampler_State ss, float2 v2TextureCoord);
anytype tex2Dbias(Sampler_State ss, float4 v4TextureCoord); //Mip相关数据在w分量中
anytype tex2Dlod(Sampler_State ss, float4 v4TextureCoord); //Mip相关数据在w分量中
anytype tex2Dproj(Sampler_State ss, float4 v4TextureCoord);
anytype tex2D(Sampler_State ss, float2 v2TextureCoord, float2 ddx, float2 ddy);
anytype tex2Dgrad(Sampler_State ss, float2 v2TextureCoord, float2 ddx, float2 ddy);

anytype texCUBE(Sampler_State ss, float3 v3TextureCoord);
anytype texCUBEbias(Sampler_State ss, float4 v4TextureCoord);
anytype texCUBElod(Sampler_State ss, float4 v4TextureCoord);
anytype texCUBEproj(Sampler_State ss, float4 v4TextureCoord);
anytype texCUBE(Sampler_State ss, float3 v3TextureCoord, float3 ddx, float3 ddy);
anytype texCUBEgrad(Sampler_State ss, float3 v3TextureCoord, float3 ddx, float3 ddy);






//////////////////////////////////////////////////////////////////////////
//该段中含有很多中文注释,在ShaderCompilerIDE的stdafx.cpp中,在包含stdafx.h(即本文件)之前,定义该宏,这样可以正常编译生成Win32工程但不会影响Shader的语法着色
#ifndef GRAMMAR_PERCEPTION_ONLY

//内部函数,anytype表示任意类型任意元素数量的数据,VEC表示任意类型但必须是向量
anytype ddx(anytype ShaderInputData);
anytype ddy(anytype ShaderInputData);
anytype ddx_coarse(anytype ShaderInputData, const char *_info = "低精度");
anytype ddy_coarse(anytype ShaderInputData, const char *_info = "低精度");
anytype ddx_fine(anytype ShaderInputData, const char *_info = "高精度");
anytype ddy_fine(anytype ShaderInputData, const char *_info = "高精度");
//数值变换
anytype saturate(anytype 限制在0和1之间);
anytype clamp(anytype Data, anytype MinValue, anytype MaxValue, const char *_info = "要特别小心UINT型的变量,必须转成int型的再传入");
anytype frac(anytype Data, const char *_info = "取其小数部分");
anytype trunc(anytype Data, const char *_info = "取整数部分");
anytype round(anytype Data, const char *_info = "取四舍五入");
UINTVECType ceil(anytype Data, const char *_info = "取大于等于它且最接近它的整数");
UINTVECType floor(anytype Data, const char *_info = "取小于等于它且最接近它的整数");
floatVECType fmod(floatVECType Data, floatVECType 除数, const char *_info = "浮点数专用的求余函数,相当于Data % 除数");
floatVECType modf(anytype Data, __out INTVECType OutData, const char *_info = "返回小数部分,参数2为输出的整数部分,这两部分的符号将与输入数值相同");
anytype degrees(anytype Data, const char *_info = "把弧度变成度");
anytype radians(anytype Data, const char *_info = "把度变成弧度");

//数值判断
INTVECType sign(anytype GetSign_LessThanZero_Or_MoreThanZero_Or_Zero);
bool all(anytype Data, const char *_info = "所有元素非0才返回TRUE");
bool any(anytype Data, const char *_info = "任意一个元素非0就返回TRUE");
anytype min(anytype A, anytype B);
anytype max(anytype A, anytype B);
bool isnan(anytype Data, const char *_info = "是否为无理数");
bool isinf(anytype Data, const char *_info = "是否为无限大或无限小");
bool isfinite(anytype Data, const char *_info = "是否为有限的,去掉了无理数和无限大小值的可能,主要用于判有效");
float step(anytype A, anytype B, const char *_info = "返回A<=B或B>=A的浮点数,去掉bool值转换");

//矩阵和向量运算
VECType normalize(VECType Data);
float dot(VECType Data1, VECType Data2);
VECType cross(VECType Data1, VECType Data2, const char *_info = "左手定则");
float determinant(MAT4 Data, const char *_info = "矩阵求秩");
MAT4 transpose(MAT4 Data);
anytype mul(anytype Data1, anytype Data2);
float length(VECType Data);
anytype lerp(anytype Data1_Left, anytype Data2_Right, anytype Coef_DirectMulToData2);
VECType reflect(VECType IncidentDirection从别处到像素, VECType Normal);
VECType refract(VECType IncidentDirection从别处到像素, VECType Normal, float 折射率之比);
float noise(VECType param, const char *_info = "只能用在ShaderModel1");
double fma(double a, double b, double c, const char *_info = "double类型并且安全的计算a*b+c");

//数据类型转换与位操作
UINTVECType f32tof16(floatVECType Data, const char *_info = "fp16类型为了方便位操作,其本质就是uint");
floatVECType f16tof32(UINTVECType fp16Data, const char *_info = "fp16类型为了方便位操作,其本质就是uint");
uint4 D3DCOLORtoUBYTE4(float4 color);
double asdouble(anytype lowbits, anytype highbits, const char *_info = "逐bit将两个32位值读取为浮点数,不改变bit值");
float2 asfloat(type64bit value, const char *_info = "逐bit将64位值读取为两个浮点数,不改变bit值");
VECType asfloat(anytype value, const char *_info = "逐bit将32位值读取为浮点数,不改变bit值");
int2 asint(type64bit value, const char *_info = "逐bit将64位值读取为两个int数,不改变bit值");
INTVECType asint(anytype value, const char *_info = "逐bit将32位值读取为int数,不改变bit值，注意half会自动隐式转换为float再做逐bit转换,请先使用f16tof32再传入该函数");
void asuint(type64bit value, __out UINT HighBits, __out UINT LowBits, const char *_info = "逐bit将64位值读取为两个UINT数,不改变bit值");
UINTVECType asuint(anytype value, const char *_info = "逐bit将32位值读取为UINT数,不改变bit值，注意half会自动隐式转换为float再做逐bit转换,请先使用f16tof32再传入该函数");

//注意HLSL中对UINT移位>=32bit的话,将对移动的位数取余
	//iValue>>32相当于iValue>>0,即等于iValue原值,而非像C++中一样变成0
	//移位超过32bit的话,如iValue>>36,等于iValue>>4
UINTVECType firstbitlow(INTVECType Data, const char *_info = "返回第一个等于一的二进制位序号,从低位向高位搜索,逐分量独立进行");
UINTVECType firstbithi(INTVECType Data, const char *_info = "返回第一个等于一的二进制位序号,从高位向低位搜索,逐分量独立进行");
UINTVECType countbits(UINTVECType Data, const char *_info = "返回等于一的二进制位数量,逐分量独立进行");
UINTVECType reversebits(UINTVECType Data);

//数学运算
anytype mad(anytype A, anytype B, anytype C, const char *_info = "返回A*B+C");
anytype sqrt(anytype 平方根);
anytype rcp(anytype 倒数);
anytype rsqrt(anytype 平方根的倒数);
anytype sin(anytype 弧度);
anytype asin(anytype 反正弦);
anytype cos(anytype 弧度);
anytype acos(anytype 反余弦);
void sincos(anytype Data, out anytype Sin, out anytype Cos, const char *_info = "同时返回正弦和余弦");
anytype tan(anytype 弧度);
anytype atan(anytype y_Div_x, const char *_info = "计算指定值的反正切,无法确定象限");
anytype atan2(anytype y, anytype x, const char *_info = "计算y/x的反正切,可以确定象限");
anytype log(anytype 以自然对数为底);
anytype log10(anytype 以10为底);
anytype log2(anytype 以2为底);
anytype pow(anytype 底数, anytype 指数);
anytype exp(anytype 以自然对数为底的指数);
anytype exp2(anytype 以2为底的指数);

anytype fwidth(anytype Data, const char *_info = "返回输入数据的偏导绝对值之和,即对两个偏导分别取绝对值后的和,相当于在内部先取了绝对值再相加的梯度 return abs(ddx)+abs(ddy)");
anytype cosh(anytype 双曲正弦);
anytype frexp(anytype Data, __out anytype OutData, const char *_info = "分解一个数字,返回其尾数,参数2为输出的指数,以10为底");
anytype ldexp(anytype 参数说明见注释, anytype 以二为底的指数, const char *_info = "先根据参数2计算以2为底的幂再乘参数1");
//对指定的参数3做Hermite平滑修正,使其由线性变为曲线,若参数3落在min和max范围外,则Clamp,注意它并非真正的Hermite曲线,不牵扯切线向量,没有太多的可控性,只能视为做了一种典型的Hermite曲线性平滑而已
anytype smoothstep(anytype min, anytype max, anytype 参数说明见注释);

//获取系统值
UINT GetRenderTargetSampleCount();
//系统控制
void clip(anytype AnyElementIsLessThanZeroThenClip);
void errorf(string Message);
void printf(string FormattedMessage, ...);
void abort();



//////////////////////////////////////////////////////////////////////////OpenGL
typedef float3x3 mat3;
typedef float4x4 mat4;
typedef _GRAMMARVECTOR4 vec4;
typedef _GRAMMARVECTOR3 vec3;
typedef _GRAMMARVECTOR2 vec2;
#define uniform //C++->Shader
#define attribute //IA->VS
#define varying //VS->PS

const int  gl_MaxLights = 8;
const int  gl_MaxClipPlanes = 6;
const int  gl_MaxTextureUnits = 2;
const int  gl_MaxTextureCoords = 2;
const int  gl_MaxVertexAttribs = 16;
const int  gl_MaxVertexUniformComponents = 512;
const int  gl_MaxVaryingFloats = 32;
const int  gl_MaxVertexTextureImageUnits = 0;
const int  gl_MaxTextureImageUnits = 2;
const int  gl_MaxFragmentUniformComponents = 64;
const int  gl_MaxCombinedTextureImageUnits = 2;
const int  gl_MaxDrawbuffers = 1;

attribute vec4 gl_Color;
attribute vec4 gl_SecondaryColor;
attribute vec3 gl_Normal;
attribute vec4 gl_Vertex;
attribute vec4 gl_MultiTexCoord0;
attribute vec4 gl_MultiTexCoord1;
attribute vec4 gl_MultiTexCoord2;

attribute vec3 gles_Normal;
attribute vec4 gles_Vertex;
attribute vec4 gles_MultiTexCoord0;
attribute vec4 gles_MultiTexCoord1;

vec4 gl_Position;
float   gl_PointSize;
vec4  gl_ClipVertex;
uniform vec4  gl_ClipPlane[gl_MaxClipPlanes];

bool gl_FrontFacing;
vec4 gl_FragColor;
vec4  gl_FragData[gl_MaxDrawbuffers];
float gl_FragDepth;

//
// Matrix state
//
uniform mat4  gl_ModelViewMatrix;
uniform mat4  gl_ProjectionMatrix;
uniform mat4  gl_ModelViewProjectionMatrix;
uniform mat4  gl_TextureMatrix[gl_MaxTextureCoords];

uniform mat3  gl_NormalMatrix; // transpose of the inverse of the upper

uniform mat4  gl_ModelViewMatrixInverse;
uniform mat4  gl_ProjectionMatrixInverse;
uniform mat4  gl_ModelViewProjectionMatrixInverse;
uniform mat4  gl_TextureMatrixInverse[gl_MaxTextureCoords];

uniform mat4  gl_ModelViewMatrixTranspose;
uniform mat4  gl_ProjectionMatrixTranspose;
uniform mat4  gl_ModelViewProjectionMatrixTranspose;
uniform mat4  gl_TextureMatrixTranspose[gl_MaxTextureCoords];

uniform mat4  gl_ModelViewMatrixInverseTranspose;
uniform mat4  gl_ProjectionMatrixInverseTranspose;
uniform mat4  gl_ModelViewProjectionMatrixInverseTranspose;
uniform mat4  gl_TextureMatrixInverseTranspose[gl_MaxTextureCoords];

#define precision
#define lowp
#define mediump
#define highp

//旧版,不推荐
anytype texture2D(sampler2D ss, float2 v2TextureCoord);
anytype textureCUBE(samplerCUBE ss, float3 v3TextureCoord);
anytype texture2DLodEXT(sampler2D ss, float2 v2TextureCoord, float lod);
anytype textureCUBELodEXT(samplerCUBE ss, float3 v3TextureCoord, float lod);
//新版,推荐,__VERSION__>=130
anytype texture(sampler any_type_tex, floatVECType vTextureCoord, __opt float bias);
anytype textureOffset(sampler any_type_tex, floatVECType vTextureCoord, INTVECType vOffset, __opt float bias);
anytype textureLod(sampler any_type_tex, floatVECType vTextureCoord, float lod);
anytype textureLodOffset(sampler any_type_tex, floatVECType vTextureCoord, float lod, INTVECType vOffset);

//包含所有采样相关的proj/grad/lod/fetch函数 https://docs.gl/el3/textureSize
anytype texelFetch(sampler any_type_tex, floatVECType vTexelCoord, int lod); //Load三个, __VERSION__>=300
anytype texelFetchOffset(sampler any_type_tex, floatVECType vTexelCoord, int lod, INTVECType vOffset); //__VERSION__>=300
INTVECType textureSize(sampler any_type_tex, int lod); //GetDimensions三个, __VERSION__>=130
#define textureGather //Garther三个
#define textureGatherOffset
#define textureGatherOffsets
#define samplerShadow //SampleCmp
#define samplerGrad //SampleGrad
#define samplerGradOffset

//__VERSION__ >= 400
vec2 textureQueryLod(sampler any_type_tex, floatVECType vTextureCoord); //CalcLevelOfDetail
int textureQueryLevels(sampler any_type_tex, const char* _info = "查询mip数量, >=430"); //__VERSION__ >= 430
int textureSamples(sampler MSAAtex, const char* _info = "查询MSAA采样点数量, >=450"); //__VERSION__ >= 450

//__VERSION__ >= 300
anytype dFdx(anytype ShaderInputData);
anytype dFdy(anytype ShaderInputData);
anytype fwidth(anytype ShaderInputData, const char* _info = "dFdx + dFdy");
anytype dFdxCoarse(anytype ShaderInputData, const char *_info = "低精度，GLES不支持");
anytype dFdyCoarse(anytype ShaderInputData, const char *_info = "低精度，GLES不支持");
anytype dFdxFine(anytype ShaderInputData, const char *_info = "高精度，GLES不支持");
anytype dFdyFine(anytype ShaderInputData, const char *_info = "高精度，GLES不支持");

//数值变换
anytype fract(anytype Data, const char *_info = "取其小数部分");
anytype mix(anytype Data1_Left, anytype Data2_Right, anytype Coef_DirectMulToData2);
floatVECType mod(floatVECType Data, floatVECType 除数, const char *_info = "浮点数专用的求余函数, 相当于Data % 除数");
//modf floor ceil round trunc和HLSL相同
//没有saturate,可以定义一个宏用clamp来计算



#endif //GRAMMAR_PERCEPTION_ONLY
//////////////////////////////////////////////////////////////////////////
//下面定义HLSL中使用的一些语法
#else
#define __in in
#define __out out
#define __inout inout
#define virtual
#define virtual
#define public
#define if_f [flatten]if
#define if_d [branch]if
#define switch_f [flatten]switch
#define switch_d [branch]switch
#define for_f(maxloopcount) [unroll(maxloopcount)]for
#define for_d [loop]for
#define TEXTURE(VariableName, CommentText) texture VariableName<string szDesc = CommentText;>;

//发布Shader时请先定义MARKSHADER_XTRIBUTE宏,该宏在调试模式时使用loop动态循环,发布时将使用unroll展开循环,但需要很多编译时间
//如果是可展开的多次循环,请使用for_opt宏来自动优化
#ifdef MARKSHADER_XTRIBUTE
#define for_opt(maxloopcount) [unroll(maxloopcount)]for
#else
#define for_opt(maxloopcount) [loop]for
#endif

#endif

#endif //Include_Once_Grammar