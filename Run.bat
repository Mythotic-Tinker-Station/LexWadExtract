@echo off

echo Mapset Acronym:
echo 	Must be 4 letters, less than 4 will error, any letters over 4 will be ignored.
echo 	Acronym will automaticly be ALL CAPS.
set /p "acronym=Enter 4 letter mapset acronym: "
echo ---------------------------------------------------------------------------------------------

echo Sprite Acronym:
echo 	Must be 2 letters, less than 2 will error, any letters over 2 will be ignored.
echo 	Acronym will automaticly be ALL CAPS.
set /p "acronym_sprite=Enter 2 letter sprite acronym: "
echo ---------------------------------------------------------------------------------------------

echo Actor replacement:
echo 	Must be either Y or N. Any other setting will default to N.
echo 	Actor replacement will follow actorlist.txt.
set /p "things=Enter either Y or N: "
echo ---------------------------------------------------------------------------------------------

echo Wad File Name:
echo 	Wad files can be placed in same folder, just the filename is required.
set /p "wad=Enter wad to convert: "
echo ---------------------------------------------------------------------------------------------

echo Verbose settings
echo 	0 = Basic.
echo 	1 = Detailed.
echo 	2 = Spam all the things.
echo 	3 = Same as 2, but includes logging of loading the iwad.
echo 	Blank = Same as 0
set /p "verbose=Enter verbosity(0-3 or blank): "
echo ---------------------------------------------------------------------------------------------

if not exist %cd%\%wad% goto 20

mkdir logs

rmdir pk3 /s /q
mkdir pk3\flats
mkdir pk3\patches
mkdir pk3\maps
mkdir pk3\sounds
mkdir pk3\textures
mkdir pk3\sprites

mkdir pk3\flats\%acronym%
mkdir pk3\patches\%acronym%
mkdir pk3\maps
mkdir pk3\sounds\%acronym%
mkdir pk3\textures\%acronym%
mkdir pk3\sprites\%acronym%

Love2D\love.exe src %wad% %acronym% %verbose% %acronym_sprite% %things% 1
goto 30

:20
echo "Error: Connot find %wad%"
pause

:30