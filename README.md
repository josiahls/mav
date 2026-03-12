# MAV: Mojo Audio Video
> Note: This library is alpha.

## Overview

Low level FFmpeg (`8.*`) bindings to Mojo for audio, image, and video processing.
Emphaisis should be placed on Low Level. This repo will never provide a high level API.
This project is originally part of ash_dynamics, but has been broken out to be used by other projects.

Actual binaries of this library will be distributed around Mojo's 1.0 release and once
FFmpeg 8 is released for Debian. For the time being, this library will track Mojo nightly builds and
will remain unstable until Mojo 1.0 is released.

Simple example of generating a single image can be found in `third_party/mav/tests/test_ffmpeg/test_ffmpeg_h264_to_pgm.mojo`

## System Requirements

Requires ffmpeg `8.*.*`.

Most recent official release:
```
FFmpeg 8.0.1 "Huffman"

libavutil      60.  8.100
libavcodec     62. 11.100
libavformat    62.  3.100
libswscale      9.  1.100
libswresample   6.  1.100
```
Note that as of 2026-03-11, ffmpeg 8.0.1 is not yet released as an installable deb package.

## Installation

### Ubuntu
Note, this will attempt to build ffmpeg from source. 
This project is build to be binded against ffmpeg 8.0.0 which has not been released
yet as an installable deb package reference [the debian ffmpeg tracker](https://tracker.debian.org/pkg/ffmpeg).
```bash
# For encoding video and simulations into h264, the encoder must be installed
# user side / and separately:
# Per https://www.openh264.org/BINARY_LICENSE.txt
# It is important for the end user to be aware of 
# https://via-la.com/licensing-programs/avc-h-264/#license-fees if they intend
# to use the encoder in commercial solutions.

pixi shell
export CONFIGURE_LIBOPENH264=true
pixi run test_all
```

## Demo
```bash
pixi run test tests/test_ffmpeg/test_ffmpeg_h264_to_mp4.mojo
```

`test_data/dash_manual/testsrc_320x180_30fps_2s.mp4`

## Developer Notes
If working in cursor, you can change the editor to use cursor instead.
```bash
git config core.editor "cursor --wait"
```

## License

Distributed under the Apache 2.0 License with LLVM Exceptions. See [LICENSE](https://github.com/Mojo-Numerics-and-Algorithms-group/NuMojo/blob/main/LICENSE) and the LLVM [License](https://llvm.org/LICENSE.txt) for more information.

This project includes code from [Mojo Standard Library](https://github.com/modular/modular), licensed under the Apache License v2.0 with LLVM Exceptions (see the LLVM [License](https://llvm.org/LICENSE.txt)). MAX and Mojo usage and distribution are licensed under the [MAX & Mojo Community License](https://www.modular.com/legal/max-mojo-license).
