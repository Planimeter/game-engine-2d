@ECHO OFF
GOTO :START

--======== Copyright 2013-2014, Planimeter, All rights reserved. ========--
--
-- Purpose: Selecting the correct Löve-version.
--
--=======================================================================--

:START
ECHO Grid Engine
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
IF EXIST %ProgramFiles(x86)% (
	ECHO "64-bit detected!"
	GOTO 64BIT
) ELSE (
	ECHO "32-bit detected!"
	GOTO 32BIT
)

:64BIT
ECHO Launching Grid Engine 64-bit in debug . . .
START bin\x64\win64\love\love.exe src -debug
GOTO END

:32BIT
ECHO Launching Grid Engine 32-bit in debug . . .
START bin\x86\win32\love\love.exe src -debug
GOTO END

:END
