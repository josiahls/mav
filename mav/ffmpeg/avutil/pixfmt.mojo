"See https://www.ffmpeg.org/doxygen/8.0/pixfmt_8h.html."
from std.ffi import c_int


# TODO: We could move the comments for each enum to be for the format:
# var thing
# "documentation of thing"
# which should show up in the docs then


@fieldwise_init("implicit")
struct AVPixelFormat(Movable, Writable):
    comptime ENUM_DTYPE = c_int

    var _value: Self.ENUM_DTYPE

    fn inc(self) -> Self:
        return Self(self._value + 1)

    comptime AV_PIX_FMT_NONE = Self(-1)

    comptime AV_PIX_FMT_YUV420P = Self(
        Self.AV_PIX_FMT_NONE._value
    ).inc()  #  planar YUV 4:2:0, 12bpp, (1 Cr & Cb sample per 2x2 Y samples)
    comptime AV_PIX_FMT_YUYV422 = Self(
        Self.AV_PIX_FMT_YUV420P._value
    ).inc()  #  packed YUV 4:2:2, 16bpp, Y0 Cb Y1 Cr
    comptime AV_PIX_FMT_RGB24 = Self(
        Self.AV_PIX_FMT_YUYV422._value
    ).inc()  #  packed RGB 8:8:8, 24bpp, RGBRGB...
    comptime AV_PIX_FMT_BGR24 = Self(
        Self.AV_PIX_FMT_RGB24._value
    ).inc()  #  packed RGB 8:8:8, 24bpp, BGRBGR...
    comptime AV_PIX_FMT_YUV422P = Self(
        Self.AV_PIX_FMT_BGR24._value
    ).inc()  #  planar YUV 4:2:2, 16bpp, (1 Cr & Cb sample per 2x1 Y samples)
    comptime AV_PIX_FMT_YUV444P = Self(
        Self.AV_PIX_FMT_YUV422P._value
    ).inc()  #  planar YUV 4:4:4, 24bpp, (1 Cr & Cb sample per 1x1 Y samples)
    comptime AV_PIX_FMT_YUV410P = Self(
        Self.AV_PIX_FMT_YUV444P._value
    ).inc()  #  planar YUV 4:1:0,  9bpp, (1 Cr & Cb sample per 4x4 Y samples)
    comptime AV_PIX_FMT_YUV411P = Self(
        Self.AV_PIX_FMT_YUV410P._value
    ).inc()  #  planar YUV 4:1:1, 12bpp, (1 Cr & Cb sample per 4x1 Y samples)
    comptime AV_PIX_FMT_GRAY8 = Self(
        Self.AV_PIX_FMT_YUV411P._value
    ).inc()  #       Y        ,  8bpp
    comptime AV_PIX_FMT_MONOWHITE = Self(
        Self.AV_PIX_FMT_GRAY8._value
    ).inc()  #       Y        ,  1bpp, 0 is white, 1 is black, in each byte pixels are ordered from the msb to the lsb
    comptime AV_PIX_FMT_MONOBLACK = Self(
        Self.AV_PIX_FMT_MONOWHITE._value
    ).inc()  #       Y        ,  1bpp, 0 is black, 1 is white, in each byte pixels are ordered from the msb to the lsb
    comptime AV_PIX_FMT_PAL8 = Self(
        Self.AV_PIX_FMT_MONOBLACK._value
    ).inc()  # 8 bits with AV_PIX_FMT_RGB32 palette
    comptime AV_PIX_FMT_YUVJ420P = Self(
        Self.AV_PIX_FMT_PAL8._value
    ).inc()  # planar YUV 4:2:0, 12bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV420P and setting color_range
    comptime AV_PIX_FMT_YUVJ422P = Self(
        Self.AV_PIX_FMT_YUVJ420P._value
    ).inc()  # planar YUV 4:2:2, 16bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV422P and setting color_range
    comptime AV_PIX_FMT_YUVJ444P = Self(
        Self.AV_PIX_FMT_YUVJ422P._value
    ).inc()  # planar YUV 4:4:4, 24bpp, full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV444P and setting color_range
    comptime AV_PIX_FMT_UYVY422 = Self(
        Self.AV_PIX_FMT_YUVJ444P._value
    ).inc()  # packed YUV 4:2:2, 16bpp, Cb Y0 Cr Y1
    comptime AV_PIX_FMT_UYYVYY411 = Self(
        Self.AV_PIX_FMT_UYVY422._value
    ).inc()  # packed YUV 4:1:1, 12bpp, Cb Y0 Y1 Cr Y2 Y3
    comptime AV_PIX_FMT_BGR8 = Self(
        Self.AV_PIX_FMT_UYYVYY411._value
    ).inc()  # packed RGB 3:3:2,  8bpp, (msb)2B 3G 3R(lsb)
    comptime AV_PIX_FMT_BGR4 = Self(
        Self.AV_PIX_FMT_BGR8._value
    ).inc()  # packed RGB 1:2:1 bitstream,  4bpp, (msb)1B 2G 1R(lsb), a byte contains two pixels, the first pixel in the byte is the one composed by the 4 msb bits
    comptime AV_PIX_FMT_BGR4_BYTE = Self(
        Self.AV_PIX_FMT_BGR4._value
    ).inc()  # packed RGB 1:2:1,  8bpp, (msb)1B 2G 1R(lsb)
    comptime AV_PIX_FMT_RGB8 = Self(
        Self.AV_PIX_FMT_BGR4_BYTE._value
    ).inc()  # packed RGB 3:3:2,  8bpp, (msb)3R 3G 2B(lsb)
    comptime AV_PIX_FMT_RGB4 = Self(
        Self.AV_PIX_FMT_RGB8._value
    ).inc()  # packed RGB 1:2:1 bitstream,  4bpp, (msb)1R 2G 1B(lsb), a byte contains two pixels, the first pixel in the byte is the one composed by the 4 msb bits
    comptime AV_PIX_FMT_RGB4_BYTE = Self(
        Self.AV_PIX_FMT_RGB4._value
    ).inc()  # packed RGB 1:2:1,  8bpp, (msb)1R 2G 1B(lsb)
    comptime AV_PIX_FMT_NV12 = Self(
        Self.AV_PIX_FMT_RGB4_BYTE._value
    ).inc()  # planar YUV 4:2:0, 12bpp, 1 plane for Y and 1 plane for the UV components, which are interleaved (first byte U and the following byte V)
    comptime AV_PIX_FMT_NV21 = Self(
        Self.AV_PIX_FMT_NV12._value
    ).inc()  # as above, but U and V bytes are swapped

    comptime AV_PIX_FMT_ARGB = Self(
        Self.AV_PIX_FMT_NV21._value
    ).inc()  # packed ARGB 8:8:8:8, 32bpp, ARGBARGB...
    comptime AV_PIX_FMT_RGBA = Self(
        Self.AV_PIX_FMT_ARGB._value
    ).inc()  # packed RGBA 8:8:8:8, 32bpp, RGBARGBA...
    comptime AV_PIX_FMT_ABGR = Self(
        Self.AV_PIX_FMT_RGBA._value
    ).inc()  # packed ABGR 8:8:8:8, 32bpp, ABGRABGR...
    comptime AV_PIX_FMT_BGRA = Self(
        Self.AV_PIX_FMT_ABGR._value
    ).inc()  # packed BGRA 8:8:8:8, 32bpp, BGRABGRA...

    comptime AV_PIX_FMT_GRAY16BE = Self(
        Self.AV_PIX_FMT_BGRA._value
    ).inc()  #        Y        , 16bpp, big-endian
    comptime AV_PIX_FMT_GRAY16LE = Self(
        Self.AV_PIX_FMT_GRAY16BE._value
    ).inc()  #        Y        , 16bpp, little-endian
    comptime AV_PIX_FMT_YUV440P = Self(
        Self.AV_PIX_FMT_GRAY16LE._value
    ).inc()  # planar YUV 4:4:0 (1 Cr & Cb sample per 1x2 Y samples)
    comptime AV_PIX_FMT_YUVJ440P = Self(
        Self.AV_PIX_FMT_YUV440P._value
    ).inc()  # planar YUV 4:4:0 full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV440P and setting color_range
    comptime AV_PIX_FMT_YUVA420P = Self(
        Self.AV_PIX_FMT_YUVJ440P._value
    ).inc()  # planar YUV 4:2:0, 20bpp, (1 Cr & Cb sample per 2x2 Y & A samples)
    comptime AV_PIX_FMT_RGB48BE = Self(
        Self.AV_PIX_FMT_YUVA420P._value
    ).inc()  # packed RGB 16:16:16, 48bpp, 16R, 16G, 16B, the 2-byte value for each R/G/B component is stored as big-endian
    comptime AV_PIX_FMT_RGB48LE = Self(
        Self.AV_PIX_FMT_RGB48BE._value
    ).inc()  # packed RGB 16:16:16, 48bpp, 16R, 16G, 16B, the 2-byte value for each R/G/B component is stored as little-endian

    comptime AV_PIX_FMT_RGB565BE = Self(
        Self.AV_PIX_FMT_RGB48LE._value
    ).inc()  # packed RGB 5:6:5, 16bpp, (msb)   5R 6G 5B(lsb), big-endian
    comptime AV_PIX_FMT_RGB565LE = Self(
        Self.AV_PIX_FMT_RGB565BE._value
    ).inc()  # packed RGB 5:6:5, 16bpp, (msb)   5R 6G 5B(lsb), little-endian
    comptime AV_PIX_FMT_RGB555BE = Self(
        Self.AV_PIX_FMT_RGB565LE._value
    ).inc()  # packed RGB 5:5:5, 16bpp, (msb)1X 5R 5G 5B(lsb), big-endian   , X=unused/undefined
    comptime AV_PIX_FMT_RGB555LE = Self(
        Self.AV_PIX_FMT_RGB555BE._value
    ).inc()  # packed RGB 5:5:5, 16bpp, (msb)1X 5R 5G 5B(lsb), little-endian, X=unused/undefined

    comptime AV_PIX_FMT_BGR565BE = Self(
        Self.AV_PIX_FMT_RGB555LE._value
    ).inc()  # packed BGR 5:6:5, 16bpp, (msb)   5B 6G 5R(lsb), big-endian
    comptime AV_PIX_FMT_BGR565LE = Self(
        Self.AV_PIX_FMT_BGR565BE._value
    ).inc()  # packed BGR 5:6:5, 16bpp, (msb)   5B 6G 5R(lsb), little-endian
    comptime AV_PIX_FMT_BGR555BE = Self(
        Self.AV_PIX_FMT_BGR565LE._value
    ).inc()  # packed BGR 5:5:5, 16bpp, (msb)1X 5B 5G 5R(lsb), big-endian   , X=unused/undefined
    comptime AV_PIX_FMT_BGR555LE = Self(
        Self.AV_PIX_FMT_BGR555BE._value
    ).inc()  # packed BGR 5:5:5, 16bpp, (msb)1X 5B 5G 5R(lsb), little-endian, X=unused/undefined

    comptime AV_PIX_FMT_VAAPI = Self(Self.AV_PIX_FMT_BGR555LE._value).inc()

    comptime AV_PIX_FMT_YUV420P16LE = Self(
        Self.AV_PIX_FMT_VAAPI._value
    ).inc()  # planar YUV 4:2:0, 24bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
    comptime AV_PIX_FMT_YUV420P16BE = Self(
        Self.AV_PIX_FMT_YUV420P16LE._value
    ).inc()  # planar YUV 4:2:0, 24bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
    comptime AV_PIX_FMT_YUV422P16LE = Self(
        Self.AV_PIX_FMT_YUV420P16BE._value
    ).inc()  # planar YUV 4:2:2, 32bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    comptime AV_PIX_FMT_YUV422P16BE = Self(
        Self.AV_PIX_FMT_YUV422P16LE._value
    ).inc()  # planar YUV 4:2:2, 32bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
    comptime AV_PIX_FMT_YUV444P16LE = Self(
        Self.AV_PIX_FMT_YUV422P16BE._value
    ).inc()  # planar YUV 4:4:4, 48bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
    comptime AV_PIX_FMT_YUV444P16BE = Self(
        Self.AV_PIX_FMT_YUV444P16LE._value
    ).inc()  # planar YUV 4:4:4, 48bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
    comptime AV_PIX_FMT_DXVA2_VLD = Self(
        Self.AV_PIX_FMT_YUV444P16BE._value
    ).inc()  # HW decoding through DXVA2, Picture.data[3] contains a LPDIRECT3DSURFACE9 pointer

    comptime AV_PIX_FMT_RGB444LE = Self(
        Self.AV_PIX_FMT_DXVA2_VLD._value
    ).inc()  # packed RGB 4:4:4, 16bpp, (msb)4X 4R 4G 4B(lsb), little-endian, X=unused/undefined
    comptime AV_PIX_FMT_RGB444BE = Self(
        Self.AV_PIX_FMT_RGB444LE._value
    ).inc()  # packed RGB 4:4:4, 16bpp, (msb)4X 4R 4G 4B(lsb), big-endian,    X=unused/undefined
    comptime AV_PIX_FMT_BGR444LE = Self(
        Self.AV_PIX_FMT_RGB444BE._value
    ).inc()  # packed BGR 4:4:4, 16bpp, (msb)4X 4B 4G 4R(lsb), little-endian, X=unused/undefined
    comptime AV_PIX_FMT_BGR444BE = Self(
        Self.AV_PIX_FMT_BGR444LE._value
    ).inc()  # packed BGR 4:4:4, 16bpp, (msb)4X 4B 4G 4R(lsb), big-endian,    X=unused/undefined
    comptime AV_PIX_FMT_YA8 = Self(
        Self.AV_PIX_FMT_BGR444BE._value
    ).inc()  # 8 bits gray, 8 bits alpha

    comptime AV_PIX_FMT_Y400A = Self(
        Self.AV_PIX_FMT_YA8._value
    )  # alias for AV_PIX_FMT_YA8
    comptime AV_PIX_FMT_GRAY8A = Self(
        Self.AV_PIX_FMT_YA8._value
    )  # alias for AV_PIX_FMT_YA8

    comptime AV_PIX_FMT_BGR48BE = Self(
        Self.AV_PIX_FMT_GRAY8A._value
    ).inc()  # packed RGB 16:16:16, 48bpp, 16B, 16G, 16R, the 2-byte value for each R/G/B component is stored as big-endian
    comptime AV_PIX_FMT_BGR48LE = Self(
        Self.AV_PIX_FMT_BGR48BE._value
    ).inc()  # packed RGB 16:16:16, 48bpp, 16B, 16G, 16R, the 2-byte value for each R/G/B component is stored as little-endian

    #
    # The following 12 formats have the disadvantage of needing 1 format for each bit depth.
    # Notice that each 9/10 bits sample is stored in 16 bits with extra padding.
    # If you want to support multiple bit depths, then using AV_PIX_FMT_YUV420P16* with the bpp stored separately is better.
    #
    comptime AV_PIX_FMT_YUV420P9BE = Self(
        Self.AV_PIX_FMT_BGR48LE._value
    ).inc()  # planar YUV 4:2:0, 13.5bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
    comptime AV_PIX_FMT_YUV420P9LE = Self(
        Self.AV_PIX_FMT_YUV420P9BE._value
    ).inc()  # planar YUV 4:2:0, 13.5bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
    comptime AV_PIX_FMT_YUV420P10BE = Self(
        Self.AV_PIX_FMT_YUV420P9LE._value
    ).inc()  # planar YUV 4:2:0, 15bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
    comptime AV_PIX_FMT_YUV420P10LE = Self(
        Self.AV_PIX_FMT_YUV420P10BE._value
    ).inc()  # planar YUV 4:2:0, 15bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
    comptime AV_PIX_FMT_YUV422P10BE = Self(
        Self.AV_PIX_FMT_YUV420P10LE._value
    ).inc()  # planar YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
    comptime AV_PIX_FMT_YUV422P10LE = Self(
        Self.AV_PIX_FMT_YUV422P10BE._value
    ).inc()  # planar YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    comptime AV_PIX_FMT_YUV444P9BE = Self(
        Self.AV_PIX_FMT_YUV422P10LE._value
    ).inc()  # planar YUV 4:4:4, 27bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
    comptime AV_PIX_FMT_YUV444P9LE = Self(
        Self.AV_PIX_FMT_YUV444P9BE._value
    ).inc()  # planar YUV 4:4:4, 27bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
    comptime AV_PIX_FMT_YUV444P10BE = Self(
        Self.AV_PIX_FMT_YUV444P9LE._value
    ).inc()  # planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
    comptime AV_PIX_FMT_YUV444P10LE = Self(
        Self.AV_PIX_FMT_YUV444P10BE._value
    ).inc()  # planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
    comptime AV_PIX_FMT_YUV422P9BE = Self(
        Self.AV_PIX_FMT_YUV444P10LE._value
    ).inc()  # planar YUV 4:2:2, 18bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
    comptime AV_PIX_FMT_YUV422P9LE = Self(
        Self.AV_PIX_FMT_YUV422P9BE._value
    ).inc()  # planar YUV 4:2:2, 18bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    comptime AV_PIX_FMT_GBRP = Self(
        Self.AV_PIX_FMT_YUV422P9LE._value
    ).inc()  # planar GBR 4:4:4 24bpp
    comptime AV_PIX_FMT_GBR24P = Self(
        Self.AV_PIX_FMT_GBRP._value
    )  # alias for #AV_PIX_FMT_GBRP
    comptime AV_PIX_FMT_GBRP9BE = Self(
        Self.AV_PIX_FMT_GBR24P._value
    ).inc()  # planar GBR 4:4:4 27bpp, big-endian
    comptime AV_PIX_FMT_GBRP9LE = Self(
        Self.AV_PIX_FMT_GBRP9BE._value
    ).inc()  # planar GBR 4:4:4 27bpp, little-endian
    comptime AV_PIX_FMT_GBRP10BE = Self(
        Self.AV_PIX_FMT_GBRP9LE._value
    ).inc()  # planar GBR 4:4:4 30bpp, big-endian
    comptime AV_PIX_FMT_GBRP10LE = Self(
        Self.AV_PIX_FMT_GBRP10BE._value
    ).inc()  # planar GBR 4:4:4 30bpp, little-endian
    comptime AV_PIX_FMT_GBRP16BE = Self(
        Self.AV_PIX_FMT_GBRP10LE._value
    ).inc()  # planar GBR 4:4:4 48bpp, big-endian
    comptime AV_PIX_FMT_GBRP16LE = Self(
        Self.AV_PIX_FMT_GBRP16BE._value
    ).inc()  # planar GBR 4:4:4 48bpp, little-endian
    comptime AV_PIX_FMT_YUVA422P = Self(
        Self.AV_PIX_FMT_GBRP16LE._value
    ).inc()  # planar YUV 4:2:2 24bpp, (1 Cr & Cb sample per 2x1 Y & A samples)
    comptime AV_PIX_FMT_YUVA444P = Self(
        Self.AV_PIX_FMT_YUVA422P._value
    ).inc()  # planar YUV 4:4:4 32bpp, (1 Cr & Cb sample per 1x1 Y & A samples)
    comptime AV_PIX_FMT_YUVA420P9BE = Self(
        Self.AV_PIX_FMT_YUVA444P._value
    ).inc()  # planar YUV 4:2:0 22.5bpp, (1 Cr & Cb sample per 2x2 Y & A samples), big-endian
    comptime AV_PIX_FMT_YUVA420P9LE = Self(
        Self.AV_PIX_FMT_YUVA420P9BE._value
    ).inc()  # planar YUV 4:2:0 22.5bpp, (1 Cr & Cb sample per 2x2 Y & A samples), little-endian
    comptime AV_PIX_FMT_YUVA422P9BE = Self(
        Self.AV_PIX_FMT_YUVA420P9LE._value
    ).inc()  # planar YUV 4:2:2 27bpp, (1 Cr & Cb sample per 2x1 Y & A samples), big-endian
    comptime AV_PIX_FMT_YUVA422P9LE = Self(
        Self.AV_PIX_FMT_YUVA422P9BE._value
    ).inc()  # planar YUV 4:2:2 27bpp, (1 Cr & Cb sample per 2x1 Y & A samples), little-endian
    comptime AV_PIX_FMT_YUVA444P9BE = Self(
        Self.AV_PIX_FMT_YUVA422P9LE._value
    ).inc()  # planar YUV 4:4:4 36bpp, (1 Cr & Cb sample per 1x1 Y & A samples), big-endian
    comptime AV_PIX_FMT_YUVA444P9LE = Self(
        Self.AV_PIX_FMT_YUVA444P9BE._value
    ).inc()  # planar YUV 4:4:4 36bpp, (1 Cr & Cb sample per 1x1 Y & A samples), little-endian
    comptime AV_PIX_FMT_YUVA420P10BE = Self(
        Self.AV_PIX_FMT_YUVA444P9LE._value
    ).inc()  # planar YUV 4:2:0 25bpp, (1 Cr & Cb sample per 2x2 Y & A samples, big-endian)
    comptime AV_PIX_FMT_YUVA420P10LE = Self(
        Self.AV_PIX_FMT_YUVA420P10BE._value
    ).inc()  # planar YUV 4:2:0 25bpp, (1 Cr & Cb sample per 2x2 Y & A samples, little-endian)
    comptime AV_PIX_FMT_YUVA422P10BE = Self(
        Self.AV_PIX_FMT_YUVA420P10LE._value
    ).inc()  # planar YUV 4:2:2 30bpp, (1 Cr & Cb sample per 2x1 Y & A samples, big-endian)
    comptime AV_PIX_FMT_YUVA422P10LE = Self(
        Self.AV_PIX_FMT_YUVA422P10BE._value
    ).inc()  # planar YUV 4:2:2 30bpp, (1 Cr & Cb sample per 2x1 Y & A samples, little-endian)
    comptime AV_PIX_FMT_YUVA444P10BE = Self(
        Self.AV_PIX_FMT_YUVA422P10LE._value
    ).inc()  # planar YUV 4:4:4 40bpp, (1 Cr & Cb sample per 1x1 Y & A samples, big-endian)
    comptime AV_PIX_FMT_YUVA444P10LE = Self(
        Self.AV_PIX_FMT_YUVA444P10BE._value
    ).inc()  # planar YUV 4:4:4 40bpp, (1 Cr & Cb sample per 1x1 Y & A samples, little-endian)
    comptime AV_PIX_FMT_YUVA420P16BE = Self(
        Self.AV_PIX_FMT_YUVA444P10LE._value
    ).inc()  # planar YUV 4:2:0 40bpp, (1 Cr & Cb sample per 2x2 Y & A samples, big-endian)
    comptime AV_PIX_FMT_YUVA420P16LE = Self(
        Self.AV_PIX_FMT_YUVA420P16BE._value
    ).inc()  # planar YUV 4:2:0 40bpp, (1 Cr & Cb sample per 2x2 Y & A samples, little-endian)
    comptime AV_PIX_FMT_YUVA422P16BE = Self(
        Self.AV_PIX_FMT_YUVA420P16LE._value
    ).inc()  # planar YUV 4:2:2 48bpp, (1 Cr & Cb sample per 2x1 Y & A samples, big-endian)
    comptime AV_PIX_FMT_YUVA422P16LE = Self(
        Self.AV_PIX_FMT_YUVA422P16BE._value
    ).inc()  # planar YUV 4:2:2 48bpp, (1 Cr & Cb sample per 2x1 Y & A samples, little-endian)
    comptime AV_PIX_FMT_YUVA444P16BE = Self(
        Self.AV_PIX_FMT_YUVA422P16LE._value
    ).inc()  # planar YUV 4:4:4 64bpp, (1 Cr & Cb sample per 1x1 Y & A samples, big-endian)
    comptime AV_PIX_FMT_YUVA444P16LE = Self(
        Self.AV_PIX_FMT_YUVA444P16BE._value
    ).inc()  # planar YUV 4:4:4 64bpp, (1 Cr & Cb sample per 1x1 Y & A samples, little-endian)

    comptime AV_PIX_FMT_VDPAU = Self(
        Self.AV_PIX_FMT_YUVA444P16LE._value
    ).inc()  # HW acceleration through VDPAU, Picture.data[3] contains a VdpVideoSurface

    comptime AV_PIX_FMT_XYZ12LE = Self(
        Self.AV_PIX_FMT_VDPAU._value
    ).inc()  # packed XYZ 4:4:4, 36 bpp, (msb) 12X, 12Y, 12Z (lsb), the 2-byte value for each X/Y/Z is stored as little-endian, the 4 lower bits are set to 0
    comptime AV_PIX_FMT_XYZ12BE = Self(
        Self.AV_PIX_FMT_XYZ12LE._value
    ).inc()  # packed XYZ 4:4:4, 36 bpp, (msb) 12X, 12Y, 12Z (lsb), the 2-byte value for each X/Y/Z is stored as big-endian, the 4 lower bits are set to 0
    comptime AV_PIX_FMT_NV16 = Self(
        Self.AV_PIX_FMT_XYZ12BE._value
    ).inc()  # interleaved chroma YUV 4:2:2, 16bpp, (1 Cr & Cb sample per 2x1 Y samples)
    comptime AV_PIX_FMT_NV20LE = Self(
        Self.AV_PIX_FMT_NV16._value
    ).inc()  # interleaved chroma YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    comptime AV_PIX_FMT_NV20BE = Self(
        Self.AV_PIX_FMT_NV20LE._value
    ).inc()  # interleaved chroma YUV 4:2:2, 20bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian

    comptime AV_PIX_FMT_RGBA64BE = Self(
        Self.AV_PIX_FMT_NV20BE._value
    ).inc()  # packed RGBA 16:16:16:16, 64bpp, 16R, 16G, 16B, 16A, the 2-byte value for each R/G/B/A component is stored as big-endian
    comptime AV_PIX_FMT_RGBA64LE = Self(
        Self.AV_PIX_FMT_RGBA64BE._value
    ).inc()  # packed RGBA 16:16:16:16, 64bpp, 16R, 16G, 16B, 16A, the 2-byte value for each R/G/B/A component is stored as little-endian
    comptime AV_PIX_FMT_BGRA64BE = Self(
        Self.AV_PIX_FMT_RGBA64LE._value
    ).inc()  # packed RGBA 16:16:16:16, 64bpp, 16B, 16G, 16R, 16A, the 2-byte value for each R/G/B/A component is stored as big-endian
    comptime AV_PIX_FMT_BGRA64LE = Self(
        Self.AV_PIX_FMT_BGRA64BE._value
    ).inc()  # packed RGBA 16:16:16:16, 64bpp, 16B, 16G, 16R, 16A, the 2-byte value for each R/G/B/A component is stored as little-endian

    comptime AV_PIX_FMT_YVYU422 = Self(
        Self.AV_PIX_FMT_BGRA64LE._value
    ).inc()  # packed YUV 4:2:2, 16bpp, Y0 Cr Y1 Cb

    comptime AV_PIX_FMT_YA16BE = Self(
        Self.AV_PIX_FMT_YVYU422._value
    ).inc()  # 16 bits gray, 16 bits alpha (big-endian)
    comptime AV_PIX_FMT_YA16LE = Self(
        Self.AV_PIX_FMT_YA16BE._value
    ).inc()  # 16 bits gray, 16 bits alpha (little-endian)

    comptime AV_PIX_FMT_GBRAP = Self(
        Self.AV_PIX_FMT_YA16LE._value
    ).inc()  # planar GBRA 4:4:4:4 32bpp
    comptime AV_PIX_FMT_GBRAP16BE = Self(
        Self.AV_PIX_FMT_GBRAP._value
    ).inc()  # planar GBRA 4:4:4:4 64bpp, big-endian
    comptime AV_PIX_FMT_GBRAP16LE = Self(
        Self.AV_PIX_FMT_GBRAP16BE._value
    ).inc()  # planar GBRA 4:4:4:4 64bpp, little-endian
    #
    # HW acceleration through QSV, data[3] contains a pointer to the
    # mfxFrameSurface1 structure.
    #
    # Before FFmpeg 5.0:
    # mfxFrameSurface1.Data.MemId contains a pointer when importing
    # the following frames as QSV frames:
    #
    # VAAPI:
    # mfxFrameSurface1.Data.MemId contains a pointer to VASurfaceID
    #
    # DXVA2:
    # mfxFrameSurface1.Data.MemId contains a pointer to IDirect3DSurface9
    #
    # FFmpeg 5.0 and above:
    # mfxFrameSurface1.Data.MemId contains a pointer to the mfxHDLPair
    # structure when importing the following frames as QSV frames:
    #
    # VAAPI:
    # mfxHDLPair.first contains a VASurfaceID pointer.
    # mfxHDLPair.second is always MFX_INFINITE.
    #
    # DXVA2:
    # mfxHDLPair.first contains IDirect3DSurface9 pointer.
    # mfxHDLPair.second is always MFX_INFINITE.
    #
    # D3D11:
    # mfxHDLPair.first contains a ID3D11Texture2D pointer.
    # mfxHDLPair.second contains the texture array index of the frame if the
    # ID3D11Texture2D is an array texture, or always MFX_INFINITE if it is a
    # normal texture.
    #
    comptime AV_PIX_FMT_QSV = Self(Self.AV_PIX_FMT_GBRAP16LE._value).inc()
    #
    # HW acceleration though MMAL, data[3] contains a pointer to the
    # MMAL_BUFFER_HEADER_T structure.
    #
    comptime AV_PIX_FMT_MMAL = Self(Self.AV_PIX_FMT_QSV._value).inc()

    comptime AV_PIX_FMT_D3D11VA_VLD = Self(
        Self.AV_PIX_FMT_MMAL._value
    ).inc()  # HW decoding through Direct3D11 via old API, Picture.data[3] contains a ID3D11VideoDecoderOutputView pointer

    #
    # HW acceleration through CUDA. data[i] contain CUdeviceptr pointers
    # exactly as for system memory frames.
    #
    comptime AV_PIX_FMT_CUDA = Self(Self.AV_PIX_FMT_D3D11VA_VLD._value).inc()

    comptime AV_PIX_FMT_0RGB = Self(
        Self.AV_PIX_FMT_CUDA._value
    ).inc()  # packed RGB 8:8:8, 32bpp, XRGBXRGB...   X=unused/undefined
    comptime AV_PIX_FMT_RGB0 = Self(
        Self.AV_PIX_FMT_0RGB._value
    ).inc()  # packed RGB 8:8:8, 32bpp, RGBXRGBX...   X=unused/undefined
    comptime AV_PIX_FMT_0BGR = Self(
        Self.AV_PIX_FMT_RGB0._value
    ).inc()  # packed BGR 8:8:8, 32bpp, XBGRXBGR...   X=unused/undefined
    comptime AV_PIX_FMT_BGR0 = Self(
        Self.AV_PIX_FMT_0BGR._value
    ).inc()  # packed BGR 8:8:8, 32bpp, BGRXBGRX...   X=unused/undefined

    comptime AV_PIX_FMT_YUV420P12BE = Self(
        Self.AV_PIX_FMT_BGR0._value
    ).inc()  # planar YUV 4:2:0,18bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
    comptime AV_PIX_FMT_YUV420P12LE = Self(
        Self.AV_PIX_FMT_YUV420P12BE._value
    ).inc()  # planar YUV 4:2:0,18bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
    comptime AV_PIX_FMT_YUV420P14BE = Self(
        Self.AV_PIX_FMT_YUV420P12LE._value
    ).inc()  # planar YUV 4:2:0,21bpp, (1 Cr & Cb sample per 2x2 Y samples), big-endian
    comptime AV_PIX_FMT_YUV420P14LE = Self(
        Self.AV_PIX_FMT_YUV420P14BE._value
    ).inc()  # planar YUV 4:2:0,21bpp, (1 Cr & Cb sample per 2x2 Y samples), little-endian
    comptime AV_PIX_FMT_YUV422P12BE = Self(
        Self.AV_PIX_FMT_YUV420P14LE._value
    ).inc()  # planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
    comptime AV_PIX_FMT_YUV422P12LE = Self(
        Self.AV_PIX_FMT_YUV422P12BE._value
    ).inc()  # planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    comptime AV_PIX_FMT_YUV422P14BE = Self(
        Self.AV_PIX_FMT_YUV422P12LE._value
    ).inc()  # planar YUV 4:2:2,28bpp, (1 Cr & Cb sample per 2x1 Y samples), big-endian
    comptime AV_PIX_FMT_YUV422P14LE = Self(
        Self.AV_PIX_FMT_YUV422P14BE._value
    ).inc()  # planar YUV 4:2:2,28bpp, (1 Cr & Cb sample per 2x1 Y samples), little-endian
    comptime AV_PIX_FMT_YUV444P12BE = Self(
        Self.AV_PIX_FMT_YUV422P14LE._value
    ).inc()  # planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
    comptime AV_PIX_FMT_YUV444P12LE = Self(
        Self.AV_PIX_FMT_YUV444P12BE._value
    ).inc()  # planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
    comptime AV_PIX_FMT_YUV444P14BE = Self(
        Self.AV_PIX_FMT_YUV444P12LE._value
    ).inc()  # planar YUV 4:4:4,42bpp, (1 Cr & Cb sample per 1x1 Y samples), big-endian
    comptime AV_PIX_FMT_YUV444P14LE = Self(
        Self.AV_PIX_FMT_YUV444P14BE._value
    ).inc()  # planar YUV 4:4:4,42bpp, (1 Cr & Cb sample per 1x1 Y samples), little-endian
    comptime AV_PIX_FMT_GBRP12BE = Self(
        Self.AV_PIX_FMT_YUV444P14LE._value
    ).inc()  # planar GBR 4:4:4 36bpp, big-endian
    comptime AV_PIX_FMT_GBRP12LE = Self(
        Self.AV_PIX_FMT_GBRP12BE._value
    ).inc()  # planar GBR 4:4:4 36bpp, little-endian
    comptime AV_PIX_FMT_GBRP14BE = Self(
        Self.AV_PIX_FMT_GBRP12LE._value
    ).inc()  # planar GBR 4:4:4 42bpp, big-endian
    comptime AV_PIX_FMT_GBRP14LE = Self(
        Self.AV_PIX_FMT_GBRP14BE._value
    ).inc()  # planar GBR 4:4:4 42bpp, little-endian
    comptime AV_PIX_FMT_YUVJ411P = Self(
        Self.AV_PIX_FMT_GBRP14LE._value
    ).inc()  # planar YUV 4:1:1, 12bpp, (1 Cr & Cb sample per 4x1 Y samples) full scale (JPEG), deprecated in favor of AV_PIX_FMT_YUV411P and setting color_range

    comptime AV_PIX_FMT_BAYER_BGGR8 = Self(
        Self.AV_PIX_FMT_YUVJ411P._value
    ).inc()  # bayer, BGBG..(odd line), GRGR..(even line), 8-bit samples
    comptime AV_PIX_FMT_BAYER_RGGB8 = Self(
        Self.AV_PIX_FMT_BAYER_BGGR8._value
    ).inc()  # bayer, RGRG..(odd line), GBGB..(even line), 8-bit samples
    comptime AV_PIX_FMT_BAYER_GBRG8 = Self(
        Self.AV_PIX_FMT_BAYER_RGGB8._value
    ).inc()  # bayer, GBGB..(odd line), RGRG..(even line), 8-bit samples
    comptime AV_PIX_FMT_BAYER_GRBG8 = Self(
        Self.AV_PIX_FMT_BAYER_GBRG8._value
    ).inc()  # bayer, GRGR..(odd line), BGBG..(even line), 8-bit samples
    comptime AV_PIX_FMT_BAYER_BGGR16LE = Self(
        Self.AV_PIX_FMT_BAYER_GRBG8._value
    ).inc()  # bayer, BGBG..(odd line), GRGR..(even line), 16-bit samples, little-endian
    comptime AV_PIX_FMT_BAYER_BGGR16BE = Self(
        Self.AV_PIX_FMT_BAYER_BGGR16LE._value
    ).inc()  # bayer, BGBG..(odd line), GRGR..(even line), 16-bit samples, big-endian
    comptime AV_PIX_FMT_BAYER_RGGB16LE = Self(
        Self.AV_PIX_FMT_BAYER_BGGR16BE._value
    ).inc()  # bayer, RGRG..(odd line), GBGB..(even line), 16-bit samples, little-endian
    comptime AV_PIX_FMT_BAYER_RGGB16BE = Self(
        Self.AV_PIX_FMT_BAYER_RGGB16LE._value
    ).inc()  # bayer, RGRG..(odd line), GBGB..(even line), 16-bit samples, big-endian
    comptime AV_PIX_FMT_BAYER_GBRG16LE = Self(
        Self.AV_PIX_FMT_BAYER_RGGB16BE._value
    ).inc()  # bayer, GBGB..(odd line), RGRG..(even line), 16-bit samples, little-endian
    comptime AV_PIX_FMT_BAYER_GBRG16BE = Self(
        Self.AV_PIX_FMT_BAYER_GBRG16LE._value
    ).inc()  # bayer, GBGB..(odd line), RGRG..(even line), 16-bit samples, big-endian
    comptime AV_PIX_FMT_BAYER_GRBG16LE = Self(
        Self.AV_PIX_FMT_BAYER_GBRG16BE._value
    ).inc()  # bayer, GRGR..(odd line), BGBG..(even line), 16-bit samples, little-endian
    comptime AV_PIX_FMT_BAYER_GRBG16BE = Self(
        Self.AV_PIX_FMT_BAYER_GRBG16LE._value
    ).inc()  # bayer, GRGR..(odd line), BGBG..(even line), 16-bit samples, big-endian

    comptime AV_PIX_FMT_YUV440P10LE = Self(
        Self.AV_PIX_FMT_BAYER_GRBG16BE._value
    ).inc()  # planar YUV 4:4:0,20bpp, (1 Cr & Cb sample per 1x2 Y samples), little-endian
    comptime AV_PIX_FMT_YUV440P10BE = Self(
        Self.AV_PIX_FMT_YUV440P10LE._value
    ).inc()  # planar YUV 4:4:0,20bpp, (1 Cr & Cb sample per 1x2 Y samples), big-endian
    comptime AV_PIX_FMT_YUV440P12LE = Self(
        Self.AV_PIX_FMT_YUV440P10BE._value
    ).inc()  # planar YUV 4:4:0,24bpp, (1 Cr & Cb sample per 1x2 Y samples), little-endian
    comptime AV_PIX_FMT_YUV440P12BE = Self(
        Self.AV_PIX_FMT_YUV440P12LE._value
    ).inc()  # planar YUV 4:4:0,24bpp, (1 Cr & Cb sample per 1x2 Y samples), big-endian
    comptime AV_PIX_FMT_AYUV64LE = Self(
        Self.AV_PIX_FMT_YUV440P12BE._value
    ).inc()  # packed AYUV 4:4:4,64bpp (1 Cr & Cb sample per 1x1 Y & A samples), little-endian
    comptime AV_PIX_FMT_AYUV64BE = Self(
        Self.AV_PIX_FMT_AYUV64LE._value
    ).inc()  # packed AYUV 4:4:4,64bpp (1 Cr & Cb sample per 1x1 Y & A samples), big-endian

    comptime AV_PIX_FMT_VIDEOTOOLBOX = Self(
        Self.AV_PIX_FMT_AYUV64BE._value
    ).inc()  # hardware decoding through Videotoolbox

    comptime AV_PIX_FMT_P010LE = Self(
        Self.AV_PIX_FMT_VIDEOTOOLBOX._value
    ).inc()  # like NV12, with 10bpp per component, data in the high bits, zeros in the low bits, little-endian
    comptime AV_PIX_FMT_P010BE = Self(
        Self.AV_PIX_FMT_P010LE._value
    ).inc()  # like NV12, with 10bpp per component, data in the high bits, zeros in the low bits, big-endian

    comptime AV_PIX_FMT_GBRAP12BE = Self(
        Self.AV_PIX_FMT_P010BE._value
    ).inc()  # planar GBR 4:4:4:4 48bpp, big-endian
    comptime AV_PIX_FMT_GBRAP12LE = Self(
        Self.AV_PIX_FMT_GBRAP12BE._value
    ).inc()  # planar GBR 4:4:4:4 48bpp, little-endian

    comptime AV_PIX_FMT_GBRAP10BE = Self(
        Self.AV_PIX_FMT_GBRAP12LE._value
    ).inc()  # planar GBR 4:4:4:4 40bpp, big-endian
    comptime AV_PIX_FMT_GBRAP10LE = Self(
        Self.AV_PIX_FMT_GBRAP10BE._value
    ).inc()  # planar GBR 4:4:4:4 40bpp, little-endian

    comptime AV_PIX_FMT_MEDIACODEC = Self(
        Self.AV_PIX_FMT_GBRAP10LE._value
    ).inc()  # hardware decoding through MediaCodec

    comptime AV_PIX_FMT_GRAY12BE = Self(
        Self.AV_PIX_FMT_MEDIACODEC._value
    ).inc()  #        Y        , 12bpp, big-endian
    comptime AV_PIX_FMT_GRAY12LE = Self(
        Self.AV_PIX_FMT_GRAY12BE._value
    ).inc()  #        Y        , 12bpp, little-endian
    comptime AV_PIX_FMT_GRAY10BE = Self(
        Self.AV_PIX_FMT_GRAY12LE._value
    ).inc()  #        Y        , 10bpp, big-endian
    comptime AV_PIX_FMT_GRAY10LE = Self(
        Self.AV_PIX_FMT_GRAY10BE._value
    ).inc()  #        Y        , 10bpp, little-endian

    comptime AV_PIX_FMT_P016LE = Self(
        Self.AV_PIX_FMT_GRAY10LE._value
    ).inc()  # like NV12, with 16bpp per component, little-endian
    comptime AV_PIX_FMT_P016BE = Self(
        Self.AV_PIX_FMT_P016LE._value
    ).inc()  # like NV12, with 16bpp per component, big-endian

    #
    # Hardware surfaces for Direct3D11.
    #
    # This is preferred over the legacy AV_PIX_FMT_D3D11VA_VLD. The new D3D11
    # hwaccel API and filtering support AV_PIX_FMT_D3D11 only.
    #
    # data[0] contains a ID3D11Texture2D pointer, and data[1] contains the
    # texture array index of the frame as intptr_t if the ID3D11Texture2D is
    # an array texture (or always 0 if it's a normal texture).
    #
    comptime AV_PIX_FMT_D3D11 = Self(Self.AV_PIX_FMT_P016BE._value).inc()

    comptime AV_PIX_FMT_GRAY9BE = Self(
        Self.AV_PIX_FMT_D3D11._value
    ).inc()  #        Y        , 9bpp, big-endian
    comptime AV_PIX_FMT_GRAY9LE = Self(
        Self.AV_PIX_FMT_GRAY9BE._value
    ).inc()  #        Y        , 9bpp, little-endian

    comptime AV_PIX_FMT_GBRPF32BE = Self(
        Self.AV_PIX_FMT_GRAY9LE._value
    ).inc()  # IEEE-754 single precision planar GBR 4:4:4,     96bpp, big-endian
    comptime AV_PIX_FMT_GBRPF32LE = Self(
        Self.AV_PIX_FMT_GBRPF32BE._value
    ).inc()  # IEEE-754 single precision planar GBR 4:4:4,     96bpp, little-endian
    comptime AV_PIX_FMT_GBRAPF32BE = Self(
        Self.AV_PIX_FMT_GBRPF32LE._value
    ).inc()  # IEEE-754 single precision planar GBRA 4:4:4:4, 128bpp, big-endian
    comptime AV_PIX_FMT_GBRAPF32LE = Self(
        Self.AV_PIX_FMT_GBRAPF32BE._value
    ).inc()  # IEEE-754 single precision planar GBRA 4:4:4:4, 128bpp, little-endian

    #
    # DRM-managed buffers exposed through PRIME buffer sharing.
    #
    # data[0] points to an AVDRMFrameDescriptor.
    #
    comptime AV_PIX_FMT_DRM_PRIME = Self(
        Self.AV_PIX_FMT_GBRAPF32LE._value
    ).inc()
    #
    # Hardware surfaces for OpenCL.
    #
    # data[i] contain 2D image objects (typed in C as cl_mem, used
    # in OpenCL as image2d_t) for each plane of the surface.
    #
    comptime AV_PIX_FMT_OPENCL = Self(Self.AV_PIX_FMT_DRM_PRIME._value).inc()

    comptime AV_PIX_FMT_GRAY14BE = Self(
        Self.AV_PIX_FMT_OPENCL._value
    ).inc()  #        Y        , 14bpp, big-endian
    comptime AV_PIX_FMT_GRAY14LE = Self(
        Self.AV_PIX_FMT_GRAY14BE._value
    ).inc()  #        Y        , 14bpp, little-endian

    comptime AV_PIX_FMT_GRAYF32BE = Self(
        Self.AV_PIX_FMT_GRAY14LE._value
    ).inc()  # IEEE-754 single precision Y, 32bpp, big-endian
    comptime AV_PIX_FMT_GRAYF32LE = Self(
        Self.AV_PIX_FMT_GRAYF32BE._value
    ).inc()  # IEEE-754 single precision Y, 32bpp, little-endian

    comptime AV_PIX_FMT_YUVA422P12BE = Self(
        Self.AV_PIX_FMT_GRAYF32LE._value
    ).inc()  # planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), 12b alpha, big-endian
    comptime AV_PIX_FMT_YUVA422P12LE = Self(
        Self.AV_PIX_FMT_YUVA422P12BE._value
    ).inc()  # planar YUV 4:2:2,24bpp, (1 Cr & Cb sample per 2x1 Y samples), 12b alpha, little-endian
    comptime AV_PIX_FMT_YUVA444P12BE = Self(
        Self.AV_PIX_FMT_YUVA422P12LE._value
    ).inc()  # planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), 12b alpha, big-endian
    comptime AV_PIX_FMT_YUVA444P12LE = Self(
        Self.AV_PIX_FMT_YUVA444P12BE._value
    ).inc()  # planar YUV 4:4:4,36bpp, (1 Cr & Cb sample per 1x1 Y samples), 12b alpha, little-endian

    comptime AV_PIX_FMT_NV24 = Self(
        Self.AV_PIX_FMT_YUVA444P12LE._value
    ).inc()  # planar YUV 4:4:4, 24bpp, 1 plane for Y and 1 plane for the UV components, which are interleaved (first byte U and the following byte V)
    comptime AV_PIX_FMT_NV42 = Self(
        Self.AV_PIX_FMT_NV24._value
    ).inc()  # as above, but U and V bytes are swapped

    #
    # Vulkan hardware images.
    #
    # data[0] points to an AVVkFrame
    #
    comptime AV_PIX_FMT_VULKAN = Self(Self.AV_PIX_FMT_NV42._value).inc()

    comptime AV_PIX_FMT_Y210BE = Self(
        Self.AV_PIX_FMT_VULKAN._value
    ).inc()  # packed YUV 4:2:2 like YUYV422, 20bpp, data in the high bits, big-endian
    comptime AV_PIX_FMT_Y210LE = Self(
        Self.AV_PIX_FMT_Y210BE._value
    ).inc()  # packed YUV 4:2:2 like YUYV422, 20bpp, data in the high bits, little-endian

    comptime AV_PIX_FMT_X2RGB10LE = Self(
        Self.AV_PIX_FMT_Y210LE._value
    ).inc()  # packed RGB 10:10:10, 30bpp, (msb)2X 10R 10G 10B(lsb), little-endian, X=unused/undefined
    comptime AV_PIX_FMT_X2RGB10BE = Self(
        Self.AV_PIX_FMT_X2RGB10LE._value
    ).inc()  # packed RGB 10:10:10, 30bpp, (msb)2X 10R 10G 10B(lsb), big-endian, X=unused/undefined
    comptime AV_PIX_FMT_X2BGR10LE = Self(
        Self.AV_PIX_FMT_X2RGB10BE._value
    ).inc()  # packed BGR 10:10:10, 30bpp, (msb)2X 10B 10G 10R(lsb), little-endian, X=unused/undefined
    comptime AV_PIX_FMT_X2BGR10BE = Self(
        Self.AV_PIX_FMT_X2BGR10LE._value
    ).inc()  # packed BGR 10:10:10, 30bpp, (msb)2X 10B 10G 10R(lsb), big-endian, X=unused/undefined

    comptime AV_PIX_FMT_P210BE = Self(
        Self.AV_PIX_FMT_X2BGR10BE._value
    ).inc()  # interleaved chroma YUV 4:2:2, 20bpp, data in the high bits, big-endian
    comptime AV_PIX_FMT_P210LE = Self(
        Self.AV_PIX_FMT_P210BE._value
    ).inc()  # interleaved chroma YUV 4:2:2, 20bpp, data in the high bits, little-endian

    comptime AV_PIX_FMT_P410BE = Self(
        Self.AV_PIX_FMT_P210LE._value
    ).inc()  # interleaved chroma YUV 4:4:4, 30bpp, data in the high bits, big-endian
    comptime AV_PIX_FMT_P410LE = Self(
        Self.AV_PIX_FMT_P410BE._value
    ).inc()  # interleaved chroma YUV 4:4:4, 30bpp, data in the high bits, little-endian

    comptime AV_PIX_FMT_P216BE = Self(
        Self.AV_PIX_FMT_P410LE._value
    ).inc()  # interleaved chroma YUV 4:2:2, 32bpp, big-endian
    comptime AV_PIX_FMT_P216LE = Self(
        Self.AV_PIX_FMT_P216BE._value
    ).inc()  # interleaved chroma YUV 4:2:2, 32bpp, little-endian

    comptime AV_PIX_FMT_P416BE = Self(
        Self.AV_PIX_FMT_P216LE._value
    ).inc()  # interleaved chroma YUV 4:4:4, 48bpp, big-endian
    comptime AV_PIX_FMT_P416LE = Self(
        Self.AV_PIX_FMT_P416BE._value
    ).inc()  # interleaved chroma YUV 4:4:4, 48bpp, little-endian

    comptime AV_PIX_FMT_VUYA = Self(
        Self.AV_PIX_FMT_P416LE._value
    ).inc()  # packed VUYA 4:4:4:4, 32bpp (1 Cr & Cb sample per 1x1 Y & A samples), VUYAVUYA...

    comptime AV_PIX_FMT_RGBAF16BE = Self(
        Self.AV_PIX_FMT_VUYA._value
    ).inc()  # IEEE-754 half precision packed RGBA 16:16:16:16, 64bpp, RGBARGBA..., big-endian
    comptime AV_PIX_FMT_RGBAF16LE = Self(
        Self.AV_PIX_FMT_RGBAF16BE._value
    ).inc()  # IEEE-754 half precision packed RGBA 16:16:16:16, 64bpp, RGBARGBA..., little-endian

    comptime AV_PIX_FMT_VUYX = Self(
        Self.AV_PIX_FMT_RGBAF16LE._value
    ).inc()  # packed VUYX 4:4:4:4, 32bpp, Variant of VUYA where alpha channel is left undefined

    comptime AV_PIX_FMT_P012LE = Self(
        Self.AV_PIX_FMT_VUYX._value
    ).inc()  # like NV12, with 12bpp per component, data in the high bits, zeros in the low bits, little-endian
    comptime AV_PIX_FMT_P012BE = Self(
        Self.AV_PIX_FMT_P012LE._value
    ).inc()  # like NV12, with 12bpp per component, data in the high bits, zeros in the low bits, big-endian

    comptime AV_PIX_FMT_Y212BE = Self(
        Self.AV_PIX_FMT_P012BE._value
    ).inc()  # packed YUV 4:2:2 like YUYV422, 24bpp, data in the high bits, zeros in the low bits, big-endian
    comptime AV_PIX_FMT_Y212LE = Self(
        Self.AV_PIX_FMT_Y212BE._value
    ).inc()  # packed YUV 4:2:2 like YUYV422, 24bpp, data in the high bits, zeros in the low bits, little-endian

    comptime AV_PIX_FMT_XV30BE = Self(
        Self.AV_PIX_FMT_Y212LE._value
    ).inc()  # packed XVYU 4:4:4, 32bpp, (msb)2X 10V 10Y 10U(lsb), big-endian, variant of Y410 where alpha channel is left undefined
    comptime AV_PIX_FMT_XV30LE = Self(
        Self.AV_PIX_FMT_XV30BE._value
    ).inc()  # packed XVYU 4:4:4, 32bpp, (msb)2X 10V 10Y 10U(lsb), little-endian, variant of Y410 where alpha channel is left undefined

    comptime AV_PIX_FMT_XV36BE = Self(
        Self.AV_PIX_FMT_XV30LE._value
    ).inc()  # packed XVYU 4:4:4, 48bpp, data in the high bits, zeros in the low bits, big-endian, variant of Y412 where alpha channel is left undefined
    comptime AV_PIX_FMT_XV36LE = Self(
        Self.AV_PIX_FMT_XV36BE._value
    ).inc()  # packed XVYU 4:4:4, 48bpp, data in the high bits, zeros in the low bits, little-endian, variant of Y412 where alpha channel is left undefined

    comptime AV_PIX_FMT_RGBF32BE = Self(
        Self.AV_PIX_FMT_XV36LE._value
    ).inc()  # IEEE-754 single precision packed RGB 32:32:32, 96bpp, RGBRGB..., big-endian
    comptime AV_PIX_FMT_RGBF32LE = Self(
        Self.AV_PIX_FMT_RGBF32BE._value
    ).inc()  # IEEE-754 single precision packed RGB 32:32:32, 96bpp, RGBRGB..., little-endian

    comptime AV_PIX_FMT_RGBAF32BE = Self(
        Self.AV_PIX_FMT_RGBF32LE._value
    ).inc()  # IEEE-754 single precision packed RGBA 32:32:32:32, 128bpp, RGBARGBA..., big-endian
    comptime AV_PIX_FMT_RGBAF32LE = Self(
        Self.AV_PIX_FMT_RGBAF32BE._value
    ).inc()  # IEEE-754 single precision packed RGBA 32:32:32:32, 128bpp, RGBARGBA..., little-endian

    comptime AV_PIX_FMT_P212BE = Self(
        Self.AV_PIX_FMT_RGBAF32LE._value
    ).inc()  # interleaved chroma YUV 4:2:2, 24bpp, data in the high bits, big-endian
    comptime AV_PIX_FMT_P212LE = Self(
        Self.AV_PIX_FMT_P212BE._value
    ).inc()  # interleaved chroma YUV 4:2:2, 24bpp, data in the high bits, little-endian

    comptime AV_PIX_FMT_P412BE = Self(
        Self.AV_PIX_FMT_P212LE._value
    ).inc()  # interleaved chroma YUV 4:4:4, 36bpp, data in the high bits, big-endian
    comptime AV_PIX_FMT_P412LE = Self(
        Self.AV_PIX_FMT_P412BE._value
    ).inc()  # interleaved chroma YUV 4:4:4, 36bpp, data in the high bits, little-endian

    comptime AV_PIX_FMT_GBRAP14BE = Self(
        Self.AV_PIX_FMT_P412LE._value
    ).inc()  # planar GBR 4:4:4:4 56bpp, big-endian
    comptime AV_PIX_FMT_GBRAP14LE = Self(
        Self.AV_PIX_FMT_GBRAP14BE._value
    ).inc()  # planar GBR 4:4:4:4 56bpp, little-endian

    #
    # Hardware surfaces for Direct3D 12.
    #
    # data[0] points to an AVD3D12VAFrame
    #
    comptime AV_PIX_FMT_D3D12 = Self(Self.AV_PIX_FMT_GBRAP14LE._value).inc()

    comptime AV_PIX_FMT_AYUV = Self(
        Self.AV_PIX_FMT_D3D12._value
    ).inc()  # packed AYUV 4:4:4:4, 32bpp (1 Cr & Cb sample per 1x1 Y & A samples), AYUVAYUV...

    comptime AV_PIX_FMT_UYVA = Self(
        Self.AV_PIX_FMT_AYUV._value
    ).inc()  # packed UYVA 4:4:4:4, 32bpp (1 Cr & Cb sample per 1x1 Y & A samples), UYVAUYVA...

    comptime AV_PIX_FMT_VYU444 = Self(
        Self.AV_PIX_FMT_UYVA._value
    ).inc()  # packed VYU 4:4:4, 24bpp (1 Cr & Cb sample per 1x1 Y), VYUVYU...

    comptime AV_PIX_FMT_V30XBE = Self(
        Self.AV_PIX_FMT_VYU444._value
    ).inc()  # packed VYUX 4:4:4 like XV30, 32bpp, (msb)10V 10Y 10U 2X(lsb), big-endian
    comptime AV_PIX_FMT_V30XLE = Self(
        Self.AV_PIX_FMT_V30XBE._value
    ).inc()  # packed VYUX 4:4:4 like XV30, 32bpp, (msb)10V 10Y 10U 2X(lsb), little-endian

    comptime AV_PIX_FMT_RGBF16BE = Self(
        Self.AV_PIX_FMT_V30XLE._value
    ).inc()  # IEEE-754 half precision packed RGB 16:16:16, 48bpp, RGBRGB..., big-endian
    comptime AV_PIX_FMT_RGBF16LE = Self(
        Self.AV_PIX_FMT_RGBF16BE._value
    ).inc()  # IEEE-754 half precision packed RGB 16:16:16, 48bpp, RGBRGB..., little-endian

    comptime AV_PIX_FMT_RGBA128BE = Self(
        Self.AV_PIX_FMT_RGBF16LE._value
    ).inc()  # packed RGBA 32:32:32:32, 128bpp, RGBARGBA..., big-endian
    comptime AV_PIX_FMT_RGBA128LE = Self(
        Self.AV_PIX_FMT_RGBA128BE._value
    ).inc()  # packed RGBA 32:32:32:32, 128bpp, RGBARGBA..., little-endian

    comptime AV_PIX_FMT_RGB96BE = Self(
        Self.AV_PIX_FMT_RGBA128LE._value
    ).inc()  # packed RGBA 32:32:32, 96bpp, RGBRGB..., big-endian
    comptime AV_PIX_FMT_RGB96LE = Self(
        Self.AV_PIX_FMT_RGB96BE._value
    ).inc()  # packed RGBA 32:32:32, 96bpp, RGBRGB..., little-endian

    comptime AV_PIX_FMT_Y216BE = Self(
        Self.AV_PIX_FMT_RGB96LE._value
    ).inc()  # packed YUV 4:2:2 like YUYV422, 32bpp, big-endian
    comptime AV_PIX_FMT_Y216LE = Self(
        Self.AV_PIX_FMT_Y216BE._value
    ).inc()  # packed YUV 4:2:2 like YUYV422, 32bpp, little-endian

    comptime AV_PIX_FMT_XV48BE = Self(
        Self.AV_PIX_FMT_Y216LE._value
    ).inc()  # packed XVYU 4:4:4, 64bpp, big-endian, variant of Y416 where alpha channel is left undefined
    comptime AV_PIX_FMT_XV48LE = Self(
        Self.AV_PIX_FMT_XV48BE._value
    ).inc()  # packed XVYU 4:4:4, 64bpp, little-endian, variant of Y416 where alpha channel is left undefined

    comptime AV_PIX_FMT_GBRPF16BE = Self(
        Self.AV_PIX_FMT_XV48LE._value
    ).inc()  # IEEE-754 half precision planer GBR 4:4:4, 48bpp, big-endian
    comptime AV_PIX_FMT_GBRPF16LE = Self(
        Self.AV_PIX_FMT_GBRPF16BE._value
    ).inc()  # IEEE-754 half precision planer GBR 4:4:4, 48bpp, little-endian
    comptime AV_PIX_FMT_GBRAPF16BE = Self(
        Self.AV_PIX_FMT_GBRPF16LE._value
    ).inc()  # IEEE-754 half precision planar GBRA 4:4:4:4, 64bpp, big-endian
    comptime AV_PIX_FMT_GBRAPF16LE = Self(
        Self.AV_PIX_FMT_GBRAPF16BE._value
    ).inc()  # IEEE-754 half precision planar GBRA 4:4:4:4, 64bpp, little-endian

    comptime AV_PIX_FMT_GRAYF16BE = Self(
        Self.AV_PIX_FMT_GBRAPF16LE._value
    ).inc()  # IEEE-754 half precision Y, 16bpp, big-endian
    comptime AV_PIX_FMT_GRAYF16LE = Self(
        Self.AV_PIX_FMT_GRAYF16BE._value
    ).inc()  # IEEE-754 half precision Y, 16bpp, little-endian

    #
    # HW acceleration through AMF. data[0] contain AMFSurface pointer
    #
    comptime AV_PIX_FMT_AMF_SURFACE = Self(
        Self.AV_PIX_FMT_GRAYF16LE._value
    ).inc()

    comptime AV_PIX_FMT_GRAY32BE = Self(
        Self.AV_PIX_FMT_AMF_SURFACE._value
    ).inc()  #         Y        , 32bpp, big-endian
    comptime AV_PIX_FMT_GRAY32LE = Self(
        Self.AV_PIX_FMT_GRAY32BE._value
    ).inc()  #         Y        , 32bpp, little-endian
    comptime AV_PIX_FMT_YAF32BE = Self(
        Self.AV_PIX_FMT_GRAY32LE._value
    ).inc()  # IEEE-754 single precision packed YA, 32 bits gray, 32 bits alpha, 64bpp, big-endian
    comptime AV_PIX_FMT_YAF32LE = Self(
        Self.AV_PIX_FMT_YAF32BE._value
    ).inc()  # IEEE-754 single precision packed YA, 32 bits gray, 32 bits alpha, 64bpp, little-endian

    comptime AV_PIX_FMT_YAF16BE = Self(
        Self.AV_PIX_FMT_YAF32LE._value
    ).inc()  # IEEE-754 half precision packed YA, 16 bits gray, 16 bits alpha, 32bpp, big-endian
    comptime AV_PIX_FMT_YAF16LE = Self(
        Self.AV_PIX_FMT_YAF16BE._value
    ).inc()  # IEEE-754 half precision packed YA, 16 bits gray, 16 bits alpha, 32bpp, little-endian

    comptime AV_PIX_FMT_GBRAP32BE = Self(
        Self.AV_PIX_FMT_YAF16LE._value
    ).inc()  # planar GBRA 4:4:4:4 128bpp, big-endian
    comptime AV_PIX_FMT_GBRAP32LE = Self(
        Self.AV_PIX_FMT_GBRAP32BE._value
    ).inc()  # planar GBRA 4:4:4:4 128bpp, little-endian

    comptime AV_PIX_FMT_YUV444P10MSBBE = Self(
        Self.AV_PIX_FMT_GBRAP32LE._value
    ).inc()  # planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), lowest bits zero, big-endian
    comptime AV_PIX_FMT_YUV444P10MSBLE = Self(
        Self.AV_PIX_FMT_YUV444P10MSBBE._value
    ).inc()  # planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), lowest bits zero, little-endian
    comptime AV_PIX_FMT_YUV444P12MSBBE = Self(
        Self.AV_PIX_FMT_YUV444P10MSBLE._value
    ).inc()  # planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), lowest bits zero, big-endian
    comptime AV_PIX_FMT_YUV444P12MSBLE = Self(
        Self.AV_PIX_FMT_YUV444P12MSBBE._value
    ).inc()  # planar YUV 4:4:4, 30bpp, (1 Cr & Cb sample per 1x1 Y samples), lowest bits zero, little-endian
    comptime AV_PIX_FMT_GBRP10MSBBE = Self(
        Self.AV_PIX_FMT_YUV444P12MSBLE._value
    ).inc()  # planar GBR 4:4:4 30bpp, lowest bits zero, big-endian
    comptime AV_PIX_FMT_GBRP10MSBLE = Self(
        Self.AV_PIX_FMT_GBRP10MSBBE._value
    ).inc()  # planar GBR 4:4:4 30bpp, lowest bits zero, little-endian
    comptime AV_PIX_FMT_GBRP12MSBBE = Self(
        Self.AV_PIX_FMT_GBRP10MSBLE._value
    ).inc()  # planar GBR 4:4:4 36bpp, lowest bits zero, big-endian
    comptime AV_PIX_FMT_GBRP12MSBLE = Self(
        Self.AV_PIX_FMT_GBRP12MSBBE._value
    ).inc()  # planar GBR 4:4:4 36bpp, lowest bits zero, little-endian

    comptime AV_PIX_FMT_OHCODEC = Self(
        Self.AV_PIX_FMT_GBRP12MSBLE._value
    ).inc()  # hardware decoding through openharmony

    comptime AV_PIX_FMT_NB = Self(
        Self.AV_PIX_FMT_OHCODEC._value
    ).inc()  # number of pixel formats, DO NOT USE THIS if you want to link with shared libav* because the number of formats might differ between versionswe


@fieldwise_init
struct AVColorRange(Movable, Writable):
    comptime ENUM_DTYPE = c_int

    var _value: Self.ENUM_DTYPE

    fn inc(self) -> Self:
        return Self(self._value + 1)

    comptime AVCOL_RANGE_UNSPECIFIED = Self(0)

    comptime AVCOL_RANGE_MPEG = Self(1)

    comptime AVCOL_RANGE_JPEG = Self(2)

    comptime AVCOL_RANGE_NB = Self(3)


@fieldwise_init("implicit")
struct AVColorPrimaries(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var _value: Self.ENUM_DTYPE

    comptime AVCOL_PRI_RESERVED0 = Self(0)
    comptime AVCOL_PRI_BT709 = Self(1)
    comptime AVCOL_PRI_UNSPECIFIED = Self(2)
    comptime AVCOL_PRI_RESERVED = Self(3)
    comptime AVCOL_PRI_BT470M = Self(4)

    comptime AVCOL_PRI_BT470BG = Self(5)
    comptime AVCOL_PRI_SMPTE170M = Self(6)
    comptime AVCOL_PRI_SMPTE240M = Self(7)
    comptime AVCOL_PRI_FILM = Self(8)
    comptime AVCOL_PRI_BT2020 = Self(9)
    comptime AVCOL_PRI_SMPTE428 = Self(10)
    comptime AVCOL_PRI_SMPTEST428_1 = Self.AVCOL_PRI_SMPTE428
    comptime AVCOL_PRI_SMPTE431 = Self(11)
    comptime AVCOL_PRI_SMPTE432 = Self(12)
    comptime AVCOL_PRI_EBU3213 = Self(22)
    comptime AVCOL_PRI_JEDEC_P22 = Self(Self.AVCOL_PRI_EBU3213._value)
    comptime AVCOL_PRI_NB = Self(Self.AVCOL_PRI_JEDEC_P22._value + 1)


@fieldwise_init("implicit")
struct AVColorTransferCharacteristic(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var _value: Self.ENUM_DTYPE

    comptime AVCOL_TRC_RESERVED0 = Self(0)
    comptime AVCOL_TRC_BT709 = Self(1)
    comptime AVCOL_TRC_UNSPECIFIED = Self(2)
    comptime AVCOL_TRC_RESERVED = Self(3)
    comptime AVCOL_TRC_GAMMA22 = Self(4)
    comptime AVCOL_TRC_GAMMA28 = Self(5)
    comptime AVCOL_TRC_SMPTE170M = Self(6)
    comptime AVCOL_TRC_SMPTE240M = Self(7)
    comptime AVCOL_TRC_LINEAR = Self(8)
    comptime AVCOL_TRC_LOG = Self(9)
    comptime AVCOL_TRC_LOG_SQRT = Self(10)
    comptime AVCOL_TRC_IEC61966_2_4 = Self(11)
    comptime AVCOL_TRC_BT1361_ECG = Self(12)
    comptime AVCOL_TRC_IEC61966_2_1 = Self(13)
    comptime AVCOL_TRC_BT2020_10 = Self(14)
    comptime AVCOL_TRC_BT2020_12 = Self(15)
    comptime AVCOL_TRC_SMPTE2084 = Self(16)
    comptime AVCOL_TRC_SMPTEST2084 = Self(Self.AVCOL_TRC_SMPTE2084._value)
    comptime AVCOL_TRC_SMPTE428 = Self(17)
    comptime AVCOL_TRC_SMPTEST428_1 = Self(Self.AVCOL_TRC_SMPTE428._value)
    comptime AVCOL_TRC_ARIB_STD_B67 = Self(18)
    comptime AVCOL_TRC_NB = Self(Self.AVCOL_TRC_ARIB_STD_B67._value + 1)


@fieldwise_init("implicit")
struct AVColorSpace(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var _value: Self.ENUM_DTYPE

    comptime AVCOL_SPC_RGB = Self(0)
    comptime AVCOL_SPC_BT709 = Self(1)
    comptime AVCOL_SPC_UNSPECIFIED = Self(2)

    comptime AVCOL_SPC_RESERVED = Self(3)
    comptime AVCOL_SPC_FCC = Self(4)
    comptime AVCOL_SPC_BT470BG = Self(5)
    comptime AVCOL_SPC_SMPTE170M = Self(6)
    comptime AVCOL_SPC_SMPTE240M = Self(7)
    comptime AVCOL_SPC_YCGCO = Self(8)
    comptime AVCOL_SPC_YCOCG = Self(Self.AVCOL_SPC_YCGCO._value)

    comptime AVCOL_SPC_BT2020_NCL = Self(9)
    comptime AVCOL_SPC_BT2020_CL = Self(10)
    comptime AVCOL_SPC_SMPTE2085 = Self(11)
    comptime AVCOL_SPC_CHROMA_DERIVED_NCL = Self(12)
    comptime AVCOL_SPC_CHROMA_DERIVED_CL = Self(13)
    comptime AVCOL_SPC_ICTCP = Self(14)
    comptime AVCOL_SPC_IPT_C2 = Self(15)
    comptime AVCOL_SPC_YCGCO_RE = Self(16)
    comptime AVCOL_SPC_YCGCO_RO = Self(17)
    comptime AVCOL_SPC_NB = Self(Self.AVCOL_SPC_YCGCO_RO._value + 1)


@fieldwise_init("implicit")
struct AVChromaLocation(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var _value: Self.ENUM_DTYPE

    comptime AVCHROMA_LOC_UNSPECIFIED = Self(0)
    comptime AVCHROMA_LOC_LEFT = Self(1)
    comptime AVCHROMA_LOC_CENTER = Self(2)
    comptime AVCHROMA_LOC_TOPLEFT = Self(3)
    comptime AVCHROMA_LOC_TOP = Self(4)
    comptime AVCHROMA_LOC_BOTTOMLEFT = Self(5)
    comptime AVCHROMA_LOC_BOTTOM = Self(6)
    comptime AVCHROMA_LOC_NB = Self(Self.AVCHROMA_LOC_BOTTOM._value + 1)
