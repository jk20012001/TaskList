@echo off
cd /d %~dp0ShaderCompilerIDE\Tools\
copy /y ..\ShaderCompilerIDE_template.vcxproj ..\ShaderCompilerIDE.vcxproj >nul >nul
copy /y ..\ShaderCompilerIDE_template.vcxproj.filters ..\ShaderCompilerIDE.vcxproj.filters >nul >nul
dllfunc tool.dll CocosShaderCompilerIDEGenerator "%~dp0ShaderCompilerIDE\ShaderCompilerIDE.vcxproj" "%~dp0..\..\"
@echo --------------------------------------------------------------------------------------------------------------------
@echo ����Visual Studio�еĹ��߲˵�--ѡ��--�ı��༭��--�ļ���չ���зֱ����effect��chunkΪMicrosoft Visual C++���͵ı༭��
@echo ͬʱ��ѡ������չ��ӳ��ΪMicrosoft Visual C++����, Ȼ������Visual Studio����Ч
@echo --------------------------------------------------------------------------------------------------------------------
pause
..\..\ShaderCompilerIDE.sln