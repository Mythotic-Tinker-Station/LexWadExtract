@echo off
set /p "acronym=Enter 4 letter acronym(must be all CAPS): "
set /p "wad=Enter wad to convert: "
echo Verbose settings
echo 	0 = Basic.
echo 	1 = Detailed.
echo 	2 = Spam all the things.
echo 	3 = Same as 2, but includes logging of loading the doom2.wad.
echo 	Blank = Same as 0
set /p "verbose=Enter verbosity(0-3 or blank): "

if not exist %cd%\%wad% goto 20

mkdir logs

rmdir pk3 /s /q
mkdir pk3\flats
mkdir pk3\patches
mkdir pk3\maps
mkdir pk3\sounds
mkdir pk3\textures
mkdir pk3\sprites
mkdir pk3\music

Love2D\love.exe src %wad% %acronym% %verbose%
goto 30

:20
echo "Error: Connot find %wad%"
pause

:30