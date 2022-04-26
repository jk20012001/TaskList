@echo off
cd /d %~dp0
call CopyFiles.bat "%1"
if not "%2"=="" (
cd /d %~dp0
call CopyFiles.bat "%2"
)
if not "%3"=="" (
cd /d %~dp0
call CopyFiles.bat "%3"
)


cls
If not exist "%localappdata%\Microsoft\VisualStudio\" (
color 04
@echo *****************************************请先安装Visual Studio!
pause
)

for /r "%localappdata%\Microsoft\VisualStudio\" %%j in (va_x.dll) do set VAXDLL=%%j
If %VAXDLL%=="" (
color 04
@echo *****************************************请安装Visual Assist X
pause
)

cls
color 02
@echo --------------------------------------------------------------------------------------------------------------------
@echo 请在Visual Studio中的工具菜单--选项--文本编辑器--文件扩展名中分别添加effect和chunk为Microsoft Visual C++类型的编辑器
@echo 同时勾选将无扩展名映射为Microsoft Visual C++类型, 然后重启Visual Studio以生效
@echo VA设置中的Projects and Files勾选Parse files without extensions as headers
@echo --------------------------------------------------------------------------------------------------------------------
pause