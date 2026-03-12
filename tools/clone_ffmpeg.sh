#!/bin/bash
if [ ! -d third_party/ffmpeg/build ]; then 
    # If directory exists but configure is missing, remove it so we can clone fresh
    if [ -d third_party/ffmpeg ]; then
        echo 'FFmpeg directory exists but configure is missing. Removing and re-cloning...'
        rm -rf third_party/ffmpeg
    fi
    git clone https://github.com/FFmpeg/FFmpeg.git third_party/ffmpeg -b release/8.0
else 
    echo 'FFmpeg directory already exists with configure file.'
fi