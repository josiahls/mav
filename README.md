# MAV: Mojo Audio Video
> Note: This library is alpha.

## Overview

Low level FFmpeg (`8.*`) bindings to Mojo for audio, image, and video processing.
Emphaisis should be placed on Low Level. This repo will never provide a high level API.
This project is originally part of ash_dynamics, but has been separated out to be used by other projects.

This package uses ffmpeg 8.0.1 from conda-forge. Please the LICENSE section for more information.

Simple example of generating a single image can be found in `third_party/mav/tests/test_ffmpeg/test_ffmpeg_h264_to_pgm.mojo`

High level API usage can be found in implementing repos such as:
- [ash_dynamics io module](https://github.com/josiahls/ash_dynamics/blob/main/ash_dynamics/image/io.mojo)

## Installation

### Ubuntu
```bash
# For encoding video and simulations into h264, the encoder must be installed
# user side / and separately:
# Per https://www.openh264.org/BINARY_LICENSE.txt
# It is important for the end user to be aware of 
# https://via-la.com/licensing-programs/avc-h-264/#license-fees if they intend
# to use the encoder in commercial solutions.

pixi shell -e use-openh264
# Note, if used in the default env, openh264 env will be used temporarily.
# The defualt enviroment will not have openh264 installed by default.
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

This software uses libraries from the FFmpeg project under the LGPLv2.1 license.

Distributed under the Apache 2.0 License with LLVM Exceptions. See [LICENSE](https://github.com/josiahls/mav/blob/main/LICENSE) and the LLVM [License](https://llvm.org/LICENSE.txt) for more information.

This project includes code from [Mojo Standard Library](https://github.com/modular/modular), licensed under the Apache License v2.0 with LLVM Exceptions (see the LLVM [License](https://llvm.org/LICENSE.txt)). MAX and Mojo usage and distribution are licensed under the [MAX & Mojo Community License](https://www.modular.com/legal/max-mojo-license).
