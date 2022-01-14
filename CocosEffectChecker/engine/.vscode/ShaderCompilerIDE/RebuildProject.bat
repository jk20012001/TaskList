@echo off
cd /d %~dp0ShaderCompilerIDE\Tools\
copy /y ..\ShaderCompilerIDE_template.vcxproj ..\ShaderCompilerIDE.vcxproj
copy /y ..\ShaderCompilerIDE_template.vcxproj.filters ..\ShaderCompilerIDE.vcxproj.filters
dllfunc goldfx.dll CocosShaderCompilerIDEGenerator "%~dp0ShaderCompilerIDE\ShaderCompilerIDE.vcxproj" "%~dp0..\..\"
..\..\ShaderCompilerIDE.sln