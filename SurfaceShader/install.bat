@echo off
if "%1"=="" (
@echo 请拖engine文件夹到bat上
pause
exit
)

cd /d "%1"
cd editor\assets\chunks
mklink /J builtin "%~dp0chunks\builtin\"
mklink /J common "%~dp0chunks\common\"
mklink /J lighting-models "%~dp0chunks\lighting-models\"
mklink /J post-process "%~dp0chunks\post-process\"
mklink /J shading-entries "%~dp0chunks\shading-entries\"
mklink /J surfaces "%~dp0chunks\surfaces\"
cd ..\effects
mklink /J surfaces "%~dp0effects\surfaces\"
pause