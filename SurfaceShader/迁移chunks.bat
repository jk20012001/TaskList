set dstpath=%1editor\assets\chunks\
set srcpath= %~dp0chunks\

cd /d "%dstpath%"

@echo delete
del /F skinning-dqs.chunk
del /F skinning-dqs.chunk.meta
del /F skinning-lbs.chunk
del /F skinning-lbs.chunk.meta
del /F cc-fog-base.chunk
del /F cc-fog-base.chunk.meta
del /F cc-shadow-map-base.chunk
del /F cc-shadow-map-base.chunk.meta
del /F morph.chunk
del /F morph.chunk.meta

@echo legacy
md legacy
move cc-shadow-map-vs.chunk legacy\
move cc-shadow-map-vs.chunk.meta legacy\
move cc-shadow-map-fs.chunk legacy\
move cc-shadow-map-fs.chunk.meta legacy\
move cc-fog-vs.chunk legacy\
move cc-fog-vs.chunk.meta legacy\
move cc-fog-fs.chunk legacy\
move cc-fog-fs.chunk.meta legacy\
move lightingmap-vs.chunk legacy\
move lightingmap-vs.chunk.meta legacy\
move decode.chunk legacy\
move decode.chunk.meta legacy\
move decode-base.chunk legacy\
move decode-base.chunk.meta legacy\
move decode-standard.chunk legacy\
move decode-standard.chunk.meta legacy\
move input.chunk legacy\
move input.chunk.meta legacy\
move input-standard.chunk legacy\
move input-standard.chunk.meta legacy\
move output.chunk legacy\
move output.chunk.meta legacy\
move output-standard.chunk legacy\
move output-standard.chunk.meta legacy\
move shading-standard.chunk legacy\
move shading-standard.chunk.meta legacy\
move shading-standard-base.chunk legacy\
move shading-standard-base.chunk.meta legacy\
move shading-standard-additive.chunk legacy\
move shading-standard-additive.chunk.meta legacy\
move shading-cluster-additive.chunk legacy\
move shading-cluster-additive.chunk.meta legacy\
move shading-toon.chunk legacy\
move shading-toon.chunk.meta legacy\
move standard-surface-entry.chunk legacy\
move standard-surface-entry.chunk.meta legacy\

@echo builtin\internal-use
move alpha-test.chunk builtin\internal-use\
move alpha-test.chunk.meta builtin\internal-use\
md builtin\internal-use\sprite
move cc-sprite-common.chunk builtin\internal-use\sprite\
move cc-sprite-common.chunk.meta builtin\internal-use\sprite\
move cc-sprite-texture.chunk builtin\internal-use\sprite\
move cc-sprite-texture.chunk.meta builtin\internal-use\sprite\
move embedded-alpha.chunk builtin\internal-use\sprite\
move embedded-alpha.chunk.meta builtin\internal-use\sprite\
md builtin\internal-use\particle
move particle-common.chunk builtin\internal-use\particle\
move particle-common.chunk.meta builtin\internal-use\particle\
move particle-trail.chunk builtin\internal-use\particle\
move particle-trail.chunk.meta builtin\internal-use\particle\
move particle-vs-gpu.chunk builtin\internal-use\particle\
move particle-vs-gpu.chunk.meta builtin\internal-use\particle\
move particle-vs-legacy.chunk builtin\internal-use\particle\
move particle-vs-legacy.chunk.meta builtin\internal-use\particle\

@echo builtin\uniforms
move cc-global.chunk builtin\uniforms\
move cc-global.chunk.meta builtin\uniforms\
move cc-local.chunk builtin\uniforms\
move cc-local.chunk.meta builtin\uniforms\
move cc-forward-light.chunk builtin\uniforms\
move cc-forward-light.chunk.meta builtin\uniforms\
move cc-environment.chunk builtin\uniforms\
move cc-environment.chunk.meta builtin\uniforms\
move cc-diffusemap.chunk builtin\uniforms\
move cc-diffusemap.chunk.meta builtin\uniforms\
move cc-shadow.chunk builtin\uniforms\cc-shadow-map.chunk
move cc-shadow.chunk.meta builtin\uniforms\cc-shadow-map.chunk.meta
move cc-world-bound.chunk builtin\uniforms\
move cc-world-bound.chunk.meta builtin\uniforms\


@echo common
move common.chunk common\
move common.chunk.meta common\
move texture-lod.chunk common\texture\
move texture-lod.chunk.meta common\texture\
move packing.chunk common\data\
move packing.chunk.meta common\data\
move unpack.chunk common\data\
move unpack.chunk.meta common\data\
move aces.chunk common\color\
move aces.chunk.meta common\color\
move gamma.chunk common\color\
move gamma.chunk.meta common\color\
move octahedron-transform.chunk common\math\
move octahedron-transform.chunk.meta common\math\
move transform.chunk common\math\
move transform.chunk.meta common\math\
move rect-area-light.chunk common\lighting\
move rect-area-light.chunk.meta common\lighting\

@echo post-process
move fxaa.chunk post-process\
move fxaa.chunk.meta post-process\
move anti-aliasing.chunk post-process\
move anti-aliasing.chunk.meta post-process\