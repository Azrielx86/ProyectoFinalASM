@echo off
set filename=%1
tasm /zi %filename%.asm
if ERRORLEVEL 1 goto end
echo Compile sucess
tlink /v/3 %filename%.obj
if ERRORLEVEL 1 goto end
echo Link success
echo:
echo:
echo Executing program:
echo:
td %filename%.exe
:end
