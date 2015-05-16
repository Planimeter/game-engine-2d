#!/bin/sh

##======== Copyright 2013-2014, Planimeter, All rights reserved. ========##
##
## Purpose:
##
##=======================================================================##

echo Grid Engine
echo Launching Grid Engine 64-bit in debug . . .
if [[ "$OSTYPE" == "linux-gnu" ]]; then
	love src/ -debug
elif [[ "$OSTYPE" == "darwin"* ]]; then
	bin/x64/macosx-x64/love.app/Contents/MacOS/love src/ -debug
fi
