@echo off
call %~dp0BuildProject.bat
@echo --------------------------------------------------------------------------------------------------------------------
@echo 请在Visual Studio中的工具菜单--选项--文本编辑器--文件扩展名中分别添加effect和chunk为Microsoft Visual C++类型的编辑器
@echo 同时勾选将无扩展名映射为Microsoft Visual C++类型, 然后重启Visual Studio以生效
@echo VA设置中的Projects and Files勾选Parse files without extensions as headers
@echo --------------------------------------------------------------------------------------------------------------------
pause
call %~dp0OpenProject.bat