@echo 先cocosshaderlink, 再执行本文件, 最后运行引擎以迁移代码
@echo 如果要提交的时候,请检查chunks根目录下的文件,和3.5.1版的是否有不同,尤其是morph batch skinning相关的

set dstpath=%1\editor\assets\chunks\
set srcpath= %~dp0\chunks\

rem xcopy /s /y "%~dp0\临时复制\chunks\" "%dstpath%"

cd /d "%dstpath%"

@echo delete
del /F embedded-alpha.meta
del /F skinning-dqs.chunk
del /F skinning-dqs.chunk.meta
del /F skinning-lbs.chunk
del /F skinning-lbs.chunk.meta
del /F builtin\legacy-cc-local-batch.chunk
del /F builtin\legacy-cc-local-batch.chunk.meta
del /F builtin\legacy-cc-skinning.chunk
del /F builtin\legacy-cc-skinning.chunk.meta
del /F builtin\legacy-morph.chunk
del /F builtin\legacy-morph.chunk.meta

@echo existed in tasklist legacy folder
del /F cc-fog-base.chunk
del /F cc-fog-base.chunk.meta
del /F cc-shadow-map-base.chunk
del /F cc-shadow-map-base.chunk.meta
del /F morph.chunk
del /F morph.chunk.meta
del /F cc-local-batch.chunk
del /F cc-local-batch.chunk.meta
del /F cc-skinning.chunk
del /F cc-skinning.chunk.meta
del /F lighting.chunk
del /F lighting.chunk.meta
del /F lightingmap-fs.chunk
del /F lightingmap-fs.chunk.meta

@echo legacy
md legacy
move cc-shadow-map-vs.chunk legacy\shadow-map-vs.chunk
move cc-shadow-map-vs.chunk.meta legacy\shadow-map-vs.chunk.meta
move cc-shadow-map-fs.chunk legacy\shadow-map-fs.chunk
move cc-shadow-map-fs.chunk.meta legacy\shadow-map-fs.chunk.meta
move cc-fog-vs.chunk legacy\fog-vs.chunk
move cc-fog-vs.chunk.meta legacy\fog-vs.chunk.meta
move cc-fog-fs.chunk legacy\fog-fs.chunk
move cc-fog-fs.chunk.meta legacy\fog-fs.chunk.meta
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
md builtin\internal-use\
move alpha-test.chunk builtin\internal-use\
move alpha-test.chunk.meta builtin\internal-use\
move cc-sprite-common.chunk builtin\internal-use\sprite-common.chunk
move cc-sprite-common.chunk.meta builtin\internal-use\sprite-common.chunk.meta
move cc-sprite-texture.chunk builtin\internal-use\sprite-texture.chunk
move cc-sprite-texture.chunk.meta builtin\internal-use\sprite-texture.chunk.meta
move embedded-alpha.chunk builtin\internal-use\
move embedded-alpha.chunk.meta builtin\internal-use\
move particle-common.chunk builtin\internal-use\
move particle-common.chunk.meta builtin\internal-use\
move particle-trail.chunk builtin\internal-use\
move particle-trail.chunk.meta builtin\internal-use\
move particle-vs-gpu.chunk builtin\internal-use\
move particle-vs-gpu.chunk.meta builtin\internal-use\
move particle-vs-legacy.chunk builtin\internal-use\
move particle-vs-legacy.chunk.meta builtin\internal-use\

@echo main functions
md builtin\main-functions\
move general-vs.chunk builtin\main-functions\
move general-vs.chunk.meta builtin\main-functions\
move outline-vs.chunk builtin\main-functions\
move outline-vs.chunk.meta builtin\main-functions\
move outline-fs.chunk builtin\main-functions\
move outline-fs.chunk.meta builtin\main-functions\

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
move cc-shadow.chunk builtin\uniforms\
move cc-shadow.chunk.meta builtin\uniforms\
move cc-csm.chunk builtin\uniforms\
move cc-csm.chunk.meta builtin\uniforms\
move cc-world-bound.chunk builtin\uniforms\
move cc-world-bound.chunk.meta builtin\uniforms\
move builtin\uniforms\cc-skinning-uniforms.chunk builtin\uniforms\cc-skinning.chunk
move builtin\uniforms\cc-skinning-uniforms.chunk.meta builtin\uniforms\cc-skinning.chunk.meta


@echo common
md common\data
md common\color
move common.chunk common\common-define.chunk
move common.chunk.meta common\common-define.chunk.meta
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
md post-process
move fxaa.chunk post-process\
move fxaa.chunk.meta post-process\
move anti-aliasing.chunk post-process\
move anti-aliasing.chunk.meta post-process\
