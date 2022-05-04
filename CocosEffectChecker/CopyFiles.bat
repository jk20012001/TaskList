@echo off
if "%1"=="" (
@echo 请拖engine文件夹到bat上
pause
exit
)
if not exist "%1" exit

cd /d %~dp0
@echo on
xcopy /s /y engine\*.* "%1"

@echo off
cd /d "%1\.vscode\ShaderCompilerIDE\"
call BuildProject.bat

cd /d "%1\.vscode\ShaderCompilerIDE\ShaderCompilerIDE\Tools\"
dllfunc tool.dll toolVSCodeAddKeyBinding "ctrl+f7 keyincomposition" "-workbench.action.tasks.build"
dllfunc tool.dll toolVSCodeAddKeyBinding_RunTask "ctrl+f7" "Cocos Effect Checker"
dllfunc tool.dll toolVSCodeAddKeyBinding_RunTask "ctrl+alt+f7" "Cocos Effect Checker With Performance"
dllfunc tool.dll toolVSCodeAddKeyBinding_RunTask "ctrl+shift+f7" "Cocos Effect Editor"
dllfunc tool.dll toolVSCodeAddKeyBinding "ctrl+shift+b" "-workbench.action.tasks.build"
dllfunc tool.dll toolVSCodeAddKeyBinding "ctrl+shift+b" "workbench.action.tasks.runTask"
