@echo off
@echo ��ѡ��:
@echo 0: ����editor
@echo 1: ����editor(����)
@echo 2: ����ts��������
@echo 3: ����ԭ����
@echo env: ����ԭ��������Ļ�������NDK_ROOT
@echo 4: ����effect
@echo 5: ����debuginfo(���unkown id������)
@echo 10: ��ʼ������(����Ҳ���cocos-for-editor��֧������)
@echo 11: ����ֿ�(����಻��������)
@echo 12: ��ȫ����(�������಻���Ļ����ֶ�����engine\scripts\typedoc-plugin, �༭���಻���Ļ����ֶ�����app\modules\engine-extensions����ȷ�İ汾)
@echo 20: ��������resources�µ������ļ���--д��
@echo 21: ��������resources�µ������ļ���--�ֶ�ָ��
set /p choice=������:


cd /d %~dp0
setlocal enabledelayedexpansion

if %choice%==1 call npm run build
if %choice%==2 copy /y npm run build-declaration
if %choice%==3 python %~dp0resources\3d\engine\native\tools\tojs\genbindings.py
if %choice%==4 node .\app\modules\engine-extensions\extensions\engine-extends\static\effect-compiler\build.js
if %choice%==5 (
cd resources\3d\engine
call npm install gulp
call gulp build-debug-infos
)
if %choice%==10 call npm run init --checkout-hard
if %choice%==11 (
call npm run clear
call npm run init --checkout-hard
cd resources\3d\engine
rd node_modules /s /q
rd profiles /s /q
rd temp /s /q
rd local /s /q
rd bin /s /q
call npm install gulp
call npm run build-declaration
)
if %choice%==12 (
cd resources\3d\engine
call npm install gulp
call npm run build-declaration
cd ..\..\..\
call npm install
)
if %choice%==0 (
if exist resources\3d\engine\bin\.cache\dev\editor\import-map.json (
rem call npm run build:effect
rem node .\app\modules\engine-extensions\extensions\engine-extends\static\effect-compiler\build.js --engine f:\work\engine\current
node .\app\modules\engine-extensions\extensions\engine-extends\static\effect-compiler\build.js
)
call npm start
)

if %choice%==20 (
set enginepath=f:\work\engine\current
md resources\3d
cd resources\3d
mklink /J engine !enginepath!
)
if "%choice%"=="env" (
C:\goldapps\DLLFunc.exe goldfx.dll toolSetRegistry HKEY_CURRENT_USER\Environment NDK_ROOT=C:\Users\Administrator\AppData\Local\Android\Sdk\ndk\21.1.6352462
C:\goldapps\DLLFunc.exe goldfx.dll toolSetRegistry HKEY_CURRENT_USER\Environment RENDERDOC_HOOK_EGL=0
@echo ������Ҫ������ע����¼��Ч
)
if %choice%==21 (
set /p enginepath=��������ļ����ϵ��˴�:
md resources\3d
cd resources\3d
mklink /J engine !enginepath!
)

pause
