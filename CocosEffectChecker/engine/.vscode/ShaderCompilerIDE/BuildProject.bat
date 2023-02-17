@echo off
cd /d %~dp0..\EffectChecker
del timestamp.ini >nul 2>nul
cd /d %~dp0ShaderCompilerIDE\Tools\
dllfunc tool.dll CocosShaderCompilerIDEGenerator "%~dp0ShaderCompilerIDE\ShaderCompilerIDE.vcxproj" "%1\editor\assets\" 0
