@echo off
if "%1"=="" (
@echo ����engine�ļ��е�bat��
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
@echo *****************************************���Ȱ�װVisual Studio!
pause
)

for /r "%localappdata%\Microsoft\VisualStudio\" %%j in (va_x.dll) do set VAXDLL=%%j
If %VAXDLL%=="" (
color 04
@echo *****************************************�밲װVisual Assist X
pause
)

cls
color 02
@echo --------------------------------------------------------------------------------------------------------------------
@echo ����Visual Studio�еĹ��߲˵�--ѡ��--�ı��༭��--�ļ���չ���зֱ����effect��chunkΪMicrosoft Visual C++���͵ı༭��
@echo ͬʱ��ѡ������չ��ӳ��ΪMicrosoft Visual C++����, Ȼ������Visual Studio����Ч
@echo --------------------------------------------------------------------------------------------------------------------
pause