::UTF-8
::
::
::		Command Line Interface-Minecraft Script Manager(CLIMSM)
::
:: 
::LOGO
::
::   =========  -----  -      -----  -  _-  -----  -  _-  
::  //______/  /      /        /    /|_-/  /      /|_-/  
:: // >_   /  /      /        /    / / /    -_   / / /  
:://‗‗‗‗‗‗/  /____  /____  __/__  / / /  ____/  / / /  
::
@echo off
CHCP 65001&CLS
SETLOCAL ENABLEDELAYEDEXPANSION
set CLIMSMVer=0.012t
title %CLIMSMVer%

cd /d %~dp0

if not exist "%LOCALAPPDATA%\CLIMSM" md "%LOCALAPPDATA%\CLIMSM"
if not exist "%LOCALAPPDATA%\CLIMSM\mcds" md "%LOCALAPPDATA%\CLIMSM\mcds"
if not exist "%LOCALAPPDATA%\CLIMSM\userlist" md "%LOCALAPPDATA%\CLIMSM\userlist"

call :Title

:load
echo Load config......

if not exist "%LOCALAPPDATA%\CLIMSM\config.ini" call :setup
call :loadconfig %LOCALAPPDATA%\CLIMSM\config.ini

REM echo Load file......
REM for %%f in (curl.exe,curl-ca-bundle.crt,libcurl.dll,jj.exe,wget.exe,config.ini,RandomMsg.txt) do (
REM		echo  ^| %%f
REM		if not exist %%f (
REM			echo W: %%f 文件未找到，但您仍然可以运行此脚本 
REM			echo.
REM			pause>nul
REM		)
REM )

if not exist "%MCHOME%\.minecraft" mkdir .minecraft

if exist "%~dp0\INTMP" echo 自解压模式& SET INTMP=TRUE &del %PGDIR%\INTMP>NUL

echo.
echo OK
echo.

if /i not "%DO_NOT_OPEN_THIS%"=="FALSE" call :onset

if /i not "%rdmsg%"=="FALSE" call :rdmsg

echo 输入HELP获取帮助
echo.

:h
if not "%com%"=="" echo.
set com=
if /i not "%rdmsg%"=="FALSE" call :rdmsg
set /p com=[CM]#
call :cut %com%
if "%com%"=="" goto h
type %~dpf0 | FINDSTR /i :%C1% >nul && (
	call :%com%
)||(
	echo 命令不存在
)
goto h

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:help
	echo About              关于
	echo Config             设定
	echo GameGuide          Minecraft创建向导
	echo GameList           Minecraft版本列表
	echo Getexe             补全第三方
	echo Getlist            刷新版本缓存
	echo DAssets            下载资源文件
	echo DGameC             下载游戏本体
	echo DLib               下载运行库
	echo DL4X               LOG4J配置文件获取
	echo Natives            获取natives
	echo Help               HELP
	echo StpCMD             Cmd运行
	echo StpPS              PowerShell运行
	echo Useradd            用户添加
	echo Version            CLIMSM版本
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:getlist
	if exist CACHE_verlist.txt del /f /s /q CACHE_verlist.txt
	if exist TEMP_verlist.txt del /f /s /q TEMP_verlist.txt
	
	echo [CACHE_LIST] CREATE: %DATE% %TIME%>>CACHE_verlist.txt
	if exist CACHE_verjson.json del /f /s /q CACHE_verjson.json
	curl %verlist%>CACHE_verjson.json
	
	for /f "delims=" %%t in ('jj -i CACHE_verjson.json latest.release') do set LRV=%%t 
	for /f "delims=" %%t in ('jj -i CACHE_verjson.json latest.snapshot') do set LSV=%%t
	
	echo [LRV] %LRV%>>CACHE_verlist.txt
	echo [LSV] %LSV%>>CACHE_verlist.txt
	
	for /l %%i in (1,1,%Num%) do (
		set T.bak=!T!
		for /f "delims=" %%t in ('jj -i CACHE_verjson.json versions.%%i.id') do set T=%%t
		if "!T!"=="!T.bak!" goto skip_1
		for /f "delims=" %%u in ('jj -i CACHE_verjson.json versions.%%i.url') do set u=%%u
		echo 获取: [!t!] !u!
		echo [!t!] !u!>>TEMP_verlist.txt
	)
:skip_1
	echo 整合中......
	echo.
	for /f %%l in (' find /c /v "" ^<"TEMP_verlist.txt" ') do set VLV=%%l
	set /a VTL=%VLV%+1
	set VNUM=0
	:loop
		set /a Vtl=%Vtl%-1
		if not "%Vtl%"=="0" (
			for /f "skip=%Vtl% delims=*" %%i in (TEMP_verlist.txt) do (
				echo %%i !VNUM!>>CACHE_verlist.txt
				goto out
			)
		) else (
			for /f "delims=*" %%i in (TEMP_verlist.txt) do (
				echo %%i !VNUM!>>CACHE_verlist.txt
				goto out
			)
		)
	:out
		if "%Vtl%"=="0" goto :eof
		set /a VNum=!VNUM!+1
	goto loop
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:DGAMEC
	if "%1"=="" (
		set /p DV=版本:
		set /p NAME=游戏名字:
	) else (
		set DV=%1
		if "%2"=="" (set NAME=%1) else (set NAME=%2)
	)
	
	if exist "%MCDIR%\versions\%NAME%" echo %NAME% 存在 &goto :eof
	set FVER=
	if not exist CACHE_verlist.txt echo 请刷新版本列表缓存 &goto :eof
	for /f "delims=" %%t in ('type CACHE_verlist.txt^|find "[%DV%]" ') do set FVER=%%t
	if "%FVER%"=="" echo 版本不存在 &goto :eof
	md %MCDIR%\versions\%NAME%\
	CALL :CUT %FVER%
	curl %C2%>%MCDIR%\versions\%NAME%\%NAME%.json
	
	echo.
	echo 下载游戏本体
	echo.
	for /f "delims=" %%t in ('jj -i %MCDIR%\versions\%NAME%\%NAME%.json downloads.client.url ') do set GAMEMAIN=%%t
	echo !GAMEMAIN:%MojangVerListLink%=%MCDS%!
	wget -q !GAMEMAIN:%MojangVerListLink%=%MCDS%! -O %MCDIR%\versions\%NAME%\%NAME%.jar
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:DLIB
	if "%1"=="" (set /p NAME=游戏名字:) else (set NAME=%1)
	
	if not exist "%MCDIR%\versions\%NAME%" echo %NAME% 不存在 &goto :eof
	
	call :MCVerNUM
	
	echo.
	echo 下载运行库
	echo.
	if not exist "%MCDIR%\libraries" md "%MCDIR%\libraries"
	for /l %%i in (0,1,%Num%) do (
		for /f "delims=" %%t in ('jj -i %MCDIR%\versions\%NAME%\%NAME%.json libraries.%%i.downloads.artifact.url') do set LibsF=%%t
		if "!LibsF!"=="" goto skip_2
		for /f "delims=" %%f in ('jj -i %MCDIR%\versions\%NAME%\%NAME%.json libraries.%%i.downloads.artifact.path') do set LibsFP=%%f

		jj -i %MCDIR%\versions\%NAME%\%NAME%.json libraries.%%i | findstr natives >nul && (
			REM 版本分界633(1.19-PRE1)
			if "%MCVer_NUM%" GEQ "633" (
				jj -i %MCDIR%\versions\%NAME%\%NAME%.json libraries.%%i.name | findstr /i %LWJGLSYS% >nul && (
					REM 创建文件夹
					if not exist "%MCDIR%\libraries\!LibsFP:/=\!\..\" md %MCDIR%\libraries\!LibsFP:/=\!\..\
					echo [N]下载:!Libs!/!LibsFP!
					curl -s "!Libs!/!LibsFP!" > "%MCDIR%\libraries\!LibsFP:/=\!"
				) || (echo NOT>nul)
			) ELSE (
				for /f "delims=" %%f in ('jj -i %MCDIR%\versions\%NAME%\%NAME%.json libraries.%%i.name') do set lwjglname=%%f
				echo SKIP LWJGL:!lwjglname!......
			)
		) || (
			REM 创建文件夹
			if not exist "%MCDIR%\libraries\!LibsFP:/=\!\..\" md %MCDIR%\libraries\!LibsFP:/=\!\..\
			
			echo 下载:!Libs!/!LibsFP!
			curl -s "!Libs!/!LibsFP!" > "%MCDIR%\libraries\!LibsFP:/=\!"
		)
		set LibsF=
	)
	:skip_2
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:DAssets
	echo.
	echo 下载Assets
	echo.
	if "%1"=="" (set /p NAME=游戏名字:) else (set NAME=%1)
	
	if not exist "%MCDIR%\versions\%NAME%\%NAME%.json" echo %NAME%不存在 &goto :eof
	
	if not exist "%MCDIR%\assets" md "%MCDIR%\assets"
	if not exist "%MCDIR%\assets\indexes" md "%MCDIR%\assets\indexes"
	if not exist "%MCDIR%\assets\objects" md "%MCDIR%\assets\objects"

	echo.
	echo 获取HASH列表
	echo.
	
	for /f "delims=" %%a in ('jj -i %MCDIR%\versions\%NAME%\%NAME%.json assetIndex.url ') do set AssetsF=%%a
	for /f "delims=" %%v in ('jj -i %MCDIR%\versions\%NAME%\%NAME%.json assetIndex.id ') do set AssetsID=%%v
	curl %AssetsF%>%MCDIR%\assets\indexes\%AssetsID%.json
	jj -i %MCDIR%\assets\indexes\%AssetsID%.json -p >TEMP_Assets.txt
	echo.
	echo 整合HASH列表
	echo.
	type .\TEMP_Assets.txt | Find "hash">TEMP_hash.txt
	for /f %%l in (' find /c /v "" ^<"TEMP_hash.txt" ') do set HASHNUM=%%l
	
	del TEMP_hashlink.txt
	for /f "delims=*" %%f in (TEMP_hash.txt) do (
		set HASH=%%f
		set HASH=!HASH:~15,-3!
	
		echo %Assets%/!HASH:~0,2!/!HASH!>>TEMP_hashlink.txt
		echo>nul
	)
	
	echo.
	echo 下载资源文件......
	echo.
	
	set NOWHASHNUM=0
	if "%ASSETSDL%"=="1" (
		for /f "delims=*" %%f in (TEMP_hash.txt) do (
			set HASH=%%f
			set HASH=!HASH:~15,-3!
		
			if not exist "%MCDIR%\assets\objects\!HASH:~0,2!" (
				md %MCDIR%\assets\objects\!HASH:~0,2!
			)
			
			set /a NOWHASHNUM=!NOWHASHNUM!+1
			echo GET: [!NOWHASHNUM!/!HASHNUM!][!HASH:~0,2!]!HASH!
			wget -q %Assets%/!HASH:~0,2!/!HASH! -O %MCDIR%\assets\objects\!HASH:~0,2!\!HASH!
			echo>nul
		)
	)
	
	
	if "%ASSETSDL%"=="2" (
		call Dassets.cmd
	)
	
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:stpcmd
	set RS=C
goto startup

:stpps
	set RS=P
goto startup

:stp1
	REM 筛选NATIVES
	REM 筛选LWJGL版本(MD！麻将把LWJGL版本统一一下啊！！！凸)
	jj -i "%MCDIR%\versions\%NAME%\%NAME%.json" libraries.%LIBNUM% | findstr lwjgl >nul && (
		jj -i "%MCDIR%\versions\%NAME%\%NAME%.json" libraries.%LIBNUM% | findstr classifiers >nul && (
			REM echo SKIP natives
			set fnt=false
		)||(
			set /a NVNUM+=1
			REM echo !NVNUM!
			for /f "delims=" %%c in ('jj -i "%MCDIR%\versions\%NAME%\%NAME%.json" libraries.%LIBNUM%.downloads.artifact.path ') do set LIBL=%%c
			for /f "delims=" %%c in ('jj -i "%MCDIR%\versions\%NAME%\%NAME%.json" libraries.%LIBNUM%.downloads.artifact.path ') do set NV_!NVNUM!_LIBL=%%c
			for /f "delims=" %%c in ('jj -i "%MCDIR%\versions\%NAME%\%NAME%.json" libraries.%LIBNUM%.name ') do set NV_!NVNUM!=%%c
			set fnt=false
		)
	)
	REM ECHO -----------------------
goto :eof

:stp2
	echo %LIBL% | findstr native >nul && (
		echo %LIBL% | findstr %LWJGLSYS% >nul && (

			REM windows和windows-x86不是一起的
			if "%LWJGLSYS%"=="windows" echo %LIBL% | findstr x86 >nul && (set fnt=false) || (set fnt=true)
		) || (set fnt=false)
	)
goto :eof

:startup
	if "%1"=="" (set /p NAME=游戏名字:) else (set NAME=%1)

	if not exist "%MCDIR%\versions\%NAME%\%NAME%.json" echo %NAME%不存在 &goto :eof

	if not exist "%LOCALAPPDATA%\CLIMSM\userlist\%PLAYER%.ini" echo 未指定玩家&call :config&goto :eof
	
	call :MCVerNUM
	call :loadconfig %LOCALAPPDATA%\CLIMSM\userlist\%PLAYER%.ini
	
	echo.
	echo [%Playername%]
	echo %UUID%
	echo %accessToken%
	echo.
	if not exist "%MCDIR%\Assets\log_configs" md "%MCDIR%\Assets\log_configs"
	for /f "delims=" %%i in ('jj -i "%MCDIR%\versions\%NAME%\%NAME%.json" assets ') do set MCIndex=%%i
	for /f "delims=" %%i in ('jj -i "%MCDIR%\versions\%NAME%\%NAME%.json" id ') do set MCVer=%%i
	for /f "delims=" %%i in ('jj -i "%MCDIR%\versions\%NAME%\%NAME%.json" mainClass ') do set MCMAINCLASS=%%i
	for /f "delims=" %%i in ('jj -i "%MCDIR%\versions\%NAME%\%NAME%.json" logging.client.file.id ') do set L4X=%%i

	REM PS/CMD启动参数
	if "%RS%"=="C" (
		set XVAL=-Xmx%XMX% -Xmn%XMN% -XX:+UseG1GC -XX:-UseAdaptiveSizePolicy -XX:-OmitStackTraceInFastThrow -XX:HeapDumpPath=MojangTricksIntelDriversForPerformance_javaw.exe_minecraft.exe.heapdump -Xss1M -XX:+UnlockExperimentalVMOptions -XX:G1NewSizePercent=20 -XX:G1ReservePercent=20 -XX:MaxGCPauseMillis=50 -XX:G1HeapRegionSize=32M
		set DVAL=-Dos.name="Windows 10" -Dminecraft.launcher.brand="%Launcher%" -Dminecraft.launcher.version="%LauncherVer%" -Djava.library.path="%MCDIR%\versions\%NAME%\natives" -Dminecraft.client.jar="%MCDIR%\versions\%NAME%\%NAME%.jar"
		set Log4j2Val=-Dlog4j2.formatMsgNoLookups=true -Dlog4j.formatMsgNoLookups=true -Dlog4j.configurationFile="%MCDIR%\versions\%NAME%\%L4X%"
		set MCMAIN=net.minecraft.client.main.Main
		set MCL=%MCMAINCLASS% --username %Playername% --version %MCver% --gameDir "%MCDIR%\versions\%NAME%" --assetsDir "%MCDIR%\assets" --assetIndex %MCIndex% --uuid %UUID% --accessToken %accessToken% --userType mojang --versionType "%Launcher%[%LauncherVer%]" --width 854 --height 480
	)
	if "%RS%"=="P" (
		set XVAL='-Xmx%XMX%' '-Xmn%XMN%' '-XX:+UseG1GC' '-XX:-UseAdaptiveSizePolicy' '-XX:-OmitStackTraceInFastThrow' '-XX:HeapDumpPath=MojangTricksIntelDriversForPerformance_javaw.exe_minecraft.exe.heapdump' '-Xss1M' '-XX:+UnlockExperimentalVMOptions' '-XX:G1NewSizePercent=20' '-XX:G1ReservePercent=20' '-XX:MaxGCPauseMillis=50' '-XX:G1HeapRegionSize=32M'
		set DVAL='-Dos.name=Windows 10' '-Dminecraft.launcher.brand=%Launcher%' '-Dminecraft.launcher.version=%LauncherVer%' '-Djava.library.path=%MCDIR%\versions\%NAME%\natives' '-Dminecraft.client.jar=%MCDIR%\versions\%NAME%\%NAME%.jar'
		set Log4j2Val='-Dlog4j2.formatMsgNoLookups=true' '-Dlog4j.formatMsgNoLookups=true' '-Dlog4j.configurationFile=%MCDIR%\versions\%NAME%\%L4X%'
		set MCMAIN=net.minecraft.client.main.Main
		set MCL='%MCMAINCLASS%' '--username' '%Playername%' '--version' '%MCver%' '--gameDir' '%MCDIR%\versions\%NAME%' '--assetsDir' '%MCDIR%\assets' '--assetIndex' '%MCIndex%' '--uuid' '%UUID%' '--accessToken' '%accessToken%' '--userType' 'mojang' '--versionType' '%Launcher%[%LauncherVer%]' '--width' '854' '--height' '480'
	)
	del /f /s /q TEMP_libs.txt
	
	set last_n_n=
	set last_nv=
	set n_tmp_n=
	set nv_tmp=
	set /A NVNUM=0
	
	REM 筛选提取运行库
	REM 选择筛选方式
	REM 633=1.19-pre1
	IF "!MCVer_NUM!" GEQ "633" (SET STARTUPSELECT=2) else (SET STARTUPSELECT=1)
	
	echo [1/3]筛选运行库
	for /l %%i in (0,1,%NUM%) do (
		set LIBNUM=%%i
		for /f "delims=" %%c in ('jj -i "%MCDIR%\versions\%NAME%\%NAME%.json" libraries.%%i.downloads.artifact.path') do set LIBL=%%c
		if "!LIBL!"=="" goto skip_3
		set fnt=true
		call :stp%STARTUPSELECT%
		if "!fnt!"=="true" echo %MCDIR%\libraries\!LIBL!;>>TEMP_libs.txt
		set vfn=
		set vnfw=
		set LIBL=
		set fnt=
	)
 
	
:skip_3
	echo.>nul
	echo NATIVE[!NVNUM!]:>nul
	 for /l %%v in (1,1,!NVNUM!) do (
		ECHO !NV_%%v_LIBL!
	)
	
	echo [2/3]选择LWJGL版本
	REM 633=1.19-pre1
	IF "%MCVer_NUM%" GEQ "633" (echo 跳过&goto skip_cp)

	for /l %%i in (0,1,%NUM%) do (
		for /f "delims=" %%t in ('jj -i "%MCDIR%\versions\%NAME%\%NAME%.json" libraries.%%i.name ') do set LIBNAME=%%t
		if "!LIBNAME!"=="" goto skip_6
		echo !LIBNAME!
		
		for /f "delims=" %%t in ('jj -i "%MCDIR%\versions\%NAME%\%NAME%.json" libraries.%%i.natives ') do set vnat=%%t
		if not "!vnat!"=="" (
			REM 根据系统选择
			echo.!vnat! | findstr %LWJGLSYS% >nul && (
				for /f "delims=" %%v in ('jj -i "%MCDIR%\versions\%NAME%\%NAME%.json" libraries.%%i.name ') do set last_nv=%%v
				echo !last_nv!
				set last_nv=!last_nv:~-5!
				goto skip_6
			)
		)
		set vnat=
		set LIBNAME=
	)
	
	
	:skip_6
	
		
	echo [2/3]!last_nv!
	for /l %%v in (1,1,!NVNUM!) do (
		echo !NV_%%v_LIBL! | findstr !last_nv! >nul && (
			echo %MCDIR%\libraries\!NV_%%v_LIBL!;>>TEMP_libs.txt
		)
	)
	
	:skip_cp
	
	REM 清空
	set /a cpnum=0
	set cpt=
	set /a CPN=1
	set CP_1=
	set CP_2=
	set CP_3=
	set CP_4=
	set CP_5=
	set CP_6=
	set CP_7=
	set CP_8=
	set CP_9=
	set CP_10=

	echo [3/3]整合CLASSPATH并检测文件
	for /f "delims=" %%i in (TEMP_libs.txt) do (
		REM 获取CP参数
		set cpt=!cpt!%%i
		set CP_!CPN!=!cpt!
		set /a cpnum+=1
		
		REM CP参数拆分
		if "!cpnum!"=="10" (
			set /a CPN=!CPN!+1
			set cpnum=0
			set cpt=
		)
	)
	
:skip_4

	for /f "delims=" %%i in (TEMP_libs.txt) do (
		set T_LIBP=%%i
		set T_LIBP=!T_LIBP:/=\!
		set T_LIBP=!T_LIBP:~0,-1!
		if not exist !T_LIBP! echo [3/3]未找到 !T_LIBP!
	)

	if not "%CP_1%"=="" set CP_1=%CP_1:/=\%
	if not "%CP_2%"=="" set CP_2=%CP_2:/=\%
	if not "%CP_3%"=="" set CP_3=%CP_3:/=\%
	if not "%CP_4%"=="" set CP_4=%CP_4:/=\%
	if not "%CP_5%"=="" set CP_5=%CP_5:/=\%
	if not "%CP_6%"=="" set CP_6=%CP_6:/=\%
	if not "%CP_7%"=="" set CP_7=%CP_7:/=\%
	if not "%CP_8%"=="" set CP_8=%CP_8:/=\%
	if not "%CP_9%"=="" set CP_9=%CP_9:/=\%
	if not "%CP_10%"=="" set CP_10=%CP_10:/=\%
	
	REM echo.______________________________
	REM echo.
	REM echo.%JAVACORE%
	REM echo.
	REM echo %MCDIR%\libraries
	REM echo.
	REM echo %XVAL% 
	REM echo.
	REM echo %DVAL% 
	REM echo.
	REM echo.%JAVAOTHERCL%
	REM echo.
	REM echo.%MCL%
	REM echo.
	REM echo %CP_1%%CP_2%%CP_3%%CP_4%%CP_5%%CP_6%%CP_7%%CP_8%%CP_9%%CP_10%
	REM echo.
	REM echo Startup
	REM echo ______________________________
	REM echo.
	
	if /i "%RS%"=="C" (
		REM echo "%JAVACORE%" %XVAL% %Log4j2Val% %DVAL% -cp "%CP_1%%CP_2%%CP_3%%CP_4%%CP_5%%CP_6%%CP_7%%CP_8%%CP_9%%CP_10%%MCDIR%\versions\%NAME%\%NAME%.jar" %JAVAOTHERCL% %MCL%
		echo "%JAVACORE%" %XVAL% %Log4j2Val% %DVAL% -cp "%CP_1%%CP_2%%CP_3%%CP_4%%CP_5%%CP_6%%CP_7%%CP_8%%CP_9%%CP_10%%MCDIR%\versions\%NAME%\%NAME%.jar" %JAVAOTHERCL% %MCL%>TEMP_startup.txt
		
		REM 独立脚本
		echo @echo off>TEMP_startup.cmd
		echo title [CMD]CLIMSM-%NAME%:%MCVER%>>TEMP_startup.cmd
		echo "%JAVACORE%" %XVAL% %Log4j2Val% %DVAL% -cp "%CP_1%%CP_2%%CP_3%%CP_4%%CP_5%%CP_6%%CP_7%%CP_8%%CP_9%%CP_10%%MCDIR%\versions\%NAME%\%NAME%.jar" %JAVAOTHERCL% %MCL%>>TEMP_startup.cmd
		REM echo echo 退出代码：%errorlevel%>>TEMP_startup.cmd
		echo.echo.>>TEMP_startup.cmd
		echo pause>nul>>TEMP_startup.cmd
		echo exit>>TEMP_startup.cmd
		start TEMP_startup.cmd
		set RS=
		goto :eof
	)
	
	if /i "%RS%"=="P" (
		REM echo ^&'%JAVACORE%' %XVAL% %Log4j2Val% %DVAL% '-cp' '%CP_1%%CP_2%%CP_3%%CP_4%%CP_5%%CP_6%%CP_7%%CP_8%%CP_9%%CP_10%%MCDIR%\versions\%NAME%\%NAME%.jar' %JAVAOTHERCL% %MCL%
		echo ^&'%JAVACORE%' %XVAL% %Log4j2Val% %DVAL% '-cp' '%CP_1%%CP_2%%CP_3%%CP_4%%CP_5%%CP_6%%CP_7%%CP_8%%CP_9%%CP_10%%MCDIR%\versions\%NAME%\%NAME%.jar' %JAVAOTHERCL% %MCL%>TEMP_PowerShellCommandLine.ps1

		
		REM 独立脚本
		echo @echo off>TEMP_startup.cmd
		echo title [POWERSHELL]CLIMSM-%NAME%:%MCVER%>>TEMP_startup.cmd
		echo PowerShell -file TEMP_PowerShellCommandLine.ps1>>TEMP_startup.cmd
		REM echo echo 退出代码：%errorlevel%>>TEMP_startup.cmd
		echo echo.>>TEMP_startup.cmd
		echo pause>nul>>TEMP_startup.cmd
		echo exit>>TEMP_startup.cmd
		start TEMP_startup.cmd

		SET RS=
		goto :eof
	)
	echo.
	echo 未选择方式
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:onset
		curl https://api.zyglq.cn/fabing.php?name=%USERNAME%
		echo.
		echo.
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:searchjava
	where java.exe
	where javaw.exe
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:searchmcdir
	for %%i in (A:\ B:\ C:\ D:\ E:\ F:\ G:\ H:\ I:\ J:\ K:\ L:\ M:\ N:\ O:\ P:\ Q:\ R:\ S:\ T:\ U:\ V:\ W:\ X:\ Y:\ Z:\) do (
		if exist %%i (
			cd /d %%i
			dir /b /s ".minecraft"
		)
		cd /d %~dp0
	)
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:rdmsg
	for /f %%l in ('find /c /v "" ^<"RandomMsg.txt" ') do set RMLINE=%%l
	set /a RDL=%RMLINE%%RANDOM% %% %RMLINE%
	IF "%RDL%"=="0" (
		if %random:~1,1% GTR 4 (
			for /f "delims=*" %%n in (RandomMsg.txt) do (
				set rdSTR=%%n
				title [LINE:%RMLINE%/0]!rdSTR!
				goto SKIP_OUT
			)
		) else (
			set /a ld=%RMLINE% - 1
			for /f "skip=%ld% delims=*" %%n in (RandomMsg.txt) do (
				set rdSTR=%%n
				title [LINE:%RMLINE%/!RMLINE!]!rdSTR!
				goto SKIP_OUT
			)
		)
	) else (
		set /a RDLD=%RDL%-1
		for /f "skip=%RDLD% delims=*" %%n in (RandomMsg.txt) do (
			set rdSTR=%%n
			title [LINE:%RMLINE%/!RDL!]!rdSTR!
			goto SKIP_OUT
		)
	)
	:SKIP_OUT
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:debug
	echo.
	echo  ^|DEBUG MOD
	echo.
	:D_H
	set /p D_C=[CM^|DEBUG]%CD%#
	if "%D_C%"=="" goto D_H
	%D_C%
	set D_C=
	goto D_H
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:getexe
::TEST
	echo EXE来源http://bcn.bathome.net/
	echo.
	echo GET wget
	mshta http://bathome.net/s/hta/index.html Tools.get('wget')
	echo GET jj
	wget -q http://bcn.bathome.net/tool/jj.exe
	echo GET rar
	wget -q http://bcn.bathome.net/tool/5.30/rar.exe
	echo GET curl
	wget -q http://bcn.bathome.net/tool/haxx,7.61.0/curl.rar
	echo.
	echo 提取 curl.rar
	::rar x curl.rar
	rar e curl.rar>nul
	del curl.cmd
	del curl.rar
	echo.
	echo.
	echo Done
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:showme
	type MAIN.BAT
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Dnatives
	if "%1"=="" (set /p NAME=游戏名字:) else (set NAME=%1)
	
	call :MCVerNUM

	md "%MCDIR%\versions\%NAME%\natives\"
	for /l %%i in (1,1,%Num%) do (
		for /f "delims=" %%t in ('jj -i "%MCDIR%\versions\%NAME%\%NAME%.json" libraries.%%i.name') do set LIBNAME=%%t
		if "!LIBNAME!"=="" goto skip_5
		
		for /f "delims=" %%t in ('jj -i "%MCDIR%\versions\%NAME%\%NAME%.json" libraries.%%i.natives') do set vnat=%%t
		if not "!vnat!"=="" (
			echo.!vnat! | findstr %LWJGLSYS% >nul && (
				for /f "delims=" %%t in ('jj -i "%MCDIR%\versions\%NAME%\%NAME%.json" libraries.%%i.downloads.classifiers.natives-%LWJGLSYS%.path') do set NatPath=%%t
				if not exist "%MCDIR%\libraries\!NatPath:/=\!\..\" md "%MCDIR%\libraries\!NatPath:/=\!\..\"
				echo 下载:!NatPath!
				wget -q "!Libs!/!NatPath!" -O "%MCDIR%\libraries\!NatPath:/=\!"
				copy "%MCDIR%\libraries\!NatPath:/=\!" "%MCDIR%\versions\%NAME%\natives\">nul
			)
		)
		set vnat=
		set sysnat=
		set LIBNAME=
	)
	:skip_5
	 echo.
	echo 解压Natives文件
	echo.
	cd "%MCDIR%\versions\%NAME%\natives\"
	for /r %%i in (*.jar) do echo %%i&tar -xf %%i
	del /f /s /q *.jar
	del /f /s /q *.git
	del /f /s /q *.sha1
	cd /d %~dp0
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:inconfig
	::配置写入
	echo.MojangDS=https://launchermeta.mojang.com >"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.MojangVerList=https://launchermeta.mojang.com/mc/game/version_manifest.json >>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.MojangVerListLink=https://launcher.mojang.com >>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.MojangAssets=https://resources.download.minecraft.net >>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.MojangLibs=https://libraries.minecraft.net >>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.MCDS=https://download.mcbbs.net >>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.Verlist=https://download.mcbbs.net/mc/game/version_manifest.json >>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.Assets=https://download.mcbbs.net/assets >>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.Libs=https://download.mcbbs.net/maven >>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.enabled_MCDS=true>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo MCHOME=%CD%>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.MCDIR=%MCDIR%>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.JAVACORE=%JAVACORE%>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.XMX=1024m>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.XMN=120m>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.JAVAOTHERCL=>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.Num=114514>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.rdmsg=FALSE>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.Launcher=Command-Line-Interface-Minecraft-Script-Manager>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.LauncherVer=%CLIMSMVer%>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo._=[DO_NOT_OPEN_THIS]不要把下面改为TRUE，这可不是什么好玩的。啊?那为什么会有这个设定.....我不知道~~~~~~ >>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.DO_NOT_OPEN_THIS=FALSE>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.INTMP=FALSE>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.LWJGLSYS=windows>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.PLAYER=%PLAYERNAME%>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.DLN=10>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.OUTTIME=1000>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo._=[ASSETSDL]assetsdl下载方式：1/2>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.ASSETSDL=2>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.STARTUPSELECT=1>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo._=[VERIsolation]版本隔离>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	echo.VERIsolation=true>>"%LOCALAPPDATA%\CLIMSM\config.ini"
	
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:useradd
	echo (目前只支持离线，且需要Powershell)
	set /p PLAYERNAME=玩家名称:
	if exist "%LOCALAPPDATA%\CLIMSM\userlist\%PLAYERNAME%" echo 玩家存在 &goto :eof
	FOR /F %%a IN ('POWERSHELL -COMMAND "$([guid]::NewGuid().ToString())"') DO ( SET PLAYERUUID=%%a )
	set PLAYERUUID=%PLAYERUUID:-=%
	echo _=请勿将此文件发送给别人>"%LOCALAPPDATA%\CLIMSM\userlist\%PLAYERNAME%.ini"
	echo Playername=%PLAYERNAME%>>"%LOCALAPPDATA%\CLIMSM\userlist\%PLAYERNAME%.ini"
	echo Type=Offline>>"%LOCALAPPDATA%\CLIMSM\userlist\%PLAYERNAME%.ini"
	echo UUID=%PLAYERUUID%>>"%LOCALAPPDATA%\CLIMSM\userlist\%PLAYERNAME%.ini"
	echo accessToken=%PLAYERUUID%>>"%LOCALAPPDATA%\CLIMSM\userlist\%PLAYERNAME%.ini"
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:useronlineadd
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:config
START NOTEPAD.EXE "%LOCALAPPDATA%\CLIMSM\config.ini"
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:loadconfig
	for /f "delims=" %%i in (%1) do (if not "%%i"=="" set %%i)
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:cut
set C1=%1
set C2=%2
set C3=%3
set C4=%4
set C5=%5
set C6=%6
set C7=%7
set C8=%8
set C9=%9
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:DL4X
	if "%1"=="" (set /p NAME=游戏名字:) else (set NAME=%1)
	if not exist "%MCDIR%\versions\%NAME%\" echo %NAME%不存在！&goto :eof
	for /f "delims=" %%f in ('jj -i "%MCDIR%\versions\%NAME%\%NAME%.json" logging.client.file.url') do set L4Xml=%%f
	for /f "delims=" %%f in ('jj -i "%MCDIR%\versions\%NAME%\%NAME%.json" logging.client.file.id') do set L4Xml_id=%%f
	curl %L4Xml%>"%MCDIR%\versions\%NAME%\%L4Xml_id%"
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:gameguide
	echo 游戏创建向导
	echo.
	set /p DV=Minecraft游戏版本：
	set /p NAME=Minecraft游戏名字[可跟版本同名]：
	if exist "%MCDIR%\versions\%NAME%\" echo %NAME%存在！&goto :eof
	echo.
	call :dgamec %DV% %NAME%
	call :dlib %NAME%
	call :dnatives %NAME%
	call :dl4x %NAME%
	call :dassets %NAME%
	echo.
	echo.执行完毕，输入STPCMD/STPPS启动游戏
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Title
	echo Command Line Interface-Minecraft Script Manager(CLIMSM) 
	echo.Version:%CLIMSMVer%
	echo.
	echo.Power By:LIKIMK
	echo.
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:About
	echo Command Line Interface-Minecraft Script Manager(CLIMSM) 
	echo.Version:%CLIMSMVer%
	echo.
	echo.Power By:LIKIMK
	echo.
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:Version
	echo.%CLIMSMVer%
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:GameList
	::dir /b "%MCDIR%\Versions"
	for /d %%i in ("%MCDIR%\versions\*") do (
		echo -------------------------
		echo [%%~nxi]
		for /f "delims=" %%f in ('jj -i "%%i\%%~nxi.json" id ') do set MCVer=%%f
		for /f "delims=" %%f in ('jj -i "%%i\%%~nxi.json" type ') do set MCtype=%%f
		echo !MCVer!-!MCtype!
	)
	echo -------------------------
	cd /d %~dp0
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:setup
	echo 简要设定向导
	echo.
	echo 检索磁盘上MC主目录......
	call :searchmcdir
	set /p MCDIR=选择MC路径:
	echo.
	echo 检索磁盘上Java......
	call :searchjava
	set /p JAVACORE=选择现有的Java[不要输入引号！如果为空请安装java]:
	echo.
	echo 创建用户
	call :useradd
	echo.
	echo 配置中写入.....
	call :inconfig
	echo.
	echo 完毕，如果要更变设置输入[config]
goto :eof
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:MCVerNUM
	REM 检测版本范围
	if not exist "%MCDIR%\versions\%NAME%\%NAME%.json" echo %NAME%不存在 &goto :eof
	if not exist "%~dp0\CACHE_verlist.txt" echo 更新版本缓存 &call :getlist 
	for /f "delims=" %%f in ('jj -i "%MCDIR%\versions\%NAME%\%NAME%.json" id ') do set MCVer=%%f
	for /f "tokens=1-5" %%1 in ('type CACHE_verlist.txt^|find "[%MCVer%]" ') do set MCVer_NUM=%%3
	if "%MCVer_NUM%"=="" (echo [警告]版本不存在 ) else (
		echo MC版本数 %MCVer_NUM%
	)
goto :eof