:start
@echo off
@echo ��ѡ��:
@echo 1: ����editor(����)
@echo 2: ����ts��������
@echo 3: ����ԭ����(��ʾȱ�ٿ�Ļ�����ѡ��py)
@echo 4: ����ȫ��effect
@echo effect: ���뵥��effect
@echo 5: ����debuginfo(���EngineErrorMap unkown id������)
@echo run: ����editor
@echo=
@echo env: ����ԭ��������Ļ�������NDK_ROOT��npm����Ļ�������NODE_PATH��
@echo npm: ȫ�ְ�װnpm����Ŀ�
@echo py: ȫ�ְ�װpython����Ŀ�
@echo link: ��������resources�µ������ļ���--�Զ����ļ�����
@echo link2: ��������resources�µ������ļ���--�ֶ�ָ��
@echo=
@echo init: ��ʼ������(����Ҳ���cocos-for-editor��֧������)
@echo clean: ����ֿ�(����಻��������)
@echo reset: reset app modules�µĹ��̵������֧���°����޸ĵ�״̬
@echo resetall: reset editor engine �Լ�app modules�µĹ��̵������֧���°����޸ĵ�״̬
@echo b: ��ȫ����(����༭���಻���Ļ����ֶ�����app\modules\engine-extensions����ȷ�İ汾)
@echo=
@echo fix1: �޸���ȫ����ʱMODULE_NOT_FOUND������
@echo fix2: �޸���ȫ����ʱtypedoc��ʾ�Ҳ���typescript\bin\tsc��������಻��������(���ܻ�Ҫ�ֶ�����engine\scripts\typedoc-plugin)
@echo=
set /p choice=������:
@echo=

set BRANCHNAME=develop
cd /d %~dp0
setlocal enabledelayedexpansion

if %choice%==1 call npm run build
if %choice%==2 copy /y npm run build-declaration
if %choice%==3 python %~dp0resources\3d\engine\native\tools\tojs\genbindings.py && node %~dp0resources\3d\engine\native\tools\swig-config\genbindings.js
if %choice%==4 node .\app\modules\engine-extensions\extensions\engine-extends\static\effect-compiler\build.js
if "%choice%"=="effect" node .\app\modules\engine-extensions\extensions\engine-extends\static\effect-compiler\build.js F:\Work\editor\current\resources\3d\engine\editor\assets\effects\surfaces\standard.effect
if %choice%==5 (
cd resources\3d\engine
rem call npm install gulp
call gulp build-debug-infos
)
if "%choice%"=="init" call npm run init --checkout-hard
if "%choice%"=="clean" (
call npm run clear
call npm run init --checkout-hard
cd resources\3d\engine
rd node_modules /s /q
rd profiles /s /q
rd temp /s /q
rd local /s /q
rd bin /s /q
rem call npm install gulp
rem call npm install
rem call npm run build-declaration
)
if "%choice%"=="resetall" (
call F:\SysApps\Reg\Functional\Apps\GitReset.bat master %BRANCHNAME% origin
cd resources\3d\engine\
call F:\SysApps\Reg\Functional\Apps\GitReset.bat __editor__ %BRANCHNAME% origin
cd ..\..\..\
call :resetappgit
)
if "%choice%"=="reset" call :resetappgit
if "%choice%"=="b" (
cd resources\3d\engine
rem call npm install gulp
call npm run build-declaration
cd ..\..\..\
cd app\modules\platform-extensions\
git checkout -- .
cd ..\..\..\resources\3d\engine\
call npm install
cd ..\..\..\
rem del workflow\.update-cache.json
rem pause
c:\goldapps\dllfunc goldfx.dll toolVPNDial jinkun
call npm install
rasdial jinkun /disconnect
rem node workflow/scripts/build.js "--disable-repl"
)
if "%choice%"=="run" (
if exist resources\3d\engine\bin\.cache\dev\editor\import-map.json (
rem call npm run build:effect
rem node .\app\modules\engine-extensions\extensions\engine-extends\static\effect-compiler\build.js --engine f:\work\engine\current
rem node .\app\modules\engine-extensions\extensions\engine-extends\static\effect-compiler\build.js
)
call npm start
)

if "%choice%"=="env" (
C:\goldapps\DLLFunc.exe goldfx.dll toolSetRegistry HKEY_CURRENT_USER\Environment NDK_ROOT=C:\Users\Administrator\AppData\Local\Android\Sdk\ndk\21.1.6352462
C:\goldapps\DLLFunc.exe goldfx.dll toolSetRegistry HKEY_CURRENT_USER\Environment RENDERDOC_HOOK_EGL=0
C:\goldapps\DLLFunc.exe goldfx.dll toolSetRegistry HKEY_CURRENT_USER\Environment NODE_PATH=C:\Users\Administrator\AppData\Roaming\npm\node_modules
rem C:\goldapps\DLLFunc.exe goldfx.dll toolAddPathToSystemEnvironmentValue C:\Users\Administrator\AppData\Roaming\npm\node_modules
@echo ������Ҫ������ע����¼��Ч
)
if "%choice%"=="npm" (
explorer https://nodejs.org/download/release/v14.19.2/
@echo ���밲װNodejs14.x
pause
npm install typescript -g
npm install tslint -g
npm install electron-rebuild -g
npm install gulp -g
npm install yarn -g
npm install workflow-admin -g
)
if "%choice%"=="py" (
@echo ����ʹ��Python2.x�ҹرմ���VPN
pip install pyyaml==5.4.1
pip install cheetah
)
if "%choice%"=="fix1" (
C:\goldapps\DLLFunc.exe goldfx.dll toolFileFindAndReplace "%~dp0workflow\config.js" ", '--production'"
)
if "%choice%"=="fix2" (
cd resources\3d\engine\scripts\typedoc-plugin\
npm install typescript
)

if "%choice%"=="link" (
goto linktoengine
)
if "%choice%"=="link2" (
set /p enginepath=��������ļ����ϵ��˴�:
md resources\3d
cd resources\3d
mklink /J engine !enginepath!
)


:end
pause
cls
goto start


:linktoengine
set full=%CD%
C:\goldapps\ConsoleTools.exe GetPathLastLevel %CD% pathname
for /f %%i in (c:\templog\envvar.txt)  Do set %%i
cd ..\..\engine
mklink /J %pathname% %~dp0resources\3d\engine
goto end

:resetappgit
cd app\modules\editor-extensions\
call F:\SysApps\Reg\Functional\Apps\GitReset.bat __editor__ %BRANCHNAME% origin
cd ..\..\..\
cd app\modules\engine-extensions\
call F:\SysApps\Reg\Functional\Apps\GitReset.bat __editor__ %BRANCHNAME% origin
cd ..\..\..\
cd app\modules\platform-extensions\
call F:\SysApps\Reg\Functional\Apps\GitReset.bat __editor__ %BRANCHNAME% origin
cd ..\..\..\
cd resources\3d\engine\native\external\
call F:\SysApps\Reg\Functional\Apps\GitReset.bat __editor__ %BRANCHNAME% origin
cd ..\..\..\
goto :EOF
