#!/bin/sh
# 终端执行方式: sh /xxx/mac-build-project.sh 主项目所在根文件夹 小包工程所在根文件夹(可选)          三个参数都是路径, 都可以靠拖的, 但切记要把换行符删掉换成空格

if [ ! -d "$TMPDIR/mac-build-project/" ]; then
	mkdir $TMPDIR/mac-build-project/
fi
TEMPFILE1=$TMPDIR/mac-build-project/ARG1.txt
TEMPFILE2=$TMPDIR/mac-build-project/ARG2.txt
BATPATH=`dirname "$0"`
echo 当前路径为$PWD

# 参数为: 命令行传入的路径, 提示名, 记录路径的临时文件
function LocateFolder() {
	RETURNDIR=""
	if [ "$1" != "" ]; then
		echo 指定了$2: $1
		RETURNDIR=$1
	elif [ -s "$3" ]; then
		#有数据但无参数, 提示是否使用默认
		CONTENT=`cat $3`
		echo 是否使用上次记录的$2: $CONTENT （y / n）:
		read CHOICELOCATE
		if [ $CHOICELOCATE = "y" ]; then RETURNDIR=$CONTENT; fi
	fi
	
	if [ "$RETURNDIR" = "" ]; then
		echo 请将$2拖到此处并回车:
		read RETURNDIR
	fi
	if [ ! -d "$RETURNDIR" ]; then
		echo 必须指定正确的$2!
		read; exit
	fi
	# 写入文件
	echo $RETURNDIR > $3
}
# 颜色值(31-47), "内容文本"
# 30黑色	31红色	32绿色	33黄色	34蓝色	35紫色	36浅蓝	37灰色
function echocolor() {
	ECHOCONTENT=`printf "\033[%sm%s\033[0m" "$1" "$2"`
	echo $ECHOCONTENT
	ECHOCONTENT=""
}

# 引擎文件夹
LocateFolder "$1" 项目根文件夹 $TEMPFILE1
WORKDIR=$RETURNDIR
echocolor 34 "项目根文件夹为: $WORKDIR"

# 功能提示
echo 请选择:
echo init:			初始化新Clone的引擎及生成项目
echo reset:			强制更新后重新生成ini及项目
echo open:			打开编辑器和主项目
echo mini:			生成小包项目
echo openmini:		编辑器打开小包项目
echo forcedel:		强制删除工程目录
echo copyipa:		复制流水线包中的资源以便真机调试
echo cxrqq:			显示CRXQQ工程中的两条命令
echo xcode16:		修复xcode16中的签名信息路径软链接
read CHOICE

if [ "$CHOICE" = "mini" ] || [ "$CHOICE" = "openmini" ]; then
	echo 先用编辑器新建一个C++项目
	LocateFolder "$2" 小包工程路径 $TEMPFILE2
	MINIPROJECTDIR=$RETURNDIR
	echocolor 34 "小包工程路径为: $MINIPROJECTDIR"
fi

if [ "$CHOICE" = "xcode16" ]; then
	# xcode16之后的签名信息文件夹更换了读取位置, 需要软链接, 不能直接拷过去, 拷过去也没文件的
	# 事实上双击mobileprovision文件之后, 闪一下其实就会生成签名信息到Library/Developer/Xcode/UserData/Provisioning Profiles下
	if [ ! -d ~/Library/Developer/Xcode/UserData/Provisioning\ Profiles/ ]; then
		echo 文件夹不存在~/Library/Developer/Xcode/UserData/Provisioning\ Profiles/
	elif [ ! -d ~/Library/MobileDevice/Provisioning\ Profiles ]; then
		echo Make Link For XCode16
		# 不存在, 直接创建软链接
		ln -s ~/Library/Developer/Xcode/UserData/Provisioning\ Profiles/ ~/Library/MobileDevice
	else
		LINKPATH=`readlink -f ~/Library/MobileDevice/Provisioning\ Profiles/`
		SRCPATH=~/Library/MobileDevice/Provisioning\ Profiles
		# 存在, 那要看下是不是已经创建过软链接了
		if [ "$LINKPATH" = "$SRCPATH" ]; then
			echo Make Link For XCode16
			rm -r ~/Library/MobileDevice/Provisioning\ Profiles/
			ln -s ~/Library/Developer/Xcode/UserData/Provisioning\ Profiles/ ~/Library/MobileDevice
		else
			echo Xcode Certification Folder-Link OK
		fi
	fi
	read
fi


if [ "$CHOICE" = "init" ]; then
	# 有时候需要这样set PATH, 否则无法调用GenerateProjectFiles.sh
	# set export PATH=$PATH:$WORKDIR/ue4_tracking_rdcsp

	# 玩法隔离软链接
	ln -s -f $WORKDIR/letsgo_common/clientTools/Feature/StarP/Export $WORKDIR/LetsGo/Content/Feature/StarP/Script/Export
	
	echo 如果Clone出Cant Write LFS的错, 要在完整访问所有磁盘的权限中添加ugit, 另外ugit设置-高级-LFS并发改为8
	echo 保证系统设置-网络-防火墙已关掉, 不然下载Dependencies时会连不上cdn.unrealengine.com
	echo 保证系统设置-隐私与安全性-完全磁盘访问权限中的XCode已打开
	echo 修改LetsGo/Config/DefaultEngine.ini加签名信息后, 按回车键继续...
	open -R $WORKDIR/LetsGo/Config/DefaultEngine.ini
	read
	sh $WORKDIR/ue4_tracking_rdcsp/Setup.sh --force
	$WORKDIR/ue4_tracking_rdcsp/GenerateProjectFiles.sh -project="$WORKDIR/LetsGo/LetsGo.uproject" -game -engine
	
	XCODEPROJECT=$WORKDIR/LetsGo/LetsGo.xcworkspace

elif [ "$CHOICE" = "reset" ]; then
	echo 修改LetsGo/Config/DefaultEngine.ini加ios签名信息后, 按回车键继续...
	open -R $WORKDIR/LetsGo/Config/DefaultEngine.ini
	read
	$WORKDIR/ue4_tracking_rdcsp/GenerateProjectFiles.sh -project="$WORKDIR/LetsGo/LetsGo.uproject" -game -engine
	XCODEPROJECT=$WORKDIR/LetsGo/LetsGo.xcworkspace

elif [ "$CHOICE" = "mini" ]; then
	if [ -d "$MINIPROJECTDIR/Plugins/MoeMSDK" ]; then
		echo MoeMSDK文件夹已存在, 忽略拷贝
	else
		mkdir "$MINIPROJECTDIR/Plugins"
		if [ -d "$BATPATH/MoeMSDK" ]; then
			cp -r $BATPATH/MoeMSDK $MINIPROJECTDIR/Plugins/
		else
			echo 当前目录下未找到MoeMSDK文件夹, 只能自行拷贝到$MINIPROJECTDIR/Plugins下
			read
		fi
	fi
	echo 修改Config/DefaultEngine.ini加ios签名信息后, 按回车键继续...
	open -R $MINIPROJECTDIR/Config/DefaultEngine.ini
	read	
	PROJECTNAME=${MINIPROJECTDIR##*/}
	echocolor 34 "工程名为: $PROJECTNAME, 即将生成此工程的XCode WorkSpace"
	echocolor 31 "如果后续XCode生成时报错找不到GVoice / MSDKAdjust / TDM等等一大堆模块, 可以根据提示从$MINIPROJECTDIR/Plugins/MoeMSDK/下的MoeMSDK.Build.cs和MoeMSDK.uplugin中统统注释掉, 全部删光一个不留都没关系"
	echo 按回车键继续...
	read
	$WORKDIR/ue4_tracking_rdcsp/GenerateProjectFiles.sh -project="$MINIPROJECTDIR/$PROJECTNAME.uproject" -game -engine
	XCODEPROJECT=$MINIPROJECTDIR/$PROJECTNAME.xcworkspace

elif [ "$CHOICE" = "open" ]; then
	cd $WORKDIR/ue4_tracking_rdcsp/Engine/Binaries/Mac/UE4Editor.app/Contents/MacOS
	echocolor 34 "工程名为: LetsGo, 即将打开$WORKDIR/LetsGo/LetsGo.uproject"
	# 记住不能用open命令, 会缺参数, 或提示缺dll等各种问题, 要直接执行或用sudo才可以
	./UE4Editor "$WORKDIR/LetsGo/LetsGo.uproject"
	exit

elif [ "$CHOICE" = "openmini" ]; then
	PROJECTNAME=${MINIPROJECTDIR##*/}
	echocolor 34 "工程名为: $PROJECTNAME, 即将打开$MINIPROJECTDIR/$PROJECTNAME.uproject"
	cd $WORKDIR/ue4_tracking_rdcsp/Engine/Binaries/Mac/UE4Editor.app/Contents/MacOS
	./UE4Editor $MINIPROJECTDIR/$PROJECTNAME.uproject
	exit

elif [ "$CHOICE" = "forcedel" ]; then
	sudo rm -rf $WORKDIR/
	exit

elif [ "$CHOICE" = "copyipa" ]; then
	echocolor 32 "1. 请参考open命令后显示的设置事项保证Build和Run都能成功"
	echo "2. 请将ipa文件拖到此处并回车:"
	read IPAFILE
	IPAPATH=`dirname "$IPAFILE"`
	IPANAME=`basename "$IPAFILE" .ipa`
	ZIPFILE="$IPAPATH/$IPANAME.zip"
	ZIPPATH="$IPAPATH/$IPANAME"
	mv $IPAFILE $ZIPFILE
	unzip -d $ZIPPATH/ $ZIPFILE
	mv $ZIPFILE $IPAFILE
	if [ -e $WORKDIR/LetsGo/Binaries/IOS/Payload/LetsGoClient.app/cookeddata/ ]; then
		echo 删除$WORKDIR/LetsGo/Binaries/IOS/Payload/LetsGoClient.app/cookeddata/文件夹, 请输入登录密码
		sudo rm -rf $WORKDIR/LetsGo/Binaries/IOS/Payload/LetsGoClient.app/cookeddata/
	fi
	if [ -e $WORKDIR/LetsGo/Binaries/IOS/Payload/LetsGoClient.app/cookeddata/ ]; then
		echo 删除失败, 请手动删除LetsGoClient.app/cookeddata文件夹
		read
		open $WORKDIR/LetsGo/Binaries/IOS/Payload/
	fi
	cp -r $ZIPPATH/Payload/LetsGoClient.app/cookeddata $WORKDIR/LetsGo/Binaries/IOS/Payload/LetsGoClient.app/
	cp -r $ZIPPATH/Payload/LetsGoClient.app/Manifest_NonUFSFiles_IOS.txt $WORKDIR/LetsGo/Binaries/IOS/Payload/LetsGoClient.app/	
	sudo rm -rf $ZIPPATH/
	exit
	
elif [ "$CHOICE" = "cxrqq" ]; then
	echo "先保证已将ipa文件下载到$WORKDIR/../ReCodesignQQ/APP/下并已经用xcode打开ReCodesignQQ工程"
	echo "1. 请将下载并解压好的dSYM文件拖到此处并回车:"
	read DSYMFILE
	echo "2. 请复制流水线上显示的构建机引擎文件夹路径到此处并回车:"
	read REMOTEENGINEPATH
	echo "3. 请复制本地引擎文件夹路径到此处并回车:"
	read LOCALENGINEPATH
	echo Run后请输入如下三条指令:
	# $WORKDIR/ue4_tracking_rdcsp/Engine/
	echo command script import "$LOCALENGINEPATH/Extras/LLDBDataFormatters/UE4DataFormatters.py"
	echo settings set target.source-map "$REMOTEENGINEPATH" "$LOCALENGINEPATH"
	echo target symbols add "$DSYMFILE"
	read
	exit
fi

# 打开项目
echo
echo
echocolor 34 "准备启动XCode并打开工程: $XCODEPROJECT"
echocolor 32 "菜单Edit Scheme Run--Info设为Development Editor，调试Arguments勾上所有项, 选择调试目标为Mac"
echocolor 32 "菜单Edit Scheme Test-Info设为Development Client，调试Arguments勾掉所有项, 选择调试目标为iPhone之后才会出现如下选项: 工程设置-Target-每一项-Build Settings-Code Signing Entitlements-Development Client中删掉IOS SDK项"
echo
echocolor 31 "如果生成时报错插件的Binaries文件夹无法访问, 需要彻底删掉ugit仓库重新clone"
open /Applications/XCode.app $XCODEPROJECT
