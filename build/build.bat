@echo off
echo mInternauta - FarmingSimulator Mod Building Tool
echo Loading ...
set zip="%~dp07za.exe"
set zip=%zip:"=%

set buildFrom=%1
set buildFrom=%buildFrom:"=%

set deployTo=%2
set deployTo=%deployTo:"=%

set buildName=%3
set buildName=%buildName:"=%

set fZipFile="%deployTo%\%buildName%.zip"
set fZipFile=%fZipFile:"=%

echo Build from: %buildFrom%
echo Deploy to: %deployTo%
echo Build name: %buildName%

echo Zip: %zip%
echo Deploy at: %fZipFile%

echo Building...

del /F /Q "%fZipFile%"
del /F /Q list.txt

echo %buildFrom%* > list.txt

"%zip%" a -tzip "%fZipFile%" @list.txt

echo Builded
