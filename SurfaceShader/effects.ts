
export function migrateChunkFolders(asset: Asset) {
    const replaceMap = new Map([
        ['cc-fog-base', 'builtin/internal-functions/fog'], // deleted
        ['cc-shadow-map-base', 'builtin/internal-functions/shadow-map'],
        ['morph', 'builtin/internal-functions/morph-animation'],

        ['cc-skinning', 'legacy/skinning'], // existed legacy
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
        ['cc-sprite-common', 'builtin/internal-use/sprite/sprite-common'],
        ['cc-sprite-texture', 'builtin/internal-use/sprite/sprite-texture'],
        ['embedded-alpha', 'builtin/internal-use/sprite/embedded-alpha'],
        ['particle-common', 'builtin/internal-use/particle/particle-common'],
        ['particle-trail', 'builtin/internal-use/particle/particle-trail'],
        ['particle-vs-gpu', 'builtin/internal-use/particle/particle-vs-gpu'],
        ['particle-vs-legacy', 'builtin/internal-use/particle/particle-vs-legacy'],

        ['cc-global', 'builtin/uniforms/cc-global'],
        ['cc-local', 'builtin/uniforms/cc-local'],
        ['cc-forward-light', 'builtin/uniforms/cc-forward-light'],
        ['cc-environment', 'builtin/uniforms/cc-environment'],
        ['cc-diffusemap', 'builtin/uniforms/cc-diffusemap'],
        ['cc-shadow', 'builtin/uniforms/cc-shadow'],
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
    ]);

    let effect = readFileSync(asset.source, { encoding: 'utf8' });

    for (const [key, value] of replaceMap) {
        const find = "/#include/s+<" + key + ">/g";
        const replace = "#include <" + value + ">";
        if (effect.match(find)) {
            effect = effect.replace(find, replace);
        }
    }

    writeFileSync(asset.source, effect, { encoding: 'utf8' });
}