@echo off
if "%1"=="" (
@echo 请拖engine文件夹到bat上
pause
exit
)
if not exist "%1" exit

cd /d %~dp0
xcopy /y engine\.vscode\tasks.json "%1\.vscode\"

rem 复制到引擎外部的文件夹, 但必须和引擎在同一个盘符
set CopyDest=%~d1\Temp\%~p1
@echo on
xcopy /s /y engine\*.* "%CopyDest%"

@echo off
cd /d "%CopyDest%\.vscode\ShaderCompilerIDE\"
call BuildProject.bat "%1"

cd /d "%CopyDest%\.vscode\ShaderCompilerIDE\ShaderCompilerIDE\Tools\"
dllfunc tool.dll toolVSCodeAddKeyBinding "ctrl+f7 keyincomposition" "-workbench.action.tasks.build"
dllfunc tool.dll toolVSCodeAddKeyBinding_RunTask "ctrl+f7" "Cocos Effect Checker"
dllfunc tool.dll toolVSCodeAddKeyBinding_RunTask "ctrl+alt+f7" "Cocos Effect Checker With Performance"
dllfunc tool.dll toolVSCodeAddKeyBinding_RunTask "ctrl+shift+f7" "Cocos Effect Editor"
dllfunc tool.dll toolVSCodeAddKeyBinding "ctrl+shift+b" "-workbench.action.tasks.build"
dllfunc tool.dll toolVSCodeAddKeyBinding "ctrl+shift+b" "workbench.action.tasks.runTask"

rem 修改tasks.json为实际路径
dllfunc tool.dll toolVSCodeConfigReplace "%1\.vscode\tasks.json" "@PATH@" "%CopyDest%\" 1
