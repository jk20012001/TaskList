//��ͷ�ļ��а���HLSL��ʹ�õ��������C++�еĶ���,��������VC�е��﷨��ɫ�Ϳ���������ʾ�����,���Բ��ܲ���HLSL����
#ifdef __cplusplus
#pragma once
#include "windows.h"
#include "MiscInclude\d3dx\d3dx9.h"
#undef IN
#undef OUT

//���ǻ�����������
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

//ͨ����������
typedef UINT uint;
typedef float anytype_scalar; //�������͵ı���ֵ
typedef _GRAMMARVECTOR4 anytype; //��������,�������������ֵ
typedef _GRAMMARVECTOR4 VECType; //��������,������
typedef _GRAMMARVECTOR4 floatVECType; //��������
typedef _GRAMMARVECTOR4 f16VECType; //����16bit����
typedef uint4 UINTVECType; //UINT����
typedef int4 INTVECType; //INT����
typedef __int64 type64bit; //64λ����,��Ϊ����,���ͻ�����

//���ǹؼ���
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

//��������;���Զ�������ؼ���
//����FVF��VBԪ�ط������˳����,Declaration���޴�����
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

//�ṹ��

struct sampler_state
{
	unsigned int Texture, MinFilter, MagFilter, MipFilter;
};

typedef struct tagSampleStater
{
	unsigned int Filter;
}Sampler_State;

//��������
anytype tex1D(Sampler_State ss, float fTextureCoord);
anytype tex1Dbias(Sampler_State ss, float4 v4TextureCoord); //Mip���������w������
anytype tex1Dlod(Sampler_State ss, float4 v4TextureCoord); //Mip���������w������
anytype tex1Dgrad(Sampler_State ss, float fTextureCoord, float ddx, float ddy);

anytype tex2D(Sampler_State ss, float2 v2TextureCoord);
anytype tex2Dbias(Sampler_State ss, float4 v4TextureCoord); //Mip���������w������
anytype tex2Dlod(Sampler_State ss, float4 v4TextureCoord); //Mip���������w������
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
//�ö��к��кܶ�����ע��,��ShaderCompilerIDE��stdafx.cpp��,�ڰ���stdafx.h(�����ļ�)֮ǰ,����ú�,��������������������Win32���̵�����Ӱ��Shader���﷨��ɫ
#ifndef GRAMMAR_PERCEPTION_ONLY

//�ڲ�����,anytype��ʾ������������Ԫ������������,VEC��ʾ�������͵�����������
anytype ddx(anytype ShaderInputData);
anytype ddy(anytype ShaderInputData);
anytype ddx_coarse(anytype ShaderInputData, __info �;���);
anytype ddy_coarse(anytype ShaderInputData, __info �;���);
anytype ddx_fine(anytype ShaderInputData, __info �߾���);
anytype ddy_fine(anytype ShaderInputData, __info �߾���);
//��ֵ�任
anytype saturate(anytype ������0��1֮��);
anytype clamp(anytype Data, anytype MinValue, anytype MaxValue, __info Ҫ�ر�С��UINT�͵ı���,����ת��int�͵��ٴ���);
anytype frac(anytype ȡ��С������);
anytype trunc(anytype ȡ��������);
anytype round(anytype ȡ��������);
UINTVECType ceil(anytype ȡ���ڵ���������ӽ���������);
UINTVECType floor(anytype ȡС�ڵ���������ӽ���������);
floatVECType fmod(floatVECType Data, floatVECType ����, __info ������ר�õ����ຯ��,�൱��Data % ����);
floatVECType modf(anytype Data, __out INTVECType OutData, __info ����С������,����2Ϊ�������������,�������ֵķ��Ž���������ֵ��ͬ);
anytype degrees(anytype �ѻ��ȱ�ɶ�);
anytype radians(anytype �Ѷȱ�ɻ���);

//��ֵ�ж�
INTVECType sign(anytype GetSign_LessThanZero_Or_MoreThanZero_Or_Zero);
bool all(anytype ����Ԫ�ط�0�ŷ���TRUE);
bool any(anytype ����һ��Ԫ�ط�0�ͷ���TRUE);
anytype min(anytype A, anytype B);
anytype max(anytype A, anytype B);
bool isnan(anytype �Ƿ�Ϊ������);
bool isinf(anytype �Ƿ�Ϊ���޴������С);
bool isfinite(anytype �Ƿ�Ϊ���޵�,ȥ���������������޴�Сֵ�Ŀ���,��Ҫ��������Ч);
float step(anytype A, anytype B, __info ����A<=B��B>=A�ĸ�����,ȥ��boolֵת��);

//�������������
VECType normalize(VECType Data);
float dot(VECType Data1, VECType Data2);
VECType cross(VECType Data1, VECType Data2, __info ���ֶ���);
float determinant(Matrix ��������);
Matrix transpose(Matrix ��������);
anytype mul(anytype Data1, anytype Data2);
float length(VECType Data);
anytype lerp(anytype Data1_Left, anytype Data2_Right, anytype Coef_DirectMulToData2);
VECType reflect(VECType IncidentDirection�ӱ𴦵�����, VECType Normal);
VECType refract(VECType IncidentDirection�ӱ𴦵�����, VECType Normal, float ������֮��);
float noise(VECType param, __info ֻ������ShaderModel1);
double fma(double a, double b, double c, __info double���Ͳ��Ұ�ȫ�ļ���a*b+c);

//��������ת����λ����
UINTVECType f32tof16(floatVECType Data, __info fp16����Ϊ�˷���λ����,�䱾�ʾ���uint);
floatVECType f16tof32(UINTVECType fp16Data, __info fp16����Ϊ�˷���λ����,�䱾�ʾ���uint);
UINTVEC4 D3DCOLORtoUBYTE4(VEC4 ������ת��Ϊ��ɫֵ����);
double asdouble(anytype lowbits, anytype highbits, __info ��bit������32λֵ��ȡΪ������,���ı�bitֵ);
float2 asfloat(type64bit value, __info ��bit��64λֵ��ȡΪ����������,���ı�bitֵ);
VECType asfloat(anytype value, __info ��bit��32λֵ��ȡΪ������,���ı�bitֵ);
int2 asint(type64bit value, __info ��bit��64λֵ��ȡΪ����int��,���ı�bitֵ);
INTVECType asint(anytype value, __info ��bit��32λֵ��ȡΪint��,���ı�bitֵ��ע��half���Զ���ʽת��Ϊfloat������bitת��,����ʹ��f16tof32�ٴ���ú���);
void asuint(type64bit value, __out UINT HighBits, __out UINT LowBits, __info ��bit��64λֵ��ȡΪ����UINT��,���ı�bitֵ);
UINTVECType asuint(anytype value, __info ��bit��32λֵ��ȡΪUINT��,���ı�bitֵ��ע��half���Զ���ʽת��Ϊfloat������bitת��,����ʹ��f16tof32�ٴ���ú���);

//ע��HLSL�ж�UINT��λ>=32bit�Ļ�,�����ƶ���λ��ȡ��
	//iValue>>32�൱��iValue>>0,������iValueԭֵ,������C++��һ�����0
	//��λ����32bit�Ļ�,��iValue>>36,����iValue>>4
UINTVECType firstbitlow(INTVECType Data, __info ���ص�һ������һ�Ķ�����λ���,�ӵ�λ���λ����,�������������);
UINTVECType firstbithi(INTVECType Data, __info ���ص�һ������һ�Ķ�����λ���,�Ӹ�λ���λ����,�������������);
UINTVECType countbits(UINTVECType Data, __info ���ص���һ�Ķ�����λ����,�������������);
UINTVECType reversebits(UINTVECType Data);

//��ѧ����
anytype mad(anytype A, anytype B, anytype C, __info ����A*B+C);
anytype sqrt(anytype ƽ����);
anytype rcp(anytype ����);
anytype rsqrt(anytype ƽ�����ĵ���);
anytype sin(anytype ����);
anytype asin(anytype ������);
anytype cos(anytype ����);
anytype acos(anytype ������);
void sincos(anytype Data, out anytype Sin, out anytype Cos, __info ͬʱ�������Һ�����);
anytype tan(anytype ����);
anytype atan(anytype ������);
anytype atan2(anytype Var1, anytype Var2, __info ͬʱ�����������ķ�����,����Ӱ��);
anytype log(anytype ����Ȼ����Ϊ��);
anytype log10(anytype ��10Ϊ��);
anytype log2(anytype ��2Ϊ��);
anytype pow(anytype ����, anytype ָ��);
anytype exp(anytype ����Ȼ����Ϊ�׵�ָ��);
anytype exp2(anytype ��2Ϊ�׵�ָ��);

//�����������ݵ�ƫ������ֵ֮��,��������ƫ���ֱ�ȡ����ֵ��ĺ�,�൱�����ڲ���ȡ�˾���ֵ����ӵ��ݶ� return abs(ddx)+abs(ddy)
anytype fwidth(anytype ����˵����ע��);
anytype cosh(anytype ˫������);
anytype frexp(anytype Data, __out anytype OutData, __info �ֽ�һ������,������β��,����2Ϊ�����ָ��,��10Ϊ��);
anytype ldexp(anytype ����˵����ע��, anytype �Զ�Ϊ�׵�ָ��, __info �ȸ��ݲ���2������2Ϊ�׵����ٳ˲���1);
//��ָ���Ĳ���3��Hermiteƽ������,ʹ�������Ա�Ϊ����,������3����min��max��Χ��,��Clamp,ע��������������Hermite����,��ǣ����������,û��̫��Ŀɿ���,ֻ����Ϊ����һ�ֵ��͵�Hermite������ƽ������
anytype smoothstep(anytype min, anytype max, anytype ����˵����ע��);

//��ȡϵͳֵ
UINT GetRenderTargetSampleCount();
//ϵͳ����
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

//�ɰ�,���Ƽ�
anytype texture2D(sampler2D ss, float2 v2TextureCoord);
anytype textureCUBE(samplerCUBE ss, float3 v3TextureCoord);
anytype texture2DLodEXT(sampler2D ss, float2 v2TextureCoord, float lod);
anytype textureCUBELodEXT(samplerCUBE ss, float3 v3TextureCoord, float lod);
//�°�,�Ƽ�
anytype texture(sampler any_type_tex, floatVECType vTextureCoord, __opt float bias);
anytype textureOffset(sampler any_type_tex, floatVECType vTextureCoord, INTVECType vOffset, __opt float bias);
anytype textureLod(sampler any_type_tex, floatVECType vTextureCoord, float lod);
anytype textureLodOffset(sampler any_type_tex, floatVECType vTextureCoord, float lod, INTVECType vOffset);

#define textureQueryLod //CalcLevelOfDetail
#define texelFetch //Load����
#define texelFetchOffset
#define textureSize //GetDimensions����
#define textureQueryLevels
#define textureSamples
#define textureGather //Garther����
#define textureGatherOffset
#define textureGatherOffsets
#define samplerShadow //SampleCmp
#define samplerGrad //SampleGrad
#define samplerGradOffset


anytype dFdx(anytype ShaderInputData);
anytype dFdy(anytype ShaderInputData);
anytype dFdxCoarse(anytype ShaderInputData, __info �;���);
anytype dFdyCoarse(anytype ShaderInputData, __info �;���);
anytype dFdxFine(anytype ShaderInputData, __info �߾���);
anytype dFdyFine(anytype ShaderInputData, __info �߾���);
//��ֵ�任
anytype fract(anytype ȡ��С������);
anytype mix(anytype Data1_Left, anytype Data2_Right, anytype Coef_DirectMulToData2);
floatVECType mod(floatVECType Data, floatVECType ����, __info ������ר�õ����ຯ��, �൱��Data % ����);
//modf floor ceil round trunc��HLSL��ͬ
//û��saturate,���Զ���һ������clamp������




//////////////////////////////////////////////////////////////////////////
//���涨��HLSL��ʹ�õ�һЩ�﷨
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

//����Shaderʱ���ȶ���MARKSHADER_XTRIBUTE��,�ú��ڵ���ģʽʱʹ��loop��̬ѭ��,����ʱ��ʹ��unrollչ��ѭ��,����Ҫ�ܶ����ʱ��
//����ǿ�չ���Ķ��ѭ��,��ʹ��for_opt�����Զ��Ż�
#ifdef MARKSHADER_XTRIBUTE
#define for_opt(maxloopcount) [unroll(maxloopcount)]for
#else
#define for_opt(maxloopcount) [loop]for
#endif

#endif