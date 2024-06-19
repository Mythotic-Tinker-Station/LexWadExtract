@echo off

echo Mapset Acronym:
echo 	Must be 4 letters, less than 4 will error, any letters over 4 will be ignored.
echo 	Acronym will automaticly be ALL CAPS.
set acronym="TART"
echo ---------------------------------------------------------------------------------------------

echo Sprite Acronym:
echo 	Must be 2 letters, less than 2 will error, any letters over 2 will be ignored.
echo 	Acronym will automaticly be ALL CAPS.
set acronym_sprite="TT"
echo ---------------------------------------------------------------------------------------------

echo Actor replacement:
echo 	Must be either Y or N. Any other setting will default to N.
echo 	Actor replacement will follow actorlist.txt.
set things="Y"
echo ---------------------------------------------------------------------------------------------

echo Wad File Name:
echo 	Wad files can be placed in same folder, just the filename is required.
set wad="Tartaru5.wad"
echo ---------------------------------------------------------------------------------------------

echo Patch Extraction:
echo 	Must be either Y or N. Any other setting will default to N.
echo 	Extract patches from the wad?
echo    (only necessary if you are using a mapset that uses them as textures)
set patches="Y"
echo ---------------------------------------------------------------------------------------------

echo Verbose settings
echo 	0 = Basic.
echo 	1 = Detailed.
echo 	2 = Spam all the things.
echo 	3 = Same as 2, but includes logging of loading the iwad.
echo 	Blank = Same as 0
set verbose="2"
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

Love2D\love.exe src %wad% %acronym% %verbose% %acronym_sprite% %things% %patches%
goto 30

:20
echo "Error: Connot find %wad%"
pause

:30