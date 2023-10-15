/*
Copyright (c) 2021, Adobe. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
   * Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
   * Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in the
     documentation and/or other materials provided with the distribution.
   * Neither the name of the Adobe nor the
     names of its contributors may be used to endorse or promote products
     derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL ADOBE BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

//////////////////////////////// Fragment shader
#version 330

#include "../common/common.glsl"
#include "../common/uvtile.glsl"
#include "../common/aniso_angle.glsl"
#include "../common/parallax.glsl"

in vec3 iFS_Normal;
in vec2 iFS_UV;
in vec3 iFS_Tangent;
in vec3 iFS_Binormal;
in vec3 iFS_PointWS;

out vec4 ocolor0;

// Environment -------------------------------------------------------------
uniform float AmbiIntensity = 1.0;
uniform float envRotation = 0.0;

// UVs -------------------------------------------------------------
uniform float tiling = 1.0;
uniform vec3 uvwScale = vec3(1.0, 1.0, 1.0);
uniform bool uvwScaleEnabled = false;

// Base Layer -------------------------------------------------------------
uniform sampler2D baseColorMap;
uniform bool sRGBBaseColor = true;
uniform sampler2D metallicMap;
uniform sampler2D roughnessMap;
uniform sampler2D opacityMap;
uniform sampler2D aoMap;
uniform sampler2D specularLevelMap;
uniform sampler2D specularEdgeColorMap;
uniform bool sRGBSpecularEdgeColor = true;
uniform float specularIoR;

// Normal -------------------------------------------------------------
uniform sampler2D normalMap;
uniform bool flipY = true;
uniform bool perFragBinormal = true;

// Height -------------------------------------------------------------
uniform int parallax_mode = 0;
uniform sampler2D heightMap;
uniform float heightMapScale = 1.0;
uniform float tessellationFactor = 4.0;
uniform float scalarZeroValue = 0.5;

// Emission -------------------------------------------------------------
uniform float emissionIntensity = 1.0;
uniform sampler2D emissionMap;
uniform bool sRGBEmission = true;

// Anisotropy -------------------------------------------------------------
uniform sampler2D anisotropyLevelMap;
uniform sampler2D anisotropyAngleMap;

// Sheen ---------------------------------------------------------------
uniform sampler2D sheenOpacityMap;
uniform sampler2D sheenColorMap;
uniform bool sRGBSheenColor = true;
uniform sampler2D sheenRoughnessMap;

// Coating -------------------------------------------------------------
uniform sampler2D coatOpacityMap;
uniform sampler2D coatColorMap;
uniform bool sRGBCoatColor = true;
uniform sampler2D coatSpecularLevelMap;
uniform sampler2D coatRoughnessMap;
uniform sampler2D coatNormalMap;
uniform float coatIoR;

// SSS -------------------------------------------------------------
uniform sampler2D sssDiffuseMap;
uniform sampler2D sssDepthMap;
uniform sampler2D translucencyMap;
uniform bool useScatteringColorChannel = false;
uniform sampler2D scatteringColorMap;
uniform bool sRGBScatteringColor = true;
uniform float scatteringDistance = 1.0;
uniform sampler2D scatteringDistanceScaleMap;
uniform bool sRGBScatteringDistanceScale = true;
uniform float sssRedShift;
uniform float sssRayleigh;

uniform sampler2D bluenoiseMask;
uniform samplerCube environmentMap;

uniform mat4 viewInverseMatrix;
uniform mat4 projectionMatrix;
uniform mat4 projectionInverseMatrix;

// Number of miplevels in the envmap
uniform float maxLod = 12.0;

// Actual number of samples in the table
uniform int nbSamples = 64;

// Irradiance spherical harmonics polynomial coefficients
// This is a color 2nd degree polynomial in (x,y,z), so it needs 10 coefficients
// for each color channel
uniform vec3 shCoefs[10];


// This must be included after the declaration of the uniform arrays since they
// can't be passed as functions parameters for performance reasons (on macs)
#include "../common/pbr_aniso_ibl.glsl"


vec4 getScatteringCoeffs(vec2 uv, bool disableFragment) {
	vec3 sss = get2DSample(scatteringDistanceScaleMap, uv, disableFragment, cDefaultColor.mScattering).rgb;
    if (sRGBScatteringDistanceScale)
        sss = srgb_to_linear(sss);
	sss *= scatteringDistance;
	return vec4(sss, sss == vec3(0.0) ? 0.0 : 1.0);
}

vec3 alg_convertSSSCoefficients(vec3 albedo, vec3 coeffs) {
	// Rayleigh & Red shift AXM model
	albedo = vec3(4.09712) + 4.20863 * albedo - sqrt(vec3(9.59217) + 41.68086 * albedo + 17.7126 * albedo * albedo);

	albedo = vec3(1.0) - albedo * albedo;
	// if 0 albedo = 0.00000571678414939477504803098729
	// if 1 albedo = 0.99999999992175670534572077351665

	float maxalbedo = max(max(albedo.r,albedo.g),albedo.b);
	albedo *= maxalbedo / max(albedo,maxalbedo/100.f);
	//if 1: maxalbedo/100.f = 0.00999999999921756705345720773517
	// if 1 albedo = 0.99999999992175670534572077351665 * 99.999999999999999999999999999965
	// if 0 albedo = 5.716784149394775048030987289998e-4
	albedo.rb *= vec2(1.0) + clamp(sssRayleigh,-1.0,2.0) * vec2(-0.493178, 0.899);

	if (sssRedShift!=0.0) {
		albedo.r *= pow(0.1,sssRedShift);
	}
	return coeffs / albedo;
	//return albedo;
	//return min(coeffs / albedo, vec3(1000));
	// if 0: return 1749.2351886433705535356255894875
}


// Samples distribution (approx. of sss_pdf)
float samples_pdf(float r, float d)
{
    return exp(-r / (3.0 * d)) / (6.0 * M_PI * d * r);
}

// Invert of the CDF of [samples_pdf * 2 * Pi * r] for importance sampling
float samples_icdf(float x, float d)
{
    return -3.0 * log(x) * d;
}

vec3 alg_sss_pdf(vec3 r, vec3 d) {
    d = max(vec3(1e-4), d);
    return (exp(-r / d) + exp(-r / (3.0 * d))) / max(vec3(1e-5), 8.0 * M_PI * d * r);
}

// Samples distribution (approx. of sss_pdf)
vec3 alg_samples_pdf(vec3 r, vec3 d) {
    d = max(vec3(1e-4), d);
    return exp(-r / (3.0 * d)) / (6.0 * M_PI * d * r);
}

// Invert of the CDF of [samples_pdf * 2 * Pi * r] for importance sampling
vec3 alg_samples_icdf(float x, vec3 d) {
    d = max(vec3(1e-4), d);
    return -3.0 * log(x) * d;
}

vec3 sssGetPosition(vec2 tex_coord)
{
    vec4 P = vec4(tex_coord, texture(sssDepthMap, tex_coord).x, 1.0);
    P.xyz = 2.0 * P.xyz - vec3(1.0);
    P = projectionInverseMatrix * P;
    return P.xyz / P.w;
}

vec3 alg_sssConvolve(vec4 d, float noise, vec2 tex_coord, vec3 prevDiffuse) {
	if (d.a <= 0.0)
		return prevDiffuse;

	vec3 currPos = sssGetPosition(tex_coord);
	mat2 projMat2d = mat2(projectionMatrix);
	{
		float dmax = max(max(d.x, d.y), d.z);
		float dz = dmax / -currPos.z;
		if (determinant(projMat2d) * dz < 1e-4)
			return prevDiffuse;
	}

	// Scale sample distribution with z
	vec3 dz = d.rgb / -currPos.z;

	vec3 X = vec3(0.0), W = vec3(0.0);
	for (int i = 0; i < 64; i++) {
		// Fibonacci spiral
		float r = (i + 0.5) / 64;
		float t = 2.0 * M_PI * (M_GOLDEN_RATIO * i + noise);
		vec3 icdf = alg_samples_icdf(r, dz);
		vec2 T = projMat2d * vec2(cos(t), sin(t));

		vec2 CoordsR = tex_coord + icdf.r * T;
		vec2 CoordsG = tex_coord + icdf.g * T;
		vec2 CoordsB = tex_coord + icdf.b * T;

		vec2 Dr = texture(sssDiffuseMap, CoordsR).ra;
		vec2 Dg = texture(sssDiffuseMap, CoordsG).ga;
		vec2 Db = texture(sssDiffuseMap, CoordsB).ba;

		// Re-weight samples with the scene 3D distance and SSS profile instead of 2D importance sampling weights
		// SSS mask in alpha
		vec3 dist = vec3(
			distance(currPos, sssGetPosition(CoordsR)),
			distance(currPos, sssGetPosition(CoordsG)),
			distance(currPos, sssGetPosition(CoordsB)));

		vec3 Weights = vec3(Dr.y, Dg.y, Db.y) * alg_sss_pdf(dist, d.rgb) / alg_samples_pdf(icdf, dz);
		X += Weights * vec3(Dr.x, Dg.x, Db.x);
		W += Weights;
	}

	return vec3(
		W.r < 1e-5 ? prevDiffuse.r : X.r / W.r,
		W.g < 1e-5 ? prevDiffuse.g : X.g / W.g,
		W.b < 1e-5 ? prevDiffuse.b : X.b / W.b);
}


// ---------------------------------------------------------------------
// Anisotropy.

//- Generate anisotropic roughness from roughness and anisotropy level
vec2 generateAnisotropicRoughnessASM(float roughness, float anisoLevel)
{
	float alphaU = min(1., roughness*roughness + pow(anisoLevel , 4.0));
	return vec2(sqrt(alphaU), roughness);
}


// ---------------------------------------------------------------------
// Coating.

float iorToSpecularLevel(float iorFrom, float iorTo)
{
	float sqrtR0 = (iorTo-iorFrom) / (iorTo+iorFrom);
	return sqrtR0*sqrtR0;
}

vec3 coat_passage_color_multiplier(vec3 coatColor, float coatOpacity, float ndv)
{
	if (min(coatColor.r, min(coatColor.g, coatColor.b)) < 1.0)
	{
		float power = 0.1575 / mix(0.24, 1.0, ndv * ndv) + 0.25;
		return pow(mix(vec3(1.0), coatColor, coatOpacity), vec3(power));
	}
	else
	{
		return vec3(1.);
	}
}

// ---------------------------------------------------------------------
// MOVE TO pbr_ibl.glsl
vec3 fresnel(
  float vdh,
  vec3 F0,
  vec3 F82)
{
  if (F82 == vec3(1.0)) {
    return fresnel(vdh, F0);
  }
  else {
    vec3 b = (1.0 - F82) * mix(F0, vec3(1.0), 0.462664366) / 0.0566527796;
    float one_minus_cos_theta = 1.0 - vdh;
    vec3 offset = (1.0 - F0 - b * vdh * one_minus_cos_theta) * pow(one_minus_cos_theta, 5.);
    return clamp(F0 + offset, 0.0, 1.0);
  }
}

vec3 cook_torrance_contrib(
  float vdh,
  float ndh,
  float ndl,
  float ndv,
  vec3 F0,
  vec3 F82,
  float roughness)
{
  // This is the contribution when using importance sampling with the GGX based
  // sample distribution. This means ct_contrib = ct_brdf / ggx_probability
  return fresnel(vdh, F0, F82) * (visibility(ndl, ndv, roughness) * vdh * ndl / ndh );
}

vec3 cook_torrance_contrib(
  float vdh,
  float ndh,
  vec3 localL,
  vec3 localE,
  vec3 F0,
  vec3 F82,
  vec2 alpha)
{
  // This is the contribution when using importance sampling with the GGX based
  // sample distribution. This means ct_contrib = ct_brdf / ggx_probability
  return fresnel(vdh, F0, F82) * (visibility(localL, localE, alpha) * vdh * localL.z / ndh);
}

//- Remove AO and shadows on glossy metallic surfaces (close to mirrors)
float specularOcclusionCorrection(float diffuseOcclusion, float metallic, float roughness)
{
  return mix(diffuseOcclusion, 1.0, metallic * (1.0 - roughness) * (1.0 - roughness));
}
// ---------------------------------------------------------------------


//- Compute the microfacets specular reflection to the viewer's eye
vec3 pbrComputeSpecular(
		samplerCube environmentMap,
		float envRotation,
		float maxLod,
		int nbSamples,
		vec3 normalWS,
		vec3 fixedNormalWS,
		vec3 Tp,
		vec3 Bp,
		vec3 pointToCameraDirWS,
		vec3 F0,
		vec3 F82,
		float roughness)
{

	vec3 radiance = vec3(0.0);
	float ndv = dot(pointToCameraDirWS, fixedNormalWS);

	for(int i=0; i<nbSamples; ++i)
	{
    vec2 Xi = fibonacci2D(i, nbSamples);
    vec3 Hn = importanceSampleGGX(
      Xi, Tp, Bp, fixedNormalWS, roughness);
    vec3 Ln = -reflect(pointToCameraDirWS,Hn);

    float fade = horizonFading(dot(normalWS, Ln));

    float ndl = dot(fixedNormalWS, Ln);
    ndl = max( 1e-8, ndl );
    float vdh = max(1e-8, dot(pointToCameraDirWS, Hn));
    float ndh = max(1e-8, dot(fixedNormalWS, Hn));
    float lodS = roughness < 0.01 ? 0.0 : computeLOD(Ln, probabilityGGX(ndh, vdh, roughness), nbSamples, maxLod);
    radiance += fade * sampleCubemapLOD(environmentMap,rotate(Ln,envRotation),lodS) *
      cook_torrance_contrib(vdh, ndh, ndl, ndv, F0, F82, roughness);
  }
  // Remove occlusions on shiny reflections
  radiance /= float(nbSamples);

  return radiance;
}

vec3 pbrComputeSpecularAnisotropic(
		samplerCube environmentMap,
		float envRotation,
		float maxLod,
		int nbSamples,
		vec3 normalWS,
		vec3 fixedNormalWS,
		vec3 Tp,
		vec3 Bp,
		vec3 pointToCameraDirWS,
		vec3 F0,
		vec3 F82,
		vec2 roughness,
		float noise)
{

	vec3 radiance = vec3(0.0);
	vec2 alpha = roughness * roughness;
	mat3 TBN = mat3(Tp, Bp, fixedNormalWS);;
	vec3 localV = pointToCameraDirWS * TBN;

  for(int i=0; i<nbSamples; ++i)
  {
    vec2 Xi = fibonacci2D(i, nbSamples);
	Xi.x += noise;	
    vec3 localH = importanceSampleGGX(Xi, alpha);
    vec3 localL = reflect(-localV, localH);

    if (localL.z > 0.0)
    {
      vec3 Ln = TBN * localL;
      float vdh = max(1e-8, dot(localV, localH));

      float fade = horizonFading(dot(normalWS, Ln));
      float pdf = probabilityGGX(localH, vdh, alpha);
      float lodS = max(roughness.x, roughness.y) < 0.01 ? 0.0 : computeLOD(Ln, pdf, nbSamples, maxLod);
      // Offset lodS to trade bias for more noise
      lodS -= 1.0;
      vec3 preconvolvedSample = sampleCubemapLOD(environmentMap,rotate(Ln,envRotation),lodS);

      radiance +=
        fade * cook_torrance_contrib(vdh, localH.z, localL, localV, F0, F82, alpha) *
        preconvolvedSample;
    }
  }
  
  return radiance / float(nbSamples);
}

// ---------------------------------------------------------------------
// Microflake sheen
vec3 sheen_contrib(float ndh, float ndl, float ndv, vec3 Ks, float roughness)
{
	float ndh2 = ndh*ndh;
	float ndl2 = ndl*ndl;
	float ndv2 = ndv*ndv;
	float r2 = roughness*roughness;

	// TODO: move the D component out, to the importance sampling.
	float t = 1.0 - ndh2 + ndh2/r2;
	float Pi_D = 1.0 / (roughness * t * t);

	float Li = sqrt(1.0 - ndl2 + r2*ndl2) / ndl;
	float Lo = sqrt(1.0 - ndv2 + r2*ndv2) / ndv;
	float G = (1.0 - exp(-(Li + Lo))) / (Li + Lo);

	// This is the contribution when using importance sampling with uniform
	// sample distribution. This means sheen_contrib = sheen_brdf / (1/(2*Pi))
	// ndl is omitted since it cancels out with the ndl outside the BRDF.
	return Ks * ((2.0 * Pi_D * G / ndv) * 0.5);
}

vec3 uniformSample(vec2 Xi, vec3 T, vec3 B, vec3 N)
{
	float cosT = Xi.y;
	float sinT = sqrt(1.0-cosT*cosT);
	float phi = 2.0*M_PI*Xi.x;
	return
		T * (sinT*cos(phi)) +
		B * (sinT*sin(phi)) +
		N *  cosT;
}

vec3 pbrComputeSheen(
		samplerCube environmentMap,
		float envRotation,
		float maxLod,
		int nbSamples,
		vec3 vertexNormal,
		vec3 normal,
		vec3 tangent,
		vec3 binormal,
		vec3 pointToCameraDirWS,
		vec3 specColor,
		float roughness)
{
	vec3 radiance = vec3(0.0);
	float ndv = dot(pointToCameraDirWS, normal);
	roughness = max(1e-3, roughness);

	for(int i=0; i<nbSamples; ++i)
	{
		vec2 Xi = fibonacci2D(i, nbSamples);
		vec3 Ln = uniformSample(Xi, tangent, binormal, normal);
		vec3 Hn = normalize(Ln + pointToCameraDirWS);
		float fade = horizonFading(dot(vertexNormal, Ln));

		float ndl = dot(normal, Ln);
		if (ndl > 0.0 && ndv > 0.0) {
			ndl = max( 1e-8, ndl );
			float vdh = max(1e-8, dot(pointToCameraDirWS, Hn));
			float ndh = max(1e-8, dot(normal, Hn));
			float lodS = computeLOD(Ln, 0.5 * M_INV_PI, nbSamples, maxLod);
			radiance += fade * sampleCubemapLOD(environmentMap,rotate(Ln,envRotation),lodS) * sheen_contrib(ndh, ndl, ndv, specColor, roughness);
		}
	}
	radiance /= float(nbSamples);

	return radiance;
}

void main()
{
	vec3 normalWS = iFS_Normal;
	vec3 tangentWS = iFS_Tangent;
	vec3 binormalWS = perFragBinormal ?
		fixBinormal(normalWS,tangentWS,iFS_Binormal) : iFS_Binormal;

	vec3 cameraPosWS = viewInverseMatrix[3].xyz;

	vec3 pointToCameraDirWS = normalize(cameraPosWS - iFS_PointWS);

	// ------------------------------------------
	// Parallax
	vec2 uvScale = vec2(1.0);
	if (uvwScaleEnabled)
		uvScale = uvwScale.xy;
	vec2 uv = parallax_mode == 1 ? iFS_UV*tiling*uvScale : updateUV(
		heightMap,
		pointToCameraDirWS,
		normalWS, tangentWS, binormalWS,
		heightMapScale,
		iFS_UV,
		uvScale,
		tiling);

	uv = uv / (tiling * uvScale);
	bool disableFragment = hasToDisableFragment(uv);
	uv = uv * tiling * uvScale;
	uv = getUDIMTileUV(uv);

	// ------------------------------------------
	// Add Normal from normalMap
	vec3 fixedNormalWS = normalWS;  // HACK for empty normal textures
	vec3 normalTS = get2DSample(normalMap, uv, disableFragment, cDefaultColor.mNormal).xyz;
	if(length(normalTS)>0.0001)
	{
		normalTS = fixNormalSample(normalTS,flipY);
		fixedNormalWS = normalize(
			normalTS.x*tangentWS +
			normalTS.y*binormalWS +
			normalTS.z*normalWS );
	}
	
	// Trick to remove black artifacts
	// Backface ? place the eye at the opposite - removes black zones
	if (dot(pointToCameraDirWS, fixedNormalWS) < 0.0) {
		pointToCameraDirWS = reflect(pointToCameraDirWS, fixedNormalWS);
	}

	// ------------------------------------------
	// Compute material model (diffuse, specular & roughness)

	// Convert the base color from sRGB to linear (we should have done this when
	// loading the texture but there is no way to specify which colorspace is
	// uѕed for a given texture in Designer yet)
	vec3 baseColor = get2DSample(baseColorMap, uv, disableFragment, cDefaultColor.mBaseColor).rgb;
	if (sRGBBaseColor)
		baseColor = srgb_to_linear(baseColor);
	float baseRoughness = get2DSample(roughnessMap, uv, disableFragment, cDefaultColor.mRoughness).r;

	float anisotropyLevel = 0.0;
	float anisotropyAngle = 0.0;
	anisotropyLevel = get2DSample(anisotropyLevelMap, uv, disableFragment, cDefaultColor.mAnisotropyLevel).r;
	if (anisotropyLevel > 0.0) {
		anisotropyAngle = -1.0 * getAnisotropyAngleSample(anisotropyAngleMap, uv, disableFragment, cDefaultColor.mAnisotropyAngle.x);
	}
	
	float metallic = get2DSample(metallicMap, uv, disableFragment, cDefaultColor.mMetallic).r;	
	
	vec3 diffColor = baseColor * (1.0 - metallic);
	float specularLevel = get2DSample(specularLevelMap, uv, disableFragment, cDefaultColor.mSpecularLevel).r;
	vec3 specColor_metal = baseColor;	
	float dielectricF0 = iorToSpecularLevel(1.0, specularIoR);	
	float coatOpacity = get2DSample(coatOpacityMap, uv, disableFragment, cDefaultColor.mCoatWeight).r;
	if (coatOpacity > 0.0) {
		dielectricF0 = mix(dielectricF0, iorToSpecularLevel(coatIoR, specularIoR), coatOpacity);
	}
	vec3 specColor_dielectric = vec3(dielectricF0 * 2.0 * specularLevel);	

	float occlusion = get2DSample(aoMap, uv, disableFragment, cDefaultColor.mAO).r;
	float specOcclusion = specularOcclusionCorrection(occlusion, metallic, baseRoughness);

	float noise = texelFetch(bluenoiseMask, ivec2(gl_FragCoord.xy) & ivec2(0xFF), 0).x;

	// Emission DF:
	vec3 emissionContrib = get2DSample(emissionMap, uv, disableFragment, cDefaultColor.mEmissive).rgb;
	if (sRGBEmission)
		emissionContrib = srgb_to_linear(emissionContrib);
	emissionContrib = emissionContrib * emissionIntensity;
	
	// Specular lobes:
	// The specs can be interpreted as interpolating between two lobes.
	// However, due to the prohibitive cost for real-time, we interpolate
	// between two specular colors and use it for a single specular lobe.
	vec3 specColor = mix(specColor_dielectric, specColor_metal, metallic);
	vec3 specSecondaryColor = get2DSample(specularEdgeColorMap, uv, disableFragment, cDefaultColor.mSpecularEdgeColor).rgb;
    if (sRGBSpecularEdgeColor)
        specSecondaryColor = srgb_to_linear(specSecondaryColor);
	vec3 specEdgeColor = mix(vec3(1.0), specSecondaryColor, metallic);
	vec3 specColoring = mix(vec3(1.0), specSecondaryColor, 1.0 - metallic);
	vec3 specReflection = vec3(0.0);
	
	vec3 Tp,Bp;
	computeSamplingFrame(iFS_Tangent, iFS_Binormal, fixedNormalWS, anisotropyAngle, Tp, Bp);	

	if (anisotropyLevel != 0.0) {
		vec2 roughnessAniso = generateAnisotropicRoughnessASM(baseRoughness, anisotropyLevel);
		specReflection = pbrComputeSpecularAnisotropic(	environmentMap,
														envRotation,
														maxLod,
														nbSamples,
														normalWS,
														fixedNormalWS,
														Tp,
														Bp,								
														pointToCameraDirWS,
														specColor,
														specEdgeColor,
														roughnessAniso,
														noise);
	}
	else {
		specReflection = pbrComputeSpecular(	environmentMap,
												envRotation,
												maxLod,
												nbSamples,
												normalWS,
												fixedNormalWS,
												Tp,
												Bp,
												pointToCameraDirWS,
												specColor,
												specEdgeColor,
												baseRoughness);
	}
	
	vec3 specularShading = specOcclusion * specColoring * specReflection * AmbiIntensity;
						
	// Sheen:
	float sheenOpacity = get2DSample(sheenOpacityMap, uv, disableFragment, cDefaultColor.mSheenOpacity).r;
	vec3 sheenShading = vec3(0.0);
	if (sheenOpacity > 0.0) {
		float sheenRoughness = get2DSample(sheenRoughnessMap, uv, disableFragment, cDefaultColor.mSheenRoughness).r;
		vec3 sheenColor = get2DSample(sheenColorMap, uv, disableFragment, cDefaultColor.mSheenColor).rgb;
        if (sRGBSheenColor)
            sheenColor = srgb_to_linear(sheenColor);
		sheenColor = sheenOpacity * sheenColor;
		sheenShading = pbrComputeSheen	(	environmentMap,
											envRotation,
											maxLod,
											nbSamples,									
											normalWS,
											fixedNormalWS,
											Tp,
											Bp,
											pointToCameraDirWS,
											sheenColor,
											sheenRoughness);
		specularShading += specOcclusion * sheenShading * AmbiIntensity;
	}

	// Subsurface Scattering	
	vec2 tex_coord = gl_FragCoord.xy / vec2(textureSize(sssDiffuseMap, 0).xy);
    vec3 diffuseShading = texture(sssDiffuseMap, tex_coord).rgb;	
	
	vec3 diffuseContrib = vec3(0.0);
	vec4 defaultTranslucency = vec4(0.0);
	float translucency = get2DSample(translucencyMap, uv, disableFragment, cDefaultColor.mTranslucency).r;

	if (translucency > 0) {
		vec3 sssAlbedo =  diffColor; //use diffColor or scatterColor depending on a parameter "Use Base Color as Scattering Color" true by default 
			if (useScatteringColorChannel){
				sssAlbedo = get2DSample(scatteringColorMap, uv, disableFragment, cDefaultColor.mScattering).rgb;
				if (sRGBScatteringColor)
					sssAlbedo = srgb_to_linear(sssAlbedo);
			}
		vec4 sssCoeffs = getScatteringCoeffs(uv, disableFragment);	
		sssCoeffs.rgb = alg_convertSSSCoefficients(sssAlbedo, sssCoeffs.rgb);
		vec3 sss = alg_sssConvolve(sssCoeffs, 0.0, tex_coord, diffuseShading);
		diffuseContrib = sssAlbedo * alg_sssConvolve(sssCoeffs, noise, tex_coord, diffuseShading);
	}
	
	// Coating:
	if (coatOpacity > 0.0) {
		vec3 coatFixedNormalWS = normalWS;  // HACK for empty normal textures
		vec3 coatNormalTS = get2DSample(coatNormalMap, uv, disableFragment, cDefaultColor.mNormal).xyz;
		if(length(coatNormalTS)>0.0001)
		{
			coatNormalTS = fixNormalSample(coatNormalTS,flipY);
			coatFixedNormalWS = normalize(
				coatNormalTS.x*tangentWS +
				coatNormalTS.y*binormalWS +
				coatNormalTS.z*normalWS );
		}
		
		// Trick to remove black artifacts
		// Backface ? place the eye at the opposite - removes black zones
		if (dot(pointToCameraDirWS, coatFixedNormalWS) < 0.0) {
			pointToCameraDirWS = reflect(pointToCameraDirWS, coatFixedNormalWS);
		}

		vec3 coatColor = get2DSample(coatColorMap, uv, disableFragment, cDefaultColor.mCoatColor).rgb;
        if (sRGBCoatColor)
            coatColor = srgb_to_linear(coatColor);		
		
		float coatSpecularLevel = get2DSample(coatSpecularLevelMap, uv, disableFragment, cDefaultColor.mSpecularLevel).r;
		vec3 coatSpecColor = vec3(iorToSpecularLevel(1.0, coatIoR) * 2.0 * coatSpecularLevel);

		float coatRoughness = get2DSample(coatRoughnessMap, uv, disableFragment, cDefaultColor.mRoughness).r;
		float coatSpecOcclusion = specularOcclusionCorrection(occlusion, 0.0, coatRoughness);
		
		computeSamplingFrame(tangentWS, binormalWS, coatFixedNormalWS, 0.0, Tp, Bp);	

		vec3 coatSpecularShading = coatSpecOcclusion *
			pbrComputeSpecular(	environmentMap,
								envRotation,
								maxLod,
								nbSamples,
								normalWS,
								coatFixedNormalWS,
								Tp,
								Bp,
								pointToCameraDirWS,
								coatSpecColor,
								vec3(1.0),
								coatRoughness);

		vec3 coatAbsorption = coat_passage_color_multiplier(coatColor, coatOpacity, clamp(dot(coatFixedNormalWS, pointToCameraDirWS), 1e-4, 1.0));
		coatAbsorption *= coatAbsorption;

		diffuseShading *= coatAbsorption;
		specularShading *= coatAbsorption;
		specularShading += coatSpecularShading * coatOpacity * AmbiIntensity;
	}	
	
	vec3 finalColor = mix(diffuseShading*diffColor, diffuseContrib, translucency) + specularShading + emissionContrib;

	float opacity = get2DSample(opacityMap, uv, disableFragment, cDefaultColor.mOpacity).r;
	ocolor0 = vec4(finalColor, opacity);						 
}
