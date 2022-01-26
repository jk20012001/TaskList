@echo off
cd /d %~dp0ShaderCompilerIDE\Tools\
copy /y ..\ShaderCompilerIDE_template.vcxproj ..\ShaderCompilerIDE.vcxproj >nul >nul
copy /y ..\ShaderCompilerIDE_template.vcxproj.filters ..\ShaderCompilerIDE.vcxproj.filters >nul >nul
dllfunc tool.dll CocosShaderCompilerIDEGenerator "%~dp0ShaderCompilerIDE\ShaderCompilerIDE.vcxproj" "%~dp0..\..\"
@echo --------------------------------------------------------------------------------------------------------------------
@echo 请在Visual Studio中的工具菜单--选项--文本编辑器--文件扩展名中分别添加effect和chunk为Microsoft Visual C++类型的编辑器
@echo 同时勾选将无扩展名映射为Microsoft Visual C++类型, 然后重启Visual Studio以生效
@echo --------------------------------------------------------------------------------------------------------------------
pause
..\..\ShaderCompilerIDE.sln