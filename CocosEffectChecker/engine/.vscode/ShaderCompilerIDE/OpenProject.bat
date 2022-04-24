@echo off
cd /d %~dp0ShaderCompilerIDE\Tools\
dllfunc tool.dll toolVSSlnOpenWithVersion "%~dp0ShaderCompilerIDE.sln" 0
rem ..\..\ShaderCompilerIDE.sln