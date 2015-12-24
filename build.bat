@echo off

echo Building ...
cd %~dp0\build\

build.bat "%~dp0src\" "%UserProfile%\Documents\My Games\FarmingSimulator2015\mods" "AgroSponsor"

pause 