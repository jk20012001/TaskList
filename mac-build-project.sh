#!/bin/sh
# 终端执行方式: sh /xxx/mac-build-project.sh 主项目所在根文件夹 小包工程所在根文件夹(可选)          三个参数都是路径, 都可以靠拖的, 但切记要把换行符删掉换成空格

if [ ! -d "$TMPDIR/mac-build-project/" ]; then
	mkdir $TMPDIR/mac-build-project/
fi
TEMPFILE1=$TMPDIR/mac-build-project/ARG1.txt
TEMPFILE2=$TMPDIR/mac-build-project/ARG2.txt
BATPATH=`dirname "$0"`
echo 当前路径为$PWD

WINPC_IP=30.19.58.50
WINPC_PORT=8037

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
echo resetwithipa:	强制更新后重新生成ini及真机调试
echo open:			打开编辑器和主项目
echo mini:			生成小包项目
echo openmini:		编辑器打开小包项目
echo forcedel:		强制删除工程目录
echo copyipa:		复制流水线包中的资源以便真机调试（旧）
echo copyipabuild:	复制流水线包中的资源到Saved下并生成以便真机调试
echo cxrqq:			显示CRXQQ工程中的两条命令
echo xcode16:		修复xcode16中的签名信息路径软链接, 仅需执行一次
echo memstats:		上传MemoryStatsViewer所需的符号
echo fixindexing:	修复Indexing无限转圈, 会失去代码提示
echo test:			测试
read CHOICE

if [ "$CHOICE" = "test" ]; then
	read
fi

if [ "$CHOICE" = "fixindexing" ]; then
	defaults write com.apple.dt.Xcode IDEIndexDisable -bool true
	echocolor 34 "命令最后的true改为false可以恢复"
	read
	exit
fi

if [ "$CHOICE" = "mini" ] || [ "$CHOICE" = "openmini" ]; then
	echo "先用编辑器新建一个C++项目"
	LocateFolder "$2" 小包工程路径 $TEMPFILE2
	MINIPROJECTDIR=$RETURNDIR
	echocolor 34 "小包工程路径为: $MINIPROJECTDIR"
fi

if [ "$CHOICE" = "xcode16" ]; then
	# xcode16之后的签名信息文件夹更换了读取位置, 需要软链接, 不能直接拷过去, 拷过去也没文件的
	# 事实上双击mobileprovision文件之后, 闪一下其实就会生成签名信息到~/Library/MobileDevice/Provisioning\ Profiles下, 查看新生成的文件名即签名id, 然后DefaultEngine.ini中的MobileProvision必须要跟此文件名匹配, 所以每次更新provision文件就要改ini内容
	if [ ! -d ~/Library/Developer/Xcode/UserData/Provisioning\ Profiles/ ]; then
		echo "文件夹不存在~/Library/Developer/Xcode/UserData/Provisioning\ Profiles/"
	elif [ ! -d ~/Library/MobileDevice/Provisioning\ Profiles ]; then
		echo "Make Link For XCode16"
		# 不存在, 直接创建软链接
		ln -s ~/Library/Developer/Xcode/UserData/Provisioning\ Profiles/ ~/Library/MobileDevice
	else
		LINKPATH=`readlink -f ~/Library/MobileDevice/Provisioning\ Profiles/`
		SRCPATH=~/Library/MobileDevice/Provisioning\ Profiles
		# 存在, 那要看下是不是已经创建过软链接了
		if [ "$LINKPATH" = "$SRCPATH" ]; then
			echo "Make Link For XCode16"
			rm -r ~/Library/MobileDevice/Provisioning\ Profiles/
			ln -s ~/Library/Developer/Xcode/UserData/Provisioning\ Profiles/ ~/Library/MobileDevice
		else
			echo "Xcode Certification Folder-Link OK"
		fi
	fi
	read
fi

if [ "$CHOICE" = "init" ]; then
	# 有时候需要这样set PATH, 否则无法调用GenerateProjectFiles.sh
	# set export PATH=$PATH:$WORKDIR/ue4_tracking_rdcsp

	# 玩法隔离软链接
	ln -s -f $WORKDIR/letsgo_common/clientTools/Feature/StarP/Export $WORKDIR/LetsGo/Content/Feature/StarP/Script/Export
	
	echo "如果Clone出Cant Write LFS的错, 要在完整访问所有磁盘的权限中添加ugit, 另外ugit设置-高级-LFS并发改为8"
	echo "保证系统设置-网络-防火墙已关掉, 不然下载Dependencies时会连不上cdn.unrealengine.com"
	echo "保证系统设置-隐私与安全性-完全磁盘访问权限中的XCode已打开"
	echo "修改LetsGo/Config/DefaultEngine.ini加签名信息后, 按回车键继续..."
	open -R $WORKDIR/LetsGo/Config/DefaultEngine.ini
	read
	sh $WORKDIR/ue4_tracking_rdcsp/Setup.sh --force
	$WORKDIR/ue4_tracking_rdcsp/GenerateProjectFiles.sh -project="$WORKDIR/LetsGo/LetsGo.uproject" -game -engine

	echo "修改LetsGo/Intermediate/ProjectFiles/LetsGo.xcodeproj/project.pbxproj去掉entitlements后, 忽略此步骤的话需要在XCode中手动删除, 按回车键继续..."
	open -R $WORKDIR/LetsGo/Intermediate/ProjectFiles/LetsGo.xcodeproj/project.pbxproj
	read
	XCODEPROJECT=$WORKDIR/LetsGo/LetsGo.xcworkspace
fi

if [ "$CHOICE" = "reset" ] || [ "$CHOICE" = "resetwithipa" ]; then
	echo "修改LetsGo/Config/DefaultEngine.ini加ios签名信息后, 按回车键继续..."
	open -R $WORKDIR/LetsGo/Config/DefaultEngine.ini
	read
	$WORKDIR/ue4_tracking_rdcsp/GenerateProjectFiles.sh -project="$WORKDIR/LetsGo/LetsGo.uproject" -game -engine
	echo "修改LetsGo/Intermediate/ProjectFiles/LetsGo.xcodeproj/project.pbxproj去掉entitlements后, 忽略此步骤的话需要在XCode中手动删除, 按回车键继续..."
	open -R $WORKDIR/LetsGo/Intermediate/ProjectFiles/LetsGo.xcodeproj/project.pbxproj
	read
	XCODEPROJECT=$WORKDIR/LetsGo/LetsGo.xcworkspace
	if [ "$CHOICE" = "resetwithipa" ]; then
		CHOICE="copyipabuild"
		open /Applications/XCode.app $XCODEPROJECT
	fi
fi

if [ "$CHOICE" = "mini" ]; then
	if [ -d "$MINIPROJECTDIR/Plugins/MoeMSDK" ]; then
		echo "MoeMSDK文件夹已存在, 忽略拷贝"
	else
		mkdir "$MINIPROJECTDIR/Plugins"
		if [ -d "$BATPATH/MoeMSDK" ]; then
			cp -r $BATPATH/MoeMSDK $MINIPROJECTDIR/Plugins/
		else
			echo "当前目录下未找到MoeMSDK文件夹, 只能自行拷贝到$MINIPROJECTDIR/Plugins下"
			read
		fi
	fi
	echo "修改Config/DefaultEngine.ini加ios签名信息后, 按回车键继续..."
	open -R $MINIPROJECTDIR/Config/DefaultEngine.ini
	read	
	PROJECTNAME=${MINIPROJECTDIR##*/}
	echocolor 34 "工程名为: $PROJECTNAME, 即将生成此工程的XCode WorkSpace"
	echocolor 31 "如果后续XCode生成时报错找不到GVoice / MSDKAdjust / TDM等等一大堆模块, 可以根据提示从$MINIPROJECTDIR/Plugins/MoeMSDK/下的MoeMSDK.Build.cs和MoeMSDK.uplugin中统统注释掉, 全部删光一个不留都没关系"
	echo "按回车键继续..."
	read
	$WORKDIR/ue4_tracking_rdcsp/GenerateProjectFiles.sh -project="$MINIPROJECTDIR/$PROJECTNAME.uproject" -game -engine
	XCODEPROJECT=$MINIPROJECTDIR/$PROJECTNAME.xcworkspace
fi

if [ "$CHOICE" = "open" ]; then
	cd $WORKDIR/ue4_tracking_rdcsp/Engine/Binaries/Mac/UE4Editor.app/Contents/MacOS
	echocolor 34 "工程名为: LetsGo, 即将打开$WORKDIR/LetsGo/LetsGo.uproject"
	# 记住不能用open命令, 会缺参数, 或提示缺dll等各种问题, 要直接执行或用sudo才可以
	./UE4Editor "$WORKDIR/LetsGo/LetsGo.uproject"
	exit
fi

if [ "$CHOICE" = "openmini" ]; then
	PROJECTNAME=${MINIPROJECTDIR##*/}
	echocolor 34 "工程名为: $PROJECTNAME, 即将打开$MINIPROJECTDIR/$PROJECTNAME.uproject"
	cd $WORKDIR/ue4_tracking_rdcsp/Engine/Binaries/Mac/UE4Editor.app/Contents/MacOS
	./UE4Editor $MINIPROJECTDIR/$PROJECTNAME.uproject
	exit
fi

if [ "$CHOICE" = "forcedel" ]; then
	sudo rm -rf $WORKDIR/
	exit
fi
	
if [ "$CHOICE" = "memstats" ]; then
	stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" $WORKDIR/LetsGo/Binaries/IOS/LetsGoClient.dSYM
	echocolor 34 "请保证显示的文件修改时间和当前时间差不多，否则上传之后流水线解析也会失败，得打开ini中的bGenerateSYM重新生成app"
	echocolor 33 "如果是Shipping包，请保证流水线启动参数开启了bEnableMemoryStatsInShipping开关"
	cd $WORKDIR/LetsGo/Tools/MemoryStats/Scripts
	python3 Task_UploadSymbol.py $WORKDIR/LetsGo/Binaries/IOS
	exit
fi

if [ "$CHOICE" = "copyipa" ] || [ "$CHOICE" = "copyipabuild" ]; then
	APPDIR=$WORKDIR/LetsGo/Binaries/IOS/Payload/LetsGoClient.app/
	if [ "$CHOICE" = "copyipabuild" ]; then
		APPDIR=$WORKDIR/LetsGo/Saved/StagedBuilds/IOSClient/
		SHFILE=$BATPATH/MoeDev/local_ios_pack.sh
		SHFILE_SHIPPING=$BATPATH/MoeDev/local_ios_pack_shipping.sh
		SHMAINFILE=`basename "$SHFILE" .sh`
		mkdir -p $APPDIR
		if [ -f $SHFILE ]; then
			cp $SHFILE $WORKDIR/
		else
			echo "错误!未找到$SHFILE"
		fi
		if [ -f $SHFILE_SHIPPING ]; then
			cp $SHFILE_SHIPPING $WORKDIR/
		else
			echo "错误!未找到$SHFILE_SHIPPING"
		fi
	fi
	DESTDIR=$APPDIR"cookeddata/"
	echo "目标路径$DESTDIR"
	echo "SH文件$SHFILE和$SHFILE_SHIPPING"
	echocolor 32 "1. 请参考open命令后显示的设置事项保证Build和Run都能成功"
	echo "2. 请将ipa文件拖到此处并回车:"
	read IPAFILE
	IPAPATH=`dirname "$IPAFILE"`
	IPANAME=`basename "$IPAFILE" .ipa`
	ZIPFILE="$IPAPATH/$IPANAME.zip"
	ZIPPATH="$IPAPATH/$IPANAME"

	# Shipping包的特殊处理
	FINDRET=`echo $IPANAME | grep 'Shipping'`
	if [ ! 	-z "$FINDRET" ]; then
		echo 检测到ipa是Shipping包, 本地编译会使用Development Client吗（y / n）:
		read CHOICECLIENT
		if [ $CHOICECLIENT = "y" ]; then
			echocolor 34 "Shipping包 + Development Client, 还需要用自动工具注释掉LetsGoClient.Target.cs文件从84到90行的if-else部分, 否则启动可能会卡住"
			echocolor 34 "然后记得复原MemoryStats.uplugin文件, 按回车键继续..."
			open -R $WORKDIR/LetsGo/Source/LetsGoClient.Target.cs
		else
			echocolor 34 "Shipping包 + Shipping Client, 还需要用自动工具删掉MemoryStats.uplugin文件中BlacklistTargetConfigurations的内容, 否则启动可能会卡住"
			echocolor 34 "然后记得复原LetsGoClient.Target.cs文件, 按回车键继续..."
			open -R $WORKDIR/LetsGo/Plugins/MOE/GameFramework/GamePlugins/Performance/MemoryStats/MemoryStats/MemoryStats.uplugin
			SHMAINFILE=`basename "$SHFILE_SHIPPING" .sh`
		fi
		read
	fi

	# 处理解压和拷贝
	if [ -e $DESTDIR ]; then
		echo "删除 $DESTDIR 请输入登录密码"
		sudo rm -rf $DESTDIR
	fi
	if [ -e $DESTDIR ]; then
		echo "删除失败, 请手动删除LetsGoClient.app/cookeddata文件夹"
		read
		open $WORKDIR/LetsGo/Binaries/IOS/Payload/
	fi

	mv $IPAFILE $ZIPFILE
	unzip -d $ZIPPATH/ $ZIPFILE
	mv $ZIPFILE $IPAFILE
	cp -r $ZIPPATH/Payload/LetsGoClient.app/cookeddata $APPDIR
	cp -r $ZIPPATH/Payload/LetsGoClient.app/Manifest_NonUFSFiles_IOS.txt $APPDIR
	sudo rm -rf $ZIPPATH/
	
	# 执行local_ios_pack.sh
	if [ ! -z "$SHFILE" ]; then
		echo "执行$SHMAINFILE.sh...可以修改$WORKDIR/$SHMAINFILE中的构建类型 Develop/Test/Shipping 等"
		cd $WORKDIR/
		sh $SHMAINFILE.sh
		echo ipabuild结束|nc -w 1 $WINPC_IP $WINPC_PORT
		echocolor 34 "现在可以用XCode修改代码并选择对应的Client配置运行启动真机调试了, 别忘了要去掉启动参数, 否则启动会卡住"
	fi
	exit
fi

if [ "$CHOICE" = "cxrqq" ]; then
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
