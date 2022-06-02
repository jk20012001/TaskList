
export function migrateChunkFolders(asset: Asset) {
    const includeMap = new Map([
        ['cc-shadow-map-base', 'builtin/internal-functions/shadow-map'],// todo

        ['cc-fog-base', 'legacy/fog-base'], // existed legacy
        ['morph', 'legacy/morph'],
        ['cc-skinning', 'legacy/skinning'], 
        ['cc-local-batch', 'legacy/local-batch'],
        ['lighting', 'legacy/lighting'],
        ['lightingmap-fs', 'legacy/lightingmap-fs'],

        ['cc-shadow-map-vs', 'legacy/shadow-map-vs'], // move to
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
        ['vert:\\s+particle-vs-gpu', 'vert: builtin/main-functions/particle-vs-gpu'],
        ['vert:\\s+particle-vs-legacy', 'vert: builtin/main-functions/particle-vs-legacy'],
        ['vert:\\s+particle-trail', 'vert: builtin/main-functions/particle-trail'],
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