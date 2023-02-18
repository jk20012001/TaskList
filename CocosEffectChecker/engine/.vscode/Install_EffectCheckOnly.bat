@echo off
if not exist "%1" exit
if "%1"=="" exit

cd /d "%~dp0"
set CopyDest="%1\.vscode\tasks.json"
del "%CopyDest%"
copy /y tasks_EffectCheckOnly.json "%CopyDest%"
ShaderCompilerIDE\ShaderCompilerIDE\Tools\dllfunc tool.dll toolVSCodeConfigReplace "%CopyDest%" "@PATH@" "%~dp0\" 1

rem zip all files and folders in this folder