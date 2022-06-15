/* eslint-disable no-useless-escape */

import { Asset, AssetDB, forEach, Importer } from '@editor/asset-db';
import { EffectAsset } from 'cc';
import { existsSync, readFileSync, writeFileSync } from 'fs-extra';
import { basename, dirname, extname, join, relative, resolve } from 'path';
import { buildEffect, IChunkInfo, options } from '../../../static/effect-compiler';

// 当某个头文件请求没找到，尝试把这个请求看成相对当前 effect 的路径，返回实际头文件路径再尝试找一下
const closure = { root: '', dir: '' };
options.throwOnWarning = true; // be more strict on the user input for now
options.skipParserTest = true; // we are guaranteed to have GL backend test here, so parser tests are not really that helpful anyways
options.getAlternativeChunkPaths = (path: string) => {
    return [relative(closure.root, resolve(closure.dir, path)).replace(/\\/g, '/')];
};
// 依然没有找到时，可能是依赖头文件还没有注册，尝试去每个 DB 搜一遍
options.chunkSearchFn = (names: string[]) => {
    const res: IChunkInfo = { name: undefined, content: undefined };
    forEach((db: AssetDB) => {
        if (res.content !== undefined) {
            return;
        }
        for (let i = 0; i < names.length; i++) { // user input path first
            const name = names[i];
            const file = resolve(db.options.target, 'chunks', name + '.chunk');
            if (!existsSync(file)) {
                continue;
            }
            res.name = name;
            res.content = readFileSync(file, { encoding: 'utf-8' });
            break;
        }
    });
    return res;
};

export default class EffectImporter extends Importer {
    // 版本号如果变更，则会强制重新导入
    get version() {
        return '1.5.7';
    }

    // importer 的名字，用于指定 importer as 等
    get name() {
        return 'effect';
    }

    // 引擎内对应的类型
    get assetType() {
        return 'cc.EffectAsset';
    }

    get migrations() {
        return migrations;
    }

    /**
     * 实际导入流程
     * 需要自己控制是否生成、拷贝文件
     * @param asset
     */
    public async import(asset: Asset) {
        try {
            const target = this.assetDB!.options.target;
            closure.root = join(target, 'chunks'); closure.dir = dirname(asset.source);
            const path = relative(join(target, 'effects'), closure.dir).replace(/\\/g, '/');
            const name = path + (path.length ? '/' : '') + basename(asset.source, extname(asset.source));

            const content = readFileSync(asset.source, { encoding: 'utf-8' });
            const effect = buildEffect(name, content);

            // 记录 effect 的头文件依赖
            forEach((db: AssetDB) => {
                for (const header of effect.dependencies) {
                    asset.depend(resolve(db.options.target, 'chunks', header + '.chunk'));
                }
            });

            const result = new EffectAsset();
            Object.assign(result, effect);

            // 引擎数据结构不变，保留 hideInEditor 属性
            if (effect.editor && effect.editor.hide) {
                result.hideInEditor = true;
            }

            // 添加 meta 文件中的 combinations
            if (asset.userData) {
                if (asset.userData.combinations) {
                    result.combinations = asset.userData.combinations;
                }

                if (effect.editor) {
                    asset.userData.editor = effect.editor;
                } else {
                    // 已存在的需要清空
                    asset.userData.editor = undefined;
                }
            }

            // @ts-ignore
            await asset.saveToLibrary('.json', EditorExtends.serialize(result));

            return true;
        } catch (err) {
            console.error(err);
            return false;
        }
    }
}

const migrations = [
    {
        version: '1.3.7',
        migrate: migrateEditorProps,
    },
    {
        version: '1.4.2',
        migrate: migrateUVAttribute,
    },
    {
        version: '1.4.7',
        migrate: migrateStandardTransparent,
    },
    {
        version: '1.4.8',
        migrate: migrateApplyFog,
    },
    {
        version: '1.4.9',
        migrate:  (asset: Asset) => {
            migrateMacroToFunction(asset);
            migrateEnableDirShadow(asset);
        },
    },
    {
        version: '1.5.0',
        migrate: migrateMacroToFunction,
    },
    {
        version: '1.5.1',
        migrate: migrateShadowFactorParameter,
    },
    {
        version: '1.5.2',
        migrate: migrateDefines,
    },
    {
        version: '1.5.3',
        migrate: migrateIncludeDecodeBase,
    },
    {
        version: '1.5.4',
        migrate: migrateSpecularIntensity,
    },
    {
        version: '1.5.5',
        migrate: migrateUnpackLightingMap,
    },
    {
        version: '1.5.6',
        migrate: migrateMacroUseLightMap,
    },
    {
        version: '1.5.7',
        migrate: migrateChunkFolders,
    },    
];

const inspectorRE = /inspector\s*:/g;
function migrateEditorProps(asset: Asset) {
    let effect = readFileSync(asset.source, { encoding: 'utf8' });
    effect = effect.replace(inspectorRE, 'editor:');
    writeFileSync(asset.source, effect, { encoding: 'utf8' });
}

const UVAttribute = /in\s*vec2\s*a_texCoord\s*;/;
const inputIncludeRE = /include.*input/;
function migrateUVAttribute(asset: Asset) {
    let effect = readFileSync(asset.source, { encoding: 'utf8' });
    if (effect.match(inputIncludeRE)) {
        effect = effect.replace(UVAttribute, '');
    }
    writeFileSync(asset.source, effect, { encoding: 'utf8' });
}

const MacroStandardTransparent = /CC_STANDARD_TRANSPARENT/g;
const ReplaceTransparentWithForward = 'CC_FORCE_FORWARD_SHADING';
function migrateStandardTransparent(asset: Asset) {
    let effect = readFileSync(asset.source, { encoding: 'utf8' });
    if (effect.match(MacroStandardTransparent)) {
        effect = effect.replace(MacroStandardTransparent, ReplaceTransparentWithForward);
    }
    writeFileSync(asset.source, effect, { encoding: 'utf8' });
}

const MacroApplyFog = /[a-zA-Z_][a-zA-Z_0-9]*\s*=\s*CC_APPLY_FOG/g;
const ReplaceApplyFog = 'CC_APPLY_FOG';
const MacroTransferFog = /[a-zA-Z_][a-zA-Z_0-9]*\s*=\s*CC_TRANSFER_FOG/g;
const ReplaceTransferFog = 'CC_TRANSFER_FOG';
function migrateApplyFog(asset: Asset) {
    let effect = readFileSync(asset.source, { encoding: 'utf8' });
    if (effect.match(MacroApplyFog)) {
        effect = effect.replace(MacroApplyFog, ReplaceApplyFog);
    }
    if (effect.match(MacroTransferFog)) {
        effect = effect.replace(MacroTransferFog, ReplaceTransferFog);
    }
    writeFileSync(asset.source, effect, { encoding: 'utf8' });
}

const MacroEnableDirShadow = /&&\s*CC_ENABLE_DIR_SHADOW/g;
const ReplaceEnableDirShadow = '';
export function migrateEnableDirShadow(asset: Asset) {
    let effect = readFileSync(asset.source, { encoding: 'utf8' });
    if (effect.match(MacroEnableDirShadow)) {
        effect = effect.replace(MacroEnableDirShadow, ReplaceEnableDirShadow);
    }
    writeFileSync(asset.source, effect, { encoding: 'utf8' });
}

const MacroShadowFactor = /CC_SHADOW_FACTOR\s*\(\s*([\w.\[\]]+)\s*,\s*([\w.\[\]]+)\s*,\s*([\w.\[\]]+)\s*\)/g;
const ReplaceShadowFactor = '$1 = CCShadowFactorBase(CC_SHADOW_POSITION, $2)';
const MacroShadowFactorBase = /CC_SHADOW_FACTOR_BASE\s*\(\s*([\w.\[\]]+)\s*,\s*([\w.\[\]]+)\s*,\s*([\w.\[\]]+)\s*,\s*([\w.\[\]]+)\s*\)/g;
const ReplaceShadowFactorBase = '$1 = CCShadowFactorBase($2, $3)';
const MacroSpotShadowFactor = /CC_SPOT_SHADOW_FACTOR\s*\(\s*([\w.\[\]]+)\s*,\s*([\w.\[\]]+)\s*,\s*([\w.\[\]]+)\s*,\s*([\w.\[\]]+)\s*\)/g;
const ReplaceSpotShadowFactor = '$1 = CCSpotShadowFactorBase(CC_SHADOW_POSITION, $2)';
const MacroSpotShadowFactorBase = /CC_SPOT_SHADOW_FACTOR_BASE\s*\(\s*([\w.\[\]]+)\s*,\s*([\w.\[\]]+)\s*,\s*([\w.\[\]]+)\s*,\s*([\w.\[\]]+)\s*,\s*([\w.\[\]]+)\s*\)/g;
const ReplaceSpotShadowFactorBase = '$1 = CCSpotShadowFactorBase($2, $3)';
function migrateMacroToFunction(asset: Asset) {
    let effect = readFileSync(asset.source, { encoding: 'utf8' });
    if (effect.match(MacroShadowFactorBase)) {
        effect = effect.replace(MacroShadowFactorBase, ReplaceShadowFactorBase);
    }
    if (effect.match(MacroShadowFactor)) {
        effect = effect.replace(MacroShadowFactor, ReplaceShadowFactor);
    }
    if (effect.match(MacroSpotShadowFactorBase)) {
        effect = effect.replace(MacroSpotShadowFactorBase, ReplaceSpotShadowFactorBase);
    }
    if (effect.match(MacroSpotShadowFactor)) {
        effect = effect.replace(MacroSpotShadowFactor, ReplaceSpotShadowFactor);
    }
    writeFileSync(asset.source, effect, { encoding: 'utf8' });
}

const SearchIncludeHeader = /#include\s*<\s*standard-surface-header\s*>/g;
const ReplaceIncludeHeader = '#include <legacy/standard-surface-header>';
const SearchIncludeMain = /#include\s*<\s*standard-surface-main\s*>/g;
const ReplaceIncludeMain = '#include <legacy/standard-surface-main>';
function migrateIncludeFolder(asset: Asset) {
    let effect = readFileSync(asset.source, { encoding: 'utf8' });
    if (effect.match(SearchIncludeHeader)) { effect = effect.replace(SearchIncludeHeader, ReplaceIncludeHeader); }
    if (effect.match(SearchIncludeMain)) { effect = effect.replace(SearchIncludeMain, ReplaceIncludeMain); }
    writeFileSync(asset.source, effect, { encoding: 'utf8' });
}

const ShadowFactorBaseParameter = /CCShadowFactorBase\s*\(\s*([\w.\[\]]+)\s*,\s*([\w.\[\]]+)\s*\)/g;
const ReplaceShadowFactorBaseParameter = 'CCShadowFactorBase($1, $2, vec2(0.0, 0.0))';
const SpotShadowFactorBaseParameter = /CCSpotShadowFactorBase\s*\(\s*([\w.\[\]]+)\s*,\s*([\w.\[\]]+)\s*\)/g;
const ReplaceSpotShadowFactorBaseParameter = 'CCSpotShadowFactorBase($1, $2, vec2(0.0, 0.0))';
function migrateShadowFactorParameter(asset: Asset) {
    let effect = readFileSync(asset.source, { encoding: 'utf8' });
    if (effect.match(ShadowFactorBaseParameter)) {
        effect = effect.replace(ShadowFactorBaseParameter, ReplaceShadowFactorBaseParameter);
    }
    if (effect.match(SpotShadowFactorBaseParameter)) {
        effect = effect.replace(SpotShadowFactorBaseParameter, ReplaceSpotShadowFactorBaseParameter);
    }
    writeFileSync(asset.source, effect, { encoding: 'utf8' });
}

const DefineMetaRE = /#pragma\s+define\s+/g;
const DefineRE = /#define/g;
export function migrateDefines(asset: Asset) {
    let effect = readFileSync(asset.source, { encoding: 'utf8' });
    effect = effect.replace(DefineMetaRE, '#pragma define-meta ');
    effect = effect.replace(DefineRE, '#pragma define');
    writeFileSync(asset.source, effect, { encoding: 'utf8' });
}

const IncludeLocalBatch = /(\s*)#include\s*<cc-local-batch>/g;
const ReplaceIncludeLocalBatch = '$1#include <decode-base>$1#include <cc-local-batch>';
export function migrateIncludeDecodeBase(asset: Asset) {
    let effect = readFileSync(asset.source, { encoding: 'utf8' });
    if (effect.match(IncludeLocalBatch)) {
        effect = effect.replace(IncludeLocalBatch, ReplaceIncludeLocalBatch);
    }
    writeFileSync(asset.source, effect, { encoding: 'utf8' });
}

const MetallicParam = /(\s*)s.metallic\s*=/g;
const ReplaceMetallicParam = '$1s.specularIntensity = 0.5;$1s.metallic =';
function migrateSpecularIntensity(asset: Asset) {
    let effect = readFileSync(asset.source, { encoding: 'utf8' });
    if (effect.match(MetallicParam)) {
        effect = effect.replace(MetallicParam, ReplaceMetallicParam);
    }
    writeFileSync(asset.source, effect, { encoding: 'utf8' });
}

const UnpackLightingMap = /UnpackLightingmap\s*\(\s*([\w.\[\]]+)\s*\)/g;
const ReplaceUnpackLightingMap = '$1.rgb';
function migrateUnpackLightingMap(asset: Asset) {
    let effect = readFileSync(asset.source, { encoding: 'utf8' });
    if (effect.match(UnpackLightingMap)) {
        effect = effect.replace(UnpackLightingMap, ReplaceUnpackLightingMap);
    }
    writeFileSync(asset.source, effect, { encoding: 'utf8' });
}

const UseLightMap = /(\s+)USE_LIGHTMAP/g;
const ReplaceUseLightMap = '$1CC_USE_LIGHTMAP';
export function migrateMacroUseLightMap(asset: Asset) {
    let effect = readFileSync(asset.source, { encoding: 'utf8' });
    if (effect.match(UseLightMap)) {
        effect = effect.replace(UseLightMap, ReplaceUseLightMap);
    }
    writeFileSync(asset.source, effect, { encoding: 'utf8' });
}

export function migrateChunkFolders(asset: Asset) {
    const includeMap = new Map([
        ['cc-fog-base', 'legacy/fog-base'], // existed, already modified
        ['cc-shadow-map-base', 'legacy/shadow-map-base'],
        ['morph', 'legacy/morph'],
        ['cc-skinning', 'legacy/skinning'],
        ['cc-local-batch', 'legacy/local-batch'],
        ['lighting', 'legacy/lighting'],
        ['lightingmap-fs', 'legacy/lightingmap-fs'],

        ['cc-shadow-map-vs', 'legacy/shadow-map-vs'], // move without any modifying
        ['cc-shadow-map-fs', 'legacy/shadow-map-fs'],
        ['cc-fog-vs', 'legacy/fog-vs'],
        ['cc-fog-fs', 'legacy/fog-fs'],
        ['lightingmap-vs', 'legacy/lightingmap-vs'],
        ['decode', 'legacy/decode'],
        ['decode-base', 'legacy/decode-base'],
        ['decode-standard', 'legacy/decode-standard'],
        ['input', 'legacy/input'],
        ['input-standard', 'legacy/input-standard'],
        ['output', 'legacy/output'],
        ['output-standard', 'legacy/output-standard'],
        ['shading-standard', 'legacy/shading-standard'],
        ['shading-standard-base', 'legacy/shading-standard-base'],
        ['shading-standard-additive', 'legacy/shading-standard-additive'],
        ['shading-cluster-additive', 'legacy/shading-cluster-additive'],
        ['shading-toon', 'legacy/shading-toon'],
        ['standard-surface-entry', 'legacy/standard-surface-entry'],

        ['alpha-test', 'builtin/internal-use/alpha-test'],
        ['cc-sprite-common', 'builtin/internal-use/sprite-common'],
        ['cc-sprite-texture', 'builtin/internal-use/sprite-texture'],
        ['embedded-alpha', 'builtin/internal-use/embedded-alpha'],
        ['particle-common', 'builtin/internal-use/particle-common'],

        ['cc-global', 'builtin/uniforms/cc-global'],
        ['cc-local', 'builtin/uniforms/cc-local'],
        ['cc-forward-light', 'builtin/uniforms/cc-forward-light'],
        ['cc-environment', 'builtin/uniforms/cc-environment'],
        ['cc-diffusemap', 'builtin/uniforms/cc-diffusemap'],
        ['cc-shadow', 'builtin/uniforms/cc-shadow'],
        ['cc-csm', 'builtin/uniforms/cc-csm'],
        ['cc-world-bound', 'builtin/uniforms/cc-world-bound'],
        ['builtin/uniforms/cc-skinning-uniforms', 'builtin/uniforms/cc-skinning'],

        ['common', 'common/common-define'],
        ['texture-lod', 'common/texture/texture-lod'],
        ['packing', 'common/data/packing'],
        ['unpack', 'common/data/unpack'],
        ['aces', 'common/color/aces'],
        ['gamma', 'common/color/gamma'],
        ['octahedron-transform', 'common/math/octahedron-transform'],
        ['transform', 'common/math/transform'],
        ['rect-area-light', 'common/lighting/rect-area-light'],

        ['fxaa', 'post-process/fxaa'],
        ['anti-aliasing', 'post-process/anti-aliasing'],
    ]);
    const mainFunctionMap = new Map([
        ['vert:\\s+particle-vs-gpu', 'vert: builtin/internal-use/particle-vs-gpu'],
        ['vert:\\s+particle-vs-legacy', 'vert: builtin/internal-use/particle-vs-legacy'],
        ['vert:\\s+particle-trail', 'vert: builtin/internal-use/particle-trail'],
        ['vert:\\s+outline-vs', 'vert: builtin/main-functions/outline-vs'],
        ['frag:\\s+outline-fs', 'frag: builtin/main-functions/outline-fs'],
        ['vert:\\s+general-vs', 'vert: builtin/main-functions/general-vs'],
    ]);

    let effect = readFileSync(asset.source, { encoding: 'utf8' });
    let needSave = false;

    for (const [key, value] of includeMap) {
        const find = new RegExp('#include\\s+<' + key + '>', 'g');
        const replace = "#include <" + value + ">";
        if (effect.match(find)) {
            effect = effect.replace(find, replace);
            needSave = true;
        }
    }
    for (const [key, value] of mainFunctionMap) {
        const find = new RegExp(key, 'g');
        const replace = value;
        if (effect.match(find)) {
            effect = effect.replace(find, replace);
            needSave = true;
        }
    }

    if (needSave) {
        writeFileSync(asset.source, effect, { encoding: 'utf8' });
    }
}