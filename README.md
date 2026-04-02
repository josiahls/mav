# MAV: Mojo Audio Video
> Note: This library is alpha.

## Overview

Low level FFmpeg (`8.*`) bindings to Mojo for audio, image, and video processing.
Emphasis should be placed on Low Level. This repo will never provide a high level API.
This project is originally part of ash_dynamics, but has been separated out to be used by other projects.

This package uses ffmpeg 8.0.1 from conda-forge. Please see the LICENSE section for more information.

Simple example of generating a single image can be found in `tests/test_ffmpeg/test_image_example.mojo`

High level API usage can be found in implementing repos such as:
- [ash_dynamics io module](https://github.com/josiahls/ash_dynamics/blob/main/ash_dynamics/image/io.mojo)

![./test_video_save.gif](./test_video_save.gif)

## Installation

### Pixi / Conda

`mav` will install `FFmpeg`, however the Mojo compiler must be pointed to those
libraries.
```toml
[workspace]
channels = [
    "https://repo.prefix.dev/modular-community", 
    "conda-forge"
]

[activation.env]
LIBRARY_PATH = "$CONDA_PREFIX/lib:$LIBRARY_PATH"
MAV_LINKERS = " -Xlinker -lavutil -Xlinker -lavcodec -Xlinker -lswresample -Xlinker -lswscale -Xlinker -lavformat"

[dependencies]
mav = "==0.0.4"
```

Code execution requires including the linker flags before running any code that 
uses the `mav` package:
```bash
pixi run mojo build $MAV_LINKERS file.mojo -o file
```


### Ubuntu ∫
```bash
# For encoding video and simulations into h264, the encoder must be installed
# user side / and separately:
# Per https://www.openh264.org/BINARY_LICENSE.txt
# It is important for the end user to be aware of 
# https://via-la.com/licensing-programs/avc-h-264/#license-fees if they intend
# to use the encoder in commercial solutions.

pixi shell -e use-openh264
# Note, if used in the default env, openh264 env will be used temporarily.
# The default environment will not have openh264 installed by default.
pixi run test_all
```

## Demo
```bash
pixi run test tests/test_ffmpeg/test_ffmpeg_h264_to_mp4.mojo
```
Output example: `test_data/dash_manual/testsrc_320x180_30fps_2s.mp4` (under `PIXI_PROJECT_ROOT` / project root when set).

### Image encode/decode (`test_image_example.mojo`)

Self-contained demo: read one PNG via libavcodec, write PNG and JPEG via encoders + libswscale (`RGB24` / `YUV420P` as appropriate). Not a public API—reference only.

```bash
pixi run test tests/test_ffmpeg/test_image_example.mojo
```

| | Path (relative to project root / `PIXI_PROJECT_ROOT`) |
|---|--------------------------------------------------------|
| **Input** | `test_data/generate_test_videos_testsrc_128x128.png` |
| **Outputs** | `test_data/test_image_example/test_image_write.png` |
| | `test_data/test_image_example/test_image_write.jpg` |

### Video decode → encode (`test_video_example.mojo`)

Self-contained demo: read one MP4, decode frames to in-memory RGBA, then mux to MP4, WebM, and GIF. Not a public API—reference only.

```bash
pixi run test tests/test_ffmpeg/test_video_example.mojo
```

| | Path (relative to project root / `PIXI_PROJECT_ROOT`) |
|---|--------------------------------------------------------|
| **Input** | `test_data/generate_test_videos_testsrc_320x180_30fps_2s.mp4` |
| **Outputs** | `test_data/test_mav/test_video_save.mp4` |
| | `test_data/test_mav/test_video_save.webm` |
| | `test_data/test_video_example/test_video_save.gif` |

Ensure `test_data/` assets exist (e.g. run your repo’s test-asset generators if present). The video demo creates output directories under `test_data/` as needed.

## Developer Notes
If working in cursor, you can change the editor to use cursor instead.
```bash
git config core.editor "cursor --wait"
```

## License

This software uses libraries from the FFmpeg project under the LGPLv2.1 license.

Distributed under the Apache 2.0 License with LLVM Exceptions. See [LICENSE](https://github.com/josiahls/mav/blob/main/LICENSE) and the LLVM [License](https://llvm.org/LICENSE.txt) for more information.

This project includes code from [Mojo Standard Library](https://github.com/modular/modular), licensed under the Apache License v2.0 with LLVM Exceptions (see the LLVM [License](https://llvm.org/LICENSE.txt)). MAX and Mojo usage and distribution are licensed under the [MAX & Mojo Community License](https://www.modular.com/legal/max-mojo-license).
