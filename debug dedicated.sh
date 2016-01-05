#!/bin/sh

##======== Copyright 2013-2016, Planimeter, All rights reserved. ========##
##
## Purpose:
##
##=======================================================================##

echo Grid Engine Dedicated Server
echo Launching Grid Engine Dedicated Server 64-bit in debug . . .
if [[ "$OSTYPE" == "linux-gnu" ]]; then
	love src/ -dedicated -debug
elif [[ "$OSTYPE" == "darwin"* ]]; then
	bin/x64/macosx-x64/love.app/Contents/MacOS/love src/ -dedicated -debug
fi
