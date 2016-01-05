@ECHO OFF
GOTO :START

--======== Copyright 2013-2016, Planimeter, All rights reserved. ========--
--
-- Purpose:
--
--=======================================================================--

:START
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
IF EXIST "%ProgramFiles(x86)%" (
	ECHO "64-bit detected!"
	GOTO 64BIT
) ELSE (
	ECHO "32-bit detected!"
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
..\bin\x86\win32\7za.exe a -tzip -mx9 ..\%RELEASEDIR%\dedicated.love cfg common engine\server engine\shared engine\init.lua game\server game\shared game\init.lua public regions class.lua conf.lua main.lua
CD ..
