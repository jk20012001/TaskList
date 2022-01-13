//该头文件中包含HLSL中使用的类或函数在C++中的定义,仅仅用于VC中的语法着色和快速输入提示或纠正,绝对不能参与HLSL编译
#ifdef __cplusplus
#pragma once
#include "windows.h"
#include "MiscInclude\d3dx\d3dx9.h"
#undef IN
#undef OUT

//先是基本数据类型
#ifndef _BASE_TYPE_DEFINED
#define _BASE_TYPE_DEFINED
#define __info
typedef D3DXMATRIX float3x3;
typedef D3DXMATRIX float3x4;
typedef D3DXMATRIX float4x3;
typedef D3DXMATRIX float4x4;
typedef D3DXMATRIX Matrix;
typedef D3DXMATRIX matrix;
typedef D3DXMATRIX Matrix4;
typedef D3DXMATRIX Matrix3;
typedef D3DXMATRIX matrix4;
typedef D3DXMATRIX matrix3;

struct _GRAMMARVECTOR2 : D3DXVECTOR2
{float r,g; D3DXVECTOR2 rr,gg,xx,yy,	rg,gr,xy,yx;};
struct _GRAMMARVECTOR3 : D3DXVECTOR3, _GRAMMARVECTOR2
{float b;	D3DXVECTOR2 bb,zz,	rb,br,xz,zx,	gb,bg,yz,zy;	D3DXVECTOR3 rrr,ggg,bbb,xxx,yyy,zzz,	rgb,rbg,xyz,xzy,	grb,gbr,yxz,yzx,	brg,bgr,zxy,zyx;};
struct _GRAMMARVECTOR4 : D3DXVECTOR4, _GRAMMARVECTOR3
{
	float a;	D3DXVECTOR2 ra, ar, xw, wx, ga, ag, yw, wy, ba, ab, zw, wz, aa, ww;
	D3DXVECTOR3	rrr, ggg, bbb, xxx, yyy, zzz, rgb, rbg, xyz, xzy, grb, gbr, yxz, yzx, brg, bgr, zxy, zyx;
	D3DXVECTOR3	rba, rab, xzw, xwz, rga, rag, xyw, xwy, gba, gab, yzw, ywz, gra, gar, yxw, ywx, bra, bar, zxw, zwx, bga, bag, zyw, zwy,
		arg, agr, wxy, wyx, agb, abg, wyz, wzy, arb, abr, wxz, wzx, aaa, www;
	D3DXVECTOR4	rgba, rgab, xyzw, xywz, rbga, rbag, xzyw, xywy, ragb, rabg, xwyz, xwzy,
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

typedef float fixed;
typedef float half;
typedef int* sampler1D;
typedef int* sampler2D;
typedef float* samplerCUBE;
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
typedef int* sampler;
#define technique
#define pass
#define in
#define out
#define inout
#define unroll(MaxLoopCount)
#define loop
#define flatten
#define branch
#define if_f if
#define if_d if
#define switch_f switch
#define switch_d switch
#define for_f(maxloopcount) for
#define for_d for
#define for_opt for
#define One
#define Zero

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
anytype ddx_coarse(anytype ShaderInputData, __info 低精度);
anytype ddy_coarse(anytype ShaderInputData, __info 低精度);
anytype ddx_fine(anytype ShaderInputData, __info 高精度);
anytype ddy_fine(anytype ShaderInputData, __info 高精度);
//数值变换
anytype saturate(anytype 限制在0和1之间);
anytype clamp(anytype Data, anytype MinValue, anytype MaxValue, __info 要特别小心UINT型的变量,必须转成int型的再传入);
anytype frac(anytype 取其小数部分);
anytype trunc(anytype 取整数部分);
anytype round(anytype 取四舍五入);
UINTVECType ceil(anytype 取大于等于它且最接近它的整数);
UINTVECType floor(anytype 取小于等于它且最接近它的整数);
floatVECType fmod(floatVECType Data, floatVECType 除数, __info 浮点数专用的求余函数,相当于Data % 除数);
floatVECType modf(anytype Data, __out INTVECType OutData, __info 返回小数部分,参数2为输出的整数部分,这两部分的符号将与输入数值相同);
anytype degrees(anytype 把弧度变成度);
anytype radians(anytype 把度变成弧度);

//数值判断
INTVECType sign(anytype GetSign_LessThanZero_Or_MoreThanZero_Or_Zero);
bool all(anytype 所有元素非0才返回TRUE);
bool any(anytype 任意一个元素非0就返回TRUE);
anytype min(anytype A, anytype B);
anytype max(anytype A, anytype B);
bool isnan(anytype 是否为无理数);
bool isinf(anytype 是否为无限大或无限小);
bool isfinite(anytype 是否为有限的,去掉了无理数和无限大小值的可能,主要用于判有效);
float step(anytype A, anytype B, __info 返回A<=B或B>=A的浮点数,去掉bool值转换);

//矩阵和向量运算
VECType normalize(VECType Data);
float dot(VECType Data1, VECType Data2);
VECType cross(VECType Data1, VECType Data2, __info 左手定则);
float determinant(Matrix 矩阵求秩);
Matrix transpose(Matrix 矩阵求逆);
anytype mul(anytype Data1, anytype Data2);
float length(VECType Data);
anytype lerp(anytype Data1_Left, anytype Data2_Right, anytype Coef_DirectMulToData2);
VECType reflect(VECType IncidentDirection从别处到像素, VECType Normal);
VECType refract(VECType IncidentDirection从别处到像素, VECType Normal, float 折射率之比);
float noise(VECType param, __info 只能用在ShaderModel1);
double fma(double a, double b, double c, __info double类型并且安全的计算a*b+c);

//数据类型转换与位操作
UINTVECType f32tof16(floatVECType Data, __info fp16类型为了方便位操作,其本质就是uint);
floatVECType f16tof32(UINTVECType fp16Data, __info fp16类型为了方便位操作,其本质就是uint);
UINTVEC4 D3DCOLORtoUBYTE4(VEC4 浮点数转换为颜色值整数);
double asdouble(anytype lowbits, anytype highbits, __info 逐bit将两个32位值读取为浮点数,不改变bit值);
float2 asfloat(type64bit value, __info 逐bit将64位值读取为两个浮点数,不改变bit值);
VECType asfloat(anytype value, __info 逐bit将32位值读取为浮点数,不改变bit值);
int2 asint(type64bit value, __info 逐bit将64位值读取为两个int数,不改变bit值);
INTVECType asint(anytype value, __info 逐bit将32位值读取为int数,不改变bit值，注意half会自动隐式转换为float再做逐bit转换,请先使用f16tof32再传入该函数);
void asuint(type64bit value, __out UINT HighBits, __out UINT LowBits, __info 逐bit将64位值读取为两个UINT数,不改变bit值);
UINTVECType asuint(anytype value, __info 逐bit将32位值读取为UINT数,不改变bit值，注意half会自动隐式转换为float再做逐bit转换,请先使用f16tof32再传入该函数);

//注意HLSL中对UINT移位>=32bit的话,将对移动的位数取余
	//iValue>>32相当于iValue>>0,即等于iValue原值,而非像C++中一样变成0
	//移位超过32bit的话,如iValue>>36,等于iValue>>4
UINTVECType firstbitlow(INTVECType Data, __info 返回第一个等于一的二进制位序号,从低位向高位搜索,逐分量独立进行);
UINTVECType firstbithi(INTVECType Data, __info 返回第一个等于一的二进制位序号,从高位向低位搜索,逐分量独立进行);
UINTVECType countbits(UINTVECType Data, __info 返回等于一的二进制位数量,逐分量独立进行);
UINTVECType reversebits(UINTVECType Data);

//数学运算
anytype mad(anytype A, anytype B, anytype C, __info 返回A*B+C);
anytype sqrt(anytype 平方根);
anytype rcp(anytype 倒数);
anytype rsqrt(anytype 平方根的倒数);
anytype sin(anytype 弧度);
anytype asin(anytype 反正弦);
anytype cos(anytype 弧度);
anytype acos(anytype 反余弦);
void sincos(anytype Data, out anytype Sin, out anytype Cos, __info 同时返回正弦和余弦);
anytype tan(anytype 弧度);
anytype atan(anytype 反正切);
anytype atan2(anytype Var1, anytype Var2, __info 同时计算两个数的反正切,互不影响);
anytype log(anytype 以自然对数为底);
anytype log10(anytype 以10为底);
anytype log2(anytype 以2为底);
anytype pow(anytype 底数, anytype 指数);
anytype exp(anytype 以自然对数为底的指数);
anytype exp2(anytype 以2为底的指数);

//返回输入数据的偏导绝对值之和,即对两个偏导分别取绝对值后的和,相当于在内部先取了绝对值再相加的梯度 return abs(ddx)+abs(ddy)
anytype fwidth(anytype 参数说明见注释);
anytype cosh(anytype 双曲正弦);
anytype frexp(anytype Data, __out anytype OutData, __info 分解一个数字,返回其尾数,参数2为输出的指数,以10为底);
anytype ldexp(anytype 参数说明见注释, anytype 以二为底的指数, __info 先根据参数2计算以2为底的幂再乘参数1);
//对指定的参数3做Hermite平滑修正,使其由线性变为曲线,若参数3落在min和max范围外,则Clamp,注意它并非真正的Hermite曲线,不牵扯切线向量,没有太多的可控性,只能视为做了一种典型的Hermite曲线性平滑而已
anytype smoothstep(anytype min, anytype max, anytype 参数说明见注释);

//获取系统值
UINT GetRenderTargetSampleCount();
//系统控制
void clip(anytype AnyElementIsLessThanZeroThenClip);
void errorf(string Message);
void printf(string FormattedMessage, ...);
void abort();
#endif //GRAMMAR_PERCEPTION_ONLY



//////////////////////////////////////////////////////////////////////////D3D10
#define SV_POSITION 128
#define SV_RENDERTARGETARRAYINDEX 8
#define SV_ISFRONTFACE 8
#define SV_TARGET 32


//////////////////////////////////////////////////////////////////////////OpenGL
typedef D3DXMATRIX mat3;
typedef D3DXMATRIX mat4;
typedef D3DXVECTOR4 vec4;
typedef D3DXVECTOR3 vec3;
typedef D3DXVECTOR2 vec2;
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
//新版,推荐
anytype texture(sampler any_type_tex, floatVECType vTextureCoord, __opt float bias);
anytype textureOffset(sampler any_type_tex, floatVECType vTextureCoord, INTVECType vOffset, __opt float bias);
anytype textureLod(sampler any_type_tex, floatVECType vTextureCoord, float lod);
anytype textureLodOffset(sampler any_type_tex, floatVECType vTextureCoord, float lod, INTVECType vOffset);

#define textureQueryLod //CalcLevelOfDetail
#define texelFetch //Load两个
#define texelFetchOffset
#define textureSize //GetDimensions三个
#define textureQueryLevels
#define textureSamples
#define textureGather //Garther三个
#define textureGatherOffset
#define textureGatherOffsets
#define samplerShadow //SampleCmp
#define samplerGrad //SampleGrad
#define samplerGradOffset


anytype dFdx(anytype ShaderInputData);
anytype dFdy(anytype ShaderInputData);
anytype dFdxCoarse(anytype ShaderInputData, __info 低精度);
anytype dFdyCoarse(anytype ShaderInputData, __info 低精度);
anytype dFdxFine(anytype ShaderInputData, __info 高精度);
anytype dFdyFine(anytype ShaderInputData, __info 高精度);
//数值变换
anytype fract(anytype 取其小数部分);
anytype mix(anytype Data1_Left, anytype Data2_Right, anytype Coef_DirectMulToData2);
floatVECType mod(floatVECType Data, floatVECType 除数, __info 浮点数专用的求余函数, 相当于Data % 除数);
//modf floor ceil round trunc和HLSL相同
//没有saturate,可以定义一个宏用clamp来计算




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