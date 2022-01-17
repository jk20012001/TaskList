@echo off
if "%1"=="" (
@echo 请拖engine文件夹到bat上
pause
exit
)
cd /d %~dp0
@echo on
xcopy /s /y engine\*.* "%1"

@echo off
cd /d "%1\.vscode\ShaderCompilerIDE\ShaderCompilerIDE\Tools\"
copy /y ..\ShaderCompilerIDE.vcxproj ..\ShaderCompilerIDE_template.vcxproj
copy /y ..\ShaderCompilerIDE.vcxproj.filters ..\ShaderCompilerIDE_template.vcxproj.filters
dllfunc goldfx.dll CocosShaderCompilerIDEGenerator "%1\.vscode\ShaderCompilerIDE\ShaderCompilerIDE\ShaderCompilerIDE.vcxproj" "%1"

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
@echo --------------------------------------------------------------------------------------------------------------------
pause