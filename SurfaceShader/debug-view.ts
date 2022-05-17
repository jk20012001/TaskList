/*
 Copyright (c) 2020 Xiamen Yaji Software Co., Ltd.

 https://www.cocos.com/

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated engine source code (the "Software"), a limited,
 worldwide, royalty-free, non-assignable, revocable and non-exclusive license
 to use Cocos Creator solely to develop games on your target platforms. You shall
 not use Cocos Creator software for developing other software or tools that's
 used for developing games. You are not granted to publish, distribute,
 sublicense, and/or sell copies of Cocos Creator.

 The software or tools in this License Agreement are licensed, not sold.
 Xiamen Yaji Software Co., Ltd. reserves all rights not expressly granted to you.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import { JSB } from 'internal:constants';
import { builtinResMgr } from '../../builtin';
import { Material } from '../../assets/material';
import { Mesh } from '../../../3d/assets/mesh';
import { TextureCube } from '../../assets/texture-cube';
import { UNIFORM_ENVIRONMENT_BINDING, UNIFORM_DIFFUSEMAP_BINDING } from '../../pipeline/define';
import { MaterialInstance } from '../core/material-instance';
import { Model } from './model';
import { legacyCC } from '../../global-exports';
import type { SkyboxInfo } from '../../scene-graph/scene-globals';
import { Root } from '../../root';
import { NaitveSkybox } from '../native-scene';
import { GlobalDSManager } from '../../pipeline/global-descriptor-set-manager';
import { Device } from '../../gfx';
import { Enum } from '../../value-types';

// export const DebugViewSingleType = Enum({
const enum DebugViewSingleType {
    /**
     * @zh
     * 半球漫反射
     * @en
     * hemisphere diffuse
     * @readonly
     */
    NONE,
    VERTEX_COLOR,
    VERTEX_NORMAL,
    VERTEX_TANGENT,
    WORLD_POS,
    VERTEX_MIRROR,
    FACE_SIDE,
    UV0,
    UV1,
    UV_LIGHTMAP,
    PROJ_DEPTH,
    LINEAR_DEPTH,
    
    FRAGMENT_NORMAL,
    FRAGMENT_TANGENT,
    FRAGMENT_BINORMAL,
    BASE_COLOR,
    DIFFUSE_COLOR,
    SPECULAR_COLOR,
    TRANSPARENCY,
    METALLIC,
    ROUGHNESS,
    SPECULAR_INTENSITY,
    
    DIRECT_DIFFUSE,
    DIRECT_SPECULAR,
    DIRECT_ALL,
    ENV_DIFFUSE,
    ENV_SPECULAR,
    ENV_ALL,
    EMISSIVE,
    LIGHT_MAP,
    SHADOW,
    AO,
    
    FOG,
};

const enum DebugViewCompositeType {
    /**
     * @zh
     * 半球漫反射
     * @en
     * hemisphere diffuse
     * @readonly
     */
     DIRECT_DIFFUSE,
     DIRECT_SPECULAR,
     ENV_DIFFUSE,
     ENV_SPECULAR,
     EMISSIVE,
     LIGHT_MAP,
     SHADOW,
     AO,
     
     NORMAL_MAP,
     FOG,
     
     TONE_MAPPING,
     GAMMA_CORRECTION,
};

/**
 * @en The skybox configuration of the render scene,
 * currently some rendering options like hdr and ibl lighting configuration is also here.
 * @zh 渲染场景的天空盒配置，目前一些渲染配置，比如 HDR 模式和环境光照配置也在 Skybox 中。
 */
export class DebugView {

    /**
     * @en The texture cube used diffuse convolution map
     * @zh 使用的漫反射卷积图
     */
    isCompositeModeEnabled(val : DebugViewCompositeType) : boolean {
        const mode = this._compositeModeValue & (1 << val);
        return mode !== 0;
    }
    enableCompositeMode(val : DebugViewCompositeType) {
        this._compositeModeValue = this._compositeModeValue | (1 << val);
    }

    get singleMode () : DebugViewSingleType {
        return this._singleModeValue;
    }
    set singleMode (val : DebugViewSingleType) {
        this._singleModeValue = val;
    }

    get lightingWithAlbedo () : boolean {
        return this._lightingWithAlbedo;
    }
    set lightingWithAlbedo (val : boolean) {
        this._lightingWithAlbedo = val;
    }

    get csmLayerColoration () : boolean {
        return this._csmLayerColoration;
    }
    set csmLayerColoration (val : boolean) {
        this._csmLayerColoration = val;
    }

    protected _singleModeValue = 0;
    protected _compositeModeValue = 0;
    protected _lightingWithAlbedo = true;
    protected _csmLayerColoration = false;
    // protected declare _nativeObj: NaitveDebugView | null;

    /**
     * @internal
     */
    get native (): NaitveSkybox {
        return this._nativeObj!;
    }

    constructor () {
        if (JSB) {
            this._nativeObj = new NaitveSkybox();
        }
    }

    private _setEnabled (val) {
        this._enabled = val;
        if (JSB) {
            this._nativeObj!.enabled = val;
        }
    }

    private _setUseDiffuseMap (val) {
        this._useDiffuseMap = val;
        if (JSB) {
            this._nativeObj!.useDiffuseMap = val;
        }
    }

    public initialize (skyboxInfo: SkyboxInfo) {
        this._setEnabled(skyboxInfo.enabled);
        this._setUseIBL(skyboxInfo.useIBL);
        this._setUseDiffuseMap(skyboxInfo.applyDiffuseMap);
        this._setUseHDR(skyboxInfo.useHDR);
    }

    /**
     * @en Set the environment maps for HDR and LDR mode
     * @zh 为 HDR 和 LDR 模式设置环境贴图
     * @param envmapHDR @en Environment map for HDR mode @zh HDR 模式下的环境贴图
     * @param envmapLDR @en Environment map for LDR mode @zh LDR 模式下的环境贴图
     */
    public setEnvMaps (envmapHDR: TextureCube | null, envmapLDR: TextureCube | null) {
        this._envmapHDR = envmapHDR;
        this._envmapLDR = envmapLDR;

        this._updateGlobalBinding();
        this._updatePipeline();
    }

    public activate () {
        const pipeline = legacyCC.director.root.pipeline;
        this._globalDSManager = pipeline.globalDSManager;
        this._default = builtinResMgr.get<TextureCube>('default-cube-texture');

        if (!this._model) {
            this._model = legacyCC.director.root.createModel(legacyCC.renderer.scene.Model) as Model;
            // @ts-expect-error private member access
            this._model._initLocalDescriptors = () => {};
            // @ts-expect-error private member access
            this._model._initWorldBoundDescriptors = () => {};
            if (JSB) {
                this._nativeObj!.model = this._model.native;
            }
        }
        let isRGBE = this._default.isRGBE;
        if (this.envmap) {
            isRGBE = this.envmap.isRGBE;
        }

        if (!skybox_material) {
            const mat = new Material();
            mat.initialize({ effectName: 'skybox', defines: { USE_RGBE_CUBEMAP: isRGBE } });
            skybox_material = new MaterialInstance({ parent: mat });
        }

        if (this.enabled) {
            if (!skybox_mesh) {
                skybox_mesh = legacyCC.utils.createMesh(legacyCC.primitives.box({ width: 2, height: 2, length: 2 })) as Mesh;
            }
            this._model.initSubModel(0, skybox_mesh.renderingSubMeshes[0], skybox_material);
        }

        if (!this.envmap) {
            this.envmap = this._default;
        }

        if (!this.diffuseMap) {
            this.diffuseMap = this._default;
        }

        this._updateGlobalBinding();
        this._updatePipeline();
    }

    protected _updatePipeline () {
        //注意一旦进入过调试模式，就不要再关掉此宏了，永远都是调试模式直到重启编辑器
        if (JSB) {
            this._nativeObj!.isRGBE = this.isRGBE;
        }

        const root = legacyCC.director.root as Root;
        const pipeline = root.pipeline;

        const useIBLValue = this.useIBL ? (this.isRGBE ? 2 : 1) : 0;
        const useDiffuseMapValue = (this.useIBL && this.useDiffuseMap && this.diffuseMap) ? (this.isRGBE ? 2 : 1) : 0;
        const useHDRValue = this.useHDR;

        if (pipeline.macros.CC_USE_IBL !== useIBLValue
            || pipeline.macros.CC_USE_DIFFUSEMAP !== useDiffuseMapValue
            || pipeline.macros.CC_USE_HDR !== useHDRValue) {
            pipeline.macros.CC_USE_IBL = useIBLValue;
            pipeline.macros.CC_USE_DIFFUSEMAP = useDiffuseMapValue;
            pipeline.macros.CC_USE_HDR = useHDRValue;

            root.onGlobalPipelineStateChanged();
        }

        if (this.enabled && skybox_material) {
            skybox_material.recompileShaders({ USE_RGBE_CUBEMAP: this.isRGBE });
        }

        if (this._model) {
            this._model.setSubModelMaterial(0, skybox_material!);
        }
    }

    protected _updateGlobalBinding () {
        if (this._globalDSManager) {
            const device = legacyCC.director.root.device as Device;

            const envmap = this.envmap ? this.envmap : this._default;
            if (envmap) {
                const texture = envmap.getGFXTexture()!;
                const sampler = device.getSampler(envmap.getSamplerInfo());
                this._globalDSManager.bindSampler(UNIFORM_ENVIRONMENT_BINDING, sampler);
                this._globalDSManager.bindTexture(UNIFORM_ENVIRONMENT_BINDING, texture);
            }

            const diffuseMap = this.diffuseMap ? this.diffuseMap : this._default;
            if (diffuseMap) {
                const texture = diffuseMap.getGFXTexture()!;
                const sampler = device.getSampler(diffuseMap.getSamplerInfo());
                this._globalDSManager.bindSampler(UNIFORM_DIFFUSEMAP_BINDING, sampler);
                this._globalDSManager.bindTexture(UNIFORM_DIFFUSEMAP_BINDING, texture);
            }

            this._globalDSManager.update();
        }
    }

    protected _destroy () {
        if (JSB) {
            this._nativeObj = null;
        }
    }

    public destroy () {
        this._destroy();
    }
}

legacyCC.DebugView = DebugView;

  // define.ts: 增加PipelineGlobalBindings.UBO_DEBUGVIEW, cc_shadowMap / cc_spotLightingMap / cc_environment / cc_diffuseMap的binding加1
/**
 * @en The uniform buffer object for debug view
 * @zh 渲染调试 UBO。
 */
export class UBODebugView {
    public static readonly SINGLE_MODE = 0;
    public static readonly LIGHTING_ENABLE_WITH_ALBEDO = UBODebugView.SINGLE_MODE + 1;
    public static readonly MISC_ENABLE_CSM_LAYER_COLORATION = UBODebugView.LIGHTING_ENABLE_WITH_ALBEDO + 1;
    public static readonly COMPOSITE_ENABLE_DIRECT_DIFFUSE = UBODebugView.MISC_ENABLE_CSM_LAYER_COLORATION + 1;
    public static readonly COMPOSITE_ENABLE_DIRECT_SPECULAR = UBODebugView.COMPOSITE_ENABLE_DIRECT_DIFFUSE + 1;
    public static readonly COMPOSITE_ENABLE_ENV_DIFFUSE = UBODebugView.COMPOSITE_ENABLE_DIRECT_SPECULAR + 1;
    public static readonly COMPOSITE_ENABLE_ENV_SPECULAR = UBODebugView.COMPOSITE_ENABLE_ENV_DIFFUSE + 1;
    public static readonly COMPOSITE_ENABLE_EMISSIVE = UBODebugView.COMPOSITE_ENABLE_ENV_SPECULAR + 1;
    public static readonly COMPOSITE_ENABLE_LIGHT_MAP = UBODebugView.COMPOSITE_ENABLE_EMISSIVE + 1;
    public static readonly COMPOSITE_ENABLE_SHADOW = UBODebugView.COMPOSITE_ENABLE_LIGHT_MAP + 1;
    public static readonly COMPOSITE_ENABLE_AO = UBODebugView.COMPOSITE_ENABLE_SHADOW + 1;
    public static readonly COMPOSITE_ENABLE_NORMAL_MAP = UBODebugView.COMPOSITE_ENABLE_AO + 1;
    public static readonly COMPOSITE_ENABLE_FOG = UBODebugView.COMPOSITE_ENABLE_NORMAL_MAP + 1;
    public static readonly COMPOSITE_ENABLE_TONE_MAPPING = UBODebugView.COMPOSITE_ENABLE_FOG + 1;
    public static readonly COMPOSITE_ENABLE_GAMMA_CORRECTION = UBODebugView.COMPOSITE_ENABLE_TONE_MAPPING + 1;
    public static readonly COUNT : number = UBODebugView.COMPOSITE_ENABLE_GAMMA_CORRECTION + 1;
    public static readonly SIZE = UBODebugView.COUNT * 4;
    public static readonly NAME = 'CCDebugView';
    public static readonly BINDING = PipelineGlobalBindings.UBO_DEBUGVIEW;
    public static readonly DESCRIPTOR = new DescriptorSetLayoutBinding(UBODebugView.BINDING, DescriptorType.UNIFORM_BUFFER, 1, ShaderStageFlagBit.ALL);
    public static readonly LAYOUT = new UniformBlock(SetIndex.GLOBAL, UBODebugView.BINDING, UBODebugView.NAME, [
        new Uniform('cc_debug_view_single_mode', Type.INT, 1),
        new Uniform('cc_debug_view_lighting_enable_with_albedo', Type.FLOAT, 1),
        new Uniform('cc_debug_view_misc_enable_csm_layer_coloration', Type.FLOAT, 1),
        new Uniform('cc_debug_view_composite_enable_direct_diffuse', Type.FLOAT, 1),
        new Uniform('cc_debug_view_composite_enable_direct_specular', Type.FLOAT, 1),
        new Uniform('cc_debug_view_composite_enable_env_diffuse', Type.FLOAT, 1),
        new Uniform('cc_debug_view_composite_enable_env_specular', Type.FLOAT, 1),
        new Uniform('cc_debug_view_composite_enable_emissive', Type.FLOAT, 1),
        new Uniform('cc_debug_view_composite_enable_light_map', Type.FLOAT, 1),
        new Uniform('cc_debug_view_composite_enable_shadow', Type.FLOAT, 1),
        new Uniform('cc_debug_view_composite_enable_ao', Type.FLOAT, 1),
        new Uniform('cc_debug_view_composite_enable_normal_map', Type.FLOAT, 1),
        new Uniform('cc_debug_view_composite_enable_fog', Type.FLOAT, 1),
        new Uniform('cc_debug_view_composite_enable_tone_mapping', Type.FLOAT, 1),
        new Uniform('cc_debug_view_composite_enable_gamma_correction', Type.FLOAT, 1),
    ], 1);
}
globalDescriptorSetLayout.layouts[UBODebugView.NAME] = UBODebugView.LAYOUT;
globalDescriptorSetLayout.bindings[UBODebugView.BINDING] = UBODebugView.DESCRIPTOR;
