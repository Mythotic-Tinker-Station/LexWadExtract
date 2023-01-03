#!/bin/bash
mkdir logs

rm -rf pk3
mkdir -p pk3/FLATS
mkdir -p pk3/PATCHES
mkdir -p pk3/MAPS
mkdir -p pk3/SOUNDS
mkdir -p pk3/TEXTURES

Love2D/love.app/Contents/MacOS/love "src" "$@"
