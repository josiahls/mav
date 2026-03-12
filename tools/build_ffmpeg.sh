#!/bin/bash
# Follow how opencv links to ffmpeg: 
# https://github.com/opencv/opencv/blob/a08565253ee098eae55e893d3f8e5d9a011440a9/CMakeLists.txt#L1631
# and
# https://github.com/microsoft/vcpkg/issues/19334
# and guidance from:
# https://www.ffmpeg.org/legal.html
# Install / configure only these packages:
# "avcodec"
# "avformat"
# "swresample"
# "swscale"

cd ./third_party/ffmpeg

BUILD_PATH=$(pwd)/build
FORCE_FFMPEG_BUILD=${FORCE_FFMPEG_BUILD:-false}

if [ ! -d ${BUILD_PATH} ] || [ "${FORCE_FFMPEG_BUILD}" = true ]; then
    echo $(ls -la)
    echo "Building ffmpeg in ${BUILD_PATH}"
    # For put the built dir in the same directory. Eventually change to the default
    # location on linux.

    # For: --enable-libopenh264, this package must be installed: 
    #      apt install libopenh264-dev
    default_configure_flags=(
        --prefix=${BUILD_PATH} \
        --enable-shared \
        --disable-avdevice \
        --disable-avfilter \
        --disable-pthreads \
        --disable-w32threads \
        --disable-os2threads \
        --disable-network \
        --disable-dwt \
        --disable-error-resilience \
        --disable-lsp \
        --disable-faan \
        --disable-iamf \
        --disable-pixelutils
        # We want to leave these enabled.
        # --disable-avcodec 
        # --disable-swresample
        # --disable-swscale
        # --disable-avformat
    )

    if [[ "${CONFIGURE_LIBOPENH264:-}" == "true" ]]; then
        default_configure_flags+=(--enable-libopenh264)
    fi

    ./configure "${default_configure_flags[@]}"

    make
    make install
else
    echo "FFmpeg already built in ${BUILD_PATH}"
fi