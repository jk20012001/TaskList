@echo off
rem argument is out file and engine folder
cd /d %~dp0ShaderCompilerIDE\Tools\
dllfunc tool.dll CocosGenerateShadeAutoGenerationList "%1" "%2"
