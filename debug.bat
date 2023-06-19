@echo off
set filename=%1
tasm /zi %filename%.asm
if ERRORLEVEL 1 goto end
echo Compile sucess
tlink /v %filename%.obj
if ERRORLEVEL 1 goto end
echo Link success
echo:
echo Executing program:
echo:
copy TDC2.TD TDCONFIG.TD
td -cTDCONFIG.TD %filename%.exe
del TDCONFIG.TD
:end
