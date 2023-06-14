@echo off
set filename=%1
tasm %filename%.asm
if ERRORLEVEL 1 goto end
echo Compile sucess
tlink %filename%.obj
if ERRORLEVEL 1 goto end
echo Link success
echo:
echo:
echo Executing program:
echo:
td %filename%.exe
:end
