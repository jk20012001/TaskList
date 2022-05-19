@echo off
if "%1"=="" (
@echo 请至少指定一个engine文件夹, 拖到bat上
pause
exit
)

if not "%1"=="" "%~dp0..\CocosEffectChecker\engine\.vscode\ShaderCompilerIDE\ShaderCompilerIDE\Tools\dllfunc.exe" tool.dll CocosTasklistShaderLink "%1\editor\assets\" "%~dp0"
if not "%2"=="" "%~dp0..\CocosEffectChecker\engine\.vscode\ShaderCompilerIDE\ShaderCompilerIDE\Tools\dllfunc.exe" tool.dll CocosTasklistShaderLink "%2\editor\assets\" "%~dp0"
if not "%3"=="" "%~dp0..\CocosEffectChecker\engine\.vscode\ShaderCompilerIDE\ShaderCompilerIDE\Tools\dllfunc.exe" tool.dll CocosTasklistShaderLink "%3\editor\assets\" "%~dp0"
pause