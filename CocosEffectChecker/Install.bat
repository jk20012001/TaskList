@echo off
if "%1"=="" (
@echo ����engine�ļ��е�bat��
pause
exit
)
cd /d %~dp0
@echo on
xcopy /s /y engine\*.* "%1"
pause

@echo off
cd /d "%1\.vscode\ShaderCompilerIDE\ShaderCompilerIDE\Tools\"
copy /y ..\ShaderCompilerIDE.vcxproj ..\ShaderCompilerIDE_template.vcxproj
copy /y ..\ShaderCompilerIDE.vcxproj.filters" ..\ShaderCompilerIDE_template.vcxproj.filters
dllfunc goldfx.dll CocosShaderCompilerIDEGenerator "%1\.vscode\ShaderCompilerIDE\ShaderCompilerIDE\ShaderCompilerIDE.vcxproj" "%1"
@echo
@echo --------------------------------------------------------------------------------------------------------------------
@echo ����Visual Studio�еĹ��߲˵�--ѡ��--�ı��༭��--�ļ���չ���зֱ����effect��chunkΪMicrosoft Visual C++���͵ı༭��
pause