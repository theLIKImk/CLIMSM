::UTF-8
::
::							Dassets(NOT WORK)
::
::
::@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
cd %~dp0

md %TEMP%\MDL>nul
del /f /s /q %TEMP%\MDL\* >nul
del /f /s /q %TEMP%\TEMP_MDL*.bat >nul
del /f /s /q %TEMP%\TEMP_MDL_VBS*.vbs >nul
set NOWHASHNUM=0

set TIMEF=%TIME%
for /f "delims=" %%t in (TEMP_hashlink.txt) do (
	set STRC=%%t
	
	REM 单独ID
	set MDLID=!random!-!random!-!random!-!random!-!random!-!random!
	echo.>%TEMP%\MDL\!MDLID!
	echo [!NOWHASHNUM!/%HASHNUM%][!STRC:~-43,2!]!STRC:~-40!
	
	%TEMP:~0,2%
	cd %TEMP%\MDL\
	call :check
	
	%~d0
	cd %~dp0
	
	REM 下载线程
	if not exist %MCDIR%\assets\objects\!STRC:~-43,2! md %MCDIR%\assets\objects\!STRC:~-43,2!
	call :MDL %%t "%MCDIR%\assets\objects\!STRC:~-43,2!\!STRC:~-40!" !MDLID!
	set /a NOWHASHNUM+=1
)

set TIMES=%TIME%
echo.OK:%TIMEF% --^> %TIMES%
echo.
echo.EXIT
exit /b



:MDL
REM CALL :MDL [URL] [PATH] [ID]
set MDLF=TEMP_MDL_%3.bat
	echo @title %3 >%TEMP%\%MDLF%
	echo @echo DOWNLOAD...... %1 ___\ %2 >>%TEMP%\%MDLF%
	echo @%~dp0\curl.exe %1^> %2 >>%TEMP%\%MDLF%
	echo @del %TEMP%\MDL\%3 >>%TEMP%\%MDLF%
	echo @del /f /s /q %TEMP%\%MDLF% ^& exit >>%TEMP%\%MDLF%
	
	echo CreateObject("WScript.Shell").Run "cmd /c call %TEMP%\%MDLF%",0 >%TEMP%\TEMP_MDL_VBS%3.vbs
	START %TEMP%\TEMP_MDL_VBS%3.vbs
goto :eof

:check
	for /l %%n in (1,1,!OUTTIME!) do (
		for /f "delims=" %%f in ('DIR /a') do set DNUM=%%f
		set /a DNUM=!DNUM:~14,2!
		if "!DNUM!"=="!DLN!" (echo [%%n][!OUTTIME!]ECHO WAIT.....) else (goto :eof)
	)
	echo x TIME OUT!
	pause>nul
goto :eof