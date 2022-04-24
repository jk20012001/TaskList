@echo off
cd /d %~dp0ShaderCompilerIDE\Tools\
copy /y ..\ShaderCompilerIDE_template.vcxproj ..\ShaderCompilerIDE.vcxproj >nul >nul
copy /y ..\ShaderCompilerIDE_template.vcxproj.filters ..\ShaderCompilerIDE.vcxproj.filters >nul >nul
dllfunc tool.dll CocosShaderCompilerIDEGenerator "%~dp0ShaderCompilerIDE\ShaderCompilerIDE.vcxproj" "%~dp0..\..\" 0
