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
dllfunc tool.dll CocosShaderCompilerIDEGenerator "%1\.vscode\ShaderCompilerIDE\ShaderCompilerIDE\ShaderCompilerIDE.vcxproj" "%1"

dllfunc tool.dll toolVSCodeAddKeyBinding "ctrl+f7 keyincomposition" "workbench.action.tasks.build"
dllfunc tool.dll toolVSCodeAddKeyBinding "ctrl+shift+b" "-workbench.action.tasks.build"
dllfunc tool.dll toolVSCodeAddKeyBinding "ctrl+shift+b" "workbench.action.tasks.runTask"

