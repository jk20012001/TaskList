//该文件在stdafx.h里包含

#define CCProgram class
#define layout struct

//所有的宏
#define CC_DEVICE_SUPPORT_FLOAT_TEXTURE 1
#define CC_DEVICE_MAX_FRAGMENT_UNIFORM_VECTORS 1024
#define CC_DEVICE_MAX_VERTEX_UNIFORM_VECTORS 1024
#define CC_EFFECT_USED_VERTEX_UNIFORM_VECTORS 128
#define CC_EFFECT_USED_FRAGMENT_UNIFORM_VECTORS 128
#define CC_DEVICE_CAN_BENEFIT_FROM_INPUT_ATTACHMENT 0
#define CC_ENABLE_CLUSTERED_LIGHT_CULLING 0
#define CC_USE_MORPH 1
#define CC_MORPH_TARGET_COUNT 2
#define CC_MORPH_PRECOMPUTED 1
#define CC_MORPH_TARGET_HAS_POSITION 1
#define CC_MORPH_TARGET_HAS_NORMAL 1
#define CC_MORPH_TARGET_HAS_TANGENT 1
#define CC_USE_SKINNING 1
#define CC_USE_BAKED_ANIMATION 1
#define USE_INSTANCING 1
#define USE_BATCHING 1
#define USE_LIGHTMAP 1
#define CC_USE_FOG 0
#define CC_FORWARD_ADD 1
#define CC_RECEIVE_SHADOW 1
#define USE_VERTEX_COLOR 1
#define USE_NORMAL_MAP 1
#define HAS_SECOND_UV 1
#define USE_TWOSIDE 1
#define SAMPLE_FROM_RT 1
#define CC_USE_IBL 1
#define CC_USE_DIFFUSEMAP 1
#define CC_ENABLE_DIR_SHADOW 1
#define CC_USE_HDR 1
#define USE_ALBEDO_MAP 1
#define ALBEDO_UV v_uv
#define NORMAL_UV v_uv
#define PBR_UV v_uv
#define USE_PBR_MAP 1
#define USE_METALLIC_ROUGHNESS_MAP 1
#define USE_OCCLUSION_MAP 1
#define USE_EMISSIVE_MAP 1
#define EMISSIVE_UV v_uv
#define USE_ALPHA_TEST 1
#define ALPHA_TEST_CHANNEL a
#define CC_PIPELINE_TYPE 0
#define CC_FORCE_FORWARD_SHADING 1

//所有的头文件

#include "editor\assets\chunks\aces.h"
#include "editor\assets\chunks\alpha-test.h"
#include "editor\assets\chunks\anti-aliasing.h"
#include "editor\assets\chunks\cc-diffusemap.h"
#include "editor\assets\chunks\cc-environment.h"
#include "editor\assets\chunks\cc-fog-base.h"
#include "editor\assets\chunks\cc-fog-fs.h"
#include "editor\assets\chunks\cc-fog-vs.h"
#include "editor\assets\chunks\cc-forward-light.h"
#include "editor\assets\chunks\cc-global.h"
#include "editor\assets\chunks\cc-local-batch.h"
#include "editor\assets\chunks\cc-local.h"
#include "editor\assets\chunks\cc-shadow-map-base.h"
#include "editor\assets\chunks\cc-shadow-map-fs.h"
#include "editor\assets\chunks\cc-shadow-map-vs.h"
#include "editor\assets\chunks\cc-shadow.h"
#include "editor\assets\chunks\cc-skinning.h"
#include "editor\assets\chunks\cc-sprite-common.h"
#include "editor\assets\chunks\cc-sprite-fs-gpu.h"
#include "editor\assets\chunks\cc-sprite-texture.h"
#include "editor\assets\chunks\cc-sprite-vs-gpu.h"
#include "editor\assets\chunks\cc-world-bound.h"
#include "editor\assets\chunks\common.h"
#include "editor\assets\chunks\decode-base.h"
#include "editor\assets\chunks\decode-standard.h"
#include "editor\assets\chunks\decode.h"
#include "editor\assets\chunks\deprecated.h"
#include "editor\assets\chunks\embedded-alpha.h"
#include "editor\assets\chunks\fxaa.h"
#include "editor\assets\chunks\gamma.h"
#include "editor\assets\chunks\general-vs.h"
#include "editor\assets\chunks\input-standard.h"
#include "editor\assets\chunks\input.h"
#include "editor\assets\chunks\lighting.h"
#include "editor\assets\chunks\lightingmap-fs.h"
#include "editor\assets\chunks\lightingmap-vs.h"
#include "editor\assets\chunks\morph.h"
#include "editor\assets\chunks\outline-fs.h"
#include "editor\assets\chunks\outline-vs.h"
#include "editor\assets\chunks\output-standard.h"
#include "editor\assets\chunks\output.h"
#include "editor\assets\chunks\packing.h"
#include "editor\assets\chunks\particle-common.h"
#include "editor\assets\chunks\particle-trail.h"
#include "editor\assets\chunks\particle-vs-gpu.h"
#include "editor\assets\chunks\particle-vs-legacy.h"
#include "editor\assets\chunks\rect-area-light.h"
#include "editor\assets\chunks\shading-cluster-additive.h"
#include "editor\assets\chunks\shading-standard-additive.h"
#include "editor\assets\chunks\shading-standard-base.h"
#include "editor\assets\chunks\shading-standard.h"
#include "editor\assets\chunks\shading-toon.h"
#include "editor\assets\chunks\skinning-dqs.h"
#include "editor\assets\chunks\skinning-lbs.h"
#include "editor\assets\chunks\standard-surface-entry.h"
#include "editor\assets\chunks\texture-lod.h"
#include "editor\assets\chunks\transform.h"
#include "editor\assets\chunks\unpack.h"
#include "editor\assets\chunks\forcompiler\input-standard.h"
#include "editor\assets\chunks\forcompiler\packing.h"
#include "editor\assets\chunks\legacy\standard-surface-header.h"
#include "editor\assets\chunks\legacy\standard-surface-main.h"