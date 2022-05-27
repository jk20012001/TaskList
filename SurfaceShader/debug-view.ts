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
import { legacyCC } from '../global-exports';
import { Root } from '../root';
// import { NaitveSkybox } from '../native-scene';
import { GlobalDSManager } from '../pipeline/global-descriptor-set-manager';
import { Device } from '../gfx';
import { Enum } from '../value-types';

const enum DebugViewType {
    NONE,
    SINGLE,
    COMPOSITE_AND_MISC,
};
export const enum DebugViewSingleType {
    /**
     * @zh
     * 单项调试模式
     * @en
     * single debug mode
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

export const enum DebugViewCompositeType {
    /**
     * @zh
     * 组合调试模式
     * @en
     * composite debug mode
     * @readonly
     */
     DIRECT_DIFFUSE = 0,
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
     MAX_BIT_COUNT
};

/**
 * @en Rendering Debug View Control
 * @zh 渲染调试控制
 */
export class DebugView {

    /**
     * @en whether enabled with specified composite debug mode 
     * @zh 获取指定的组合调试模式是否开启
     */
    public isCompositeModeEnabled(val : number) : boolean {
        const mode = this._compositeModeValue & (1 << val);
        return mode !== 0;
    }
    /**
     * @en toggle specified composite debug mode
     * @zh 开关指定的组合调试模式
     */
     public enableCompositeMode(val: DebugViewCompositeType, enable: boolean) {
        this._enableCompositeMode(val, enable);
        this._updatePipeline();
    }

    public get singleMode () : DebugViewSingleType {
        return this._singleMode;
    }
    public set singleMode (val : DebugViewSingleType) {
        this._singleMode = val;
        this._updatePipeline();
    }

    public get lightingWithAlbedo () : boolean {
        return this._lightingWithAlbedo;
    }
    public set lightingWithAlbedo (val : boolean) {
        this._lightingWithAlbedo = val;
        this._updatePipeline();
    }

    public get csmLayerColoration () : boolean {
        return this._csmLayerColoration;
    }
    public set csmLayerColoration (val : boolean) {
        this._csmLayerColoration = val;
        this._updatePipeline();
    }

    protected _singleMode = DebugViewSingleType.NONE;
    protected _compositeModeValue = 0;
    protected _lightingWithAlbedo = true;
    protected _csmLayerColoration = false;
    protected _currentDebugViewType = DebugViewType.NONE;
    // protected declare _nativeObj: NaitveDebugView | null;

    /**
     * @internal
     */
    /*get native (): NaitveSkybox {
        return this._nativeObj!;
    }*/

    constructor () {
        if (JSB) {
            // this._nativeObj = new NaitveSkybox();
        }
    }

    private _enableCompositeMode(val: DebugViewCompositeType, enable: boolean) {
        if (enable) {
            this._compositeModeValue = this._compositeModeValue | (1 << val);
        } else {
            this._compositeModeValue = this._compositeModeValue & (~(1 << val));
        }
    }

    private _getDebugViewType () : DebugViewType {
        if (this._singleMode !== DebugViewSingleType.NONE) {
            return DebugViewType.SINGLE;
        } else if (this._lightingWithAlbedo !== true || this._csmLayerColoration !== false) {
            return DebugViewType.COMPOSITE_AND_MISC;
        } else {
            for (let i = 0; i < DebugViewCompositeType.MAX_BIT_COUNT; i++) {
                if (!this.isCompositeModeEnabled(i)) {
                    return DebugViewType.COMPOSITE_AND_MISC;
                }
            }
        }
        return DebugViewType.NONE;
    }

    public activate () {
        for (let i = 0; i < DebugViewCompositeType.MAX_BIT_COUNT; i++) {
            this._enableCompositeMode(i, true);
        }

        this._singleMode = DebugViewSingleType.NONE;
        this._lightingWithAlbedo = true;
        this._csmLayerColoration = false;
        this._currentDebugViewType = DebugViewType.NONE;
    }

    protected _updatePipeline () {
        if (JSB) {
            // this._nativeObj!.isRGBE = this.isRGBE;
        }

        const root = legacyCC.director.root as Root;
        const pipeline = root.pipeline;

        // Once you have entered debug mode, don't turn off this macro again, it will always be in debug mode until you restart the editor
        const useDebugView = this._currentDebugViewType === DebugViewType.NONE ? this._getDebugViewType() : this._currentDebugViewType;

        if(useDebugView !== DebugViewType.NONE)
        {
            pipeline.pipelineUBO.updateDebugViewUBO();
        }

        if (pipeline.macros.CC_USE_DEBUG_VIEW !== useDebugView) {
            pipeline.macros.CC_USE_DEBUG_VIEW = useDebugView;
            root.onGlobalPipelineStateChanged();
        }
    }

    protected _destroy () {
        if (JSB) {
            // this._nativeObj = null;
        }
    }

    public destroy () {
        this._destroy();
    }
}

legacyCC.debugView = new DebugView();

// 需要修改shader：cc_shadowMap / cc_spotLightingMap / cc_environment / cc_diffuseMap的binding加1