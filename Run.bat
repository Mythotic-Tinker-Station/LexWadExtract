@echo off
set /p "acronym=Enter 4 letter acronym(must be all CAPS): "
set /p "wad=Enter wad to convert: "
set /p "verbose=Enter verbosity(0-2): "

if not exist %cd%\%wad% goto 20

mkdir logs

rmdir pk3 /s /q
mkdir pk3\flats
mkdir pk3\patches
mkdir pk3\maps
mkdir pk3\sounds
mkdir pk3\textures
mkdir pk3\sprites

Love2D\love.exe src %wad% %acronym% %verbose%
goto 30

:20
echo "Error: Connot find %wad%"
pause

:30