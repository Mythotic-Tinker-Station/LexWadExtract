#!/bin/bash

# Function to read user input with a prompt
read_input() {
    read -p "$1" input
    echo $input
}

# Function to ensure input length
ensure_length() {
    echo $1 | awk -v len=$2 '{ if(length($0) < len) { print "Error: Input must be at least " len " characters." } else { print toupper(substr($0,1,len)) } }'
}

# Read mapset acronym
echo "Mapset Acronym:"
echo "  Must be 4 letters, less than 4 will error, any letters over 4 will be ignored."
acronym=$(ensure_length "$(read_input 'Enter 4 letter mapset acronym: ')" 4)
echo "---------------------------------------------------------------------------------------------"

# Read sprite acronym
echo "Sprite Acronym:"
echo "  Must be 2 letters, less than 2 will error, any letters over 2 will be ignored."
acronym_sprite=$(ensure_length "$(read_input 'Enter 2 letter sprite acronym: ')" 2)
echo "---------------------------------------------------------------------------------------------"

# Read actor replacement
echo "Actor replacement:"
echo "  Must be either Y or N. Any other setting will default to N."
things=$(read_input 'Enter either Y or N: ')
things=$(echo $things | awk '{ if($0 == "Y" || $0 == "y") print "Y"; else print "N" }')
echo "---------------------------------------------------------------------------------------------"

# Read WAD file name
echo "Wad File Name:"
echo "  Wad files can be placed in same folder, just the filename is required."
wad=$(read_input 'Enter wad to convert: ')
echo "---------------------------------------------------------------------------------------------"

# Read patch extraction option
echo "Patch Extraction:"
echo "  Must be either Y or N. Any other setting will default to N."
echo "  Extract patches from the wad?"
echo "  (only necessary if you are using a mapset that uses them as textures)"
patches=$(read_input 'Enter either Y or N: ')
patches=$(echo $patches | awk '{ if($0 == "Y" || $0 == "y") print "Y"; else print "N" }')
echo "---------------------------------------------------------------------------------------------"

# Read verbosity settings
echo "Verbose settings:"
echo "  0 = Basic."
echo "  1 = Detailed."
echo "  2 = Spam all the things."
echo "  3 = Same as 2, but includes logging of loading the iwad."
echo "  Blank = Same as 0"
verbose=$(read_input 'Enter verbosity (0-3 or blank): ')
echo "---------------------------------------------------------------------------------------------"

# Check if WAD file exists
if [ ! -f "$wad" ]; then
    echo "Error: Cannot find $wad"
    read -p "Press enter to continue..."
    exit 1
fi

# Create necessary directories
mkdir -p logs
rm -rf pk3
mkdir -p pk3/{flats,patches,maps,sounds,textures,sprites}
mkdir -p pk3/flats/$acronym
mkdir -p pk3/patches/$acronym
mkdir -p pk3/maps
mkdir -p pk3/sounds/$acronym
mkdir -p pk3/textures/$acronym
mkdir -p pk3/sprites/$acronym

# Run the conversion command
Love2D/love.exe src "$wad" "$acronym" "$verbose" "$acronym_sprite" "$things" "$patches"

