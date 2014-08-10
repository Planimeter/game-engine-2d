@REM --======= Copyright © 2013-2014, Planimeter, All rights reserved. =======--
@REM --
@REM -- Purpose:
@REM --
@REM --=======================================================================--

@ECHO OFF
ECHO Grid Engine Dedicated Server
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
ECHO Launching Grid Engine Dedicated Server 64-bit in debug . . .
START bin\x64\win64\love\love.exe src -dedicated -debug
GOTO END

:32BIT
ECHO Launching Grid Engine Dedicated Server 32-bit in debug . . .
START bin\x86\win32\love\love.exe src -dedicated -debug
GOTO END

:END
