@REM --======= Copyright © 2013-2014, Planimeter, All rights reserved. =======--
@REM --
@REM -- Purpose:
@REM --
@REM --=======================================================================--

@ECHO OFF
ECHO Grid Engine Dedicated Server Build
IF [%1]==[] (
	GOTO DETECT
)
IF [%1]==[x64] (
	GOTO 64BIT
)
IF [%1]==[x86] (
	GOTO 32BIT
)

:DETECT
ECHO Detecting architecture . . .
IF DEFINED ProgramFiles(x86) (
	GOTO 64BIT
) ELSE (
	GOTO 32BIT
)

:64BIT
ECHO Building Grid Engine Dedicated Server 64-bit . . .
SET RELEASEDIR="Release"
MKDIR %RELEASEDIR%
CD bin\x64\win64\love
GOTO BUILD

:32BIT
ECHO Building Grid Engine Dedicated Server 32-bit . . .
SET RELEASEDIR="Release (x86)"
MKDIR %RELEASEDIR%
CD bin\x86\win32\love
GOTO BUILD

:BUILD
XCOPY * ..\..\..\..\%RELEASEDIR% /S /Y
CD ..\..\..\..\src
..\bin\x86\win32\7za.exe a -tzip -mx9 ..\%RELEASEDIR%\dedicated.love common engine\server engine\shared engine\init.lua game\server game\shared game\init.lua public regions class.lua conf.lua main.lua
CD ..
