#!/bin/bash
mkdir logs

rm -rf ../../pk3
mkdir ../../pk3
mkdir ../../pk3/FLATS
mkdir ../../pk3/PATCHES
mkdir ../../pk3/MAPS
mkdir ../../pk3/SOUNDS
mkdir ../../pk3/TEXTURES

Love2D/love.app/Contents/MacOS/love "src"