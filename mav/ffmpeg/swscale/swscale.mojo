"See https://www.ffmpeg.org/doxygen/8.0/swscale_8h.html."
from std.ffi import (
    c_int,
    c_char,
    c_uchar,
    c_long_long,
    c_uint,
    c_size_t,
    c_double,
    c_float,
    external_call,
)
from std.sys._libc import dup, fclose, fdopen, fflush, FILE_ptr
from std.utils import StaticTuple
from mav._clib import C_Union
from mav.ffmpeg.avutil.frame import AVFrame
from mav.ffmpeg.avcodec.codec import AVCodec
from mav.ffmpeg.avcodec.codec_id import AVCodecID
from mav.ffmpeg.avcodec.packet import AVPacket, AVPacketSideData
from mav.ffmpeg.avcodec.codec_par import AVCodecParameters
from mav.ffmpeg.avcodec.defs import AVDiscard
from mav.ffmpeg.avcodec.avcodec import AVCodecParserContext

from mav.ffmpeg.avutil.log import AVClass
from mav.ffmpeg.avutil.rational import AVRational
from mav.ffmpeg.avutil.dict import AVDictionary
from mav.ffmpeg.avutil.avutil import AVMediaType
from mav.ffmpeg.avutil.pixfmt import (
    AVPixelFormat,
    AVColorSpace,
    AVColorPrimaries,
    AVColorTransferCharacteristic,
)
from mav.ffmpeg.avformat.internal import AVCodecTag
from mav.ffmpeg.avformat.avio import AVIOContext, AVIOInterruptCB

from mav.ffmpeg.avutil.iamf import (
    AVIAMFMixPresentation,
    AVIAMFSubmix,
    AVIAMFSubmixElement,
    AVIAMFSubmixLayout,
    AVIAMFAudioElement,
    AVIAMFLayer,
    AVIAMFParamDefinition,
    AVIAMFAudioElementType,
    AVIAMFHeadphonesMode,
    AVIAMFSubmixLayoutType,
)


fn swscale_version() -> c_uint:
    return external_call["swscale_version", c_uint]()


fn swscale_configuration() -> UnsafePointer[c_char, ImmutExternalOrigin]:
    return external_call[
        "swscale_configuration", UnsafePointer[c_char, ImmutExternalOrigin]
    ]()


fn swscale_license() -> UnsafePointer[c_char, ImmutExternalOrigin]:
    return external_call[
        "swscale_license", UnsafePointer[c_char, ImmutExternalOrigin]
    ]()


fn sws_get_class() -> UnsafePointer[AVClass, ImmutExternalOrigin]:
    return external_call[
        "sws_get_class", UnsafePointer[AVClass, ImmutExternalOrigin]
    ]()


#############################
# Flags and quality settings #
#############################


@fieldwise_init
struct SwsDither(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var value: Self.ENUM_DTYPE

    comptime SWS_DITHER_NONE = Self(0)
    comptime SWS_DITHER_AUTO = Self(1)
    comptime SWS_DITHER_BAYER = Self(2)
    comptime SWS_DITHER_ED = Self(3)
    comptime SWS_DITHER_A_DITHER = Self(4)
    comptime SWS_DITHER_X_DITHER = Self(5)
    comptime SWS_DITHER_NB = Self(6)


@fieldwise_init
struct SwsAlphaBlend(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var value: Self.ENUM_DTYPE

    comptime SWS_ALPHA_BLEND_NONE = Self(0)
    comptime SWS_ALPHA_BLEND_UNIFORM = Self(1)
    comptime SWS_ALPHA_BLEND_CHECKERBOARD = Self(2)
    comptime SWS_ALPHA_BLEND_NB = Self(3)


@fieldwise_init
struct SwsFlags(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var value: Self.ENUM_DTYPE

    comptime SWS_FAST_BILINEAR = Self(1 << 0)
    comptime SWS_BILINEAR = Self(1 << 1)
    comptime SWS_BICUBIC = Self(1 << 2)
    comptime SWS_X = Self(1 << 3)
    comptime SWS_POINT = Self(1 << 4)
    comptime SWS_AREA = Self(1 << 5)
    comptime SWS_BICUBLIN = Self(1 << 6)
    comptime SWS_GAUSS = Self(1 << 7)
    comptime SWS_SINC = Self(1 << 8)
    comptime SWS_LANCZOS = Self(1 << 9)
    comptime SWS_SPLINE = Self(1 << 10)

    comptime SWS_STRICT = Self(1 << 11)

    comptime SWS_PRINT_INFO = Self(1 << 12)

    comptime SWS_FULL_CHR_H_INT = Self(1 << 13)
    comptime SWS_FULL_CHR_H_INP = Self(1 << 14)
    comptime SWS_ACCURATE_RND = Self(1 << 18)

    comptime SWS_BITEXACT = Self(1 << 19)

    # Deprecated flags.
    comptime SWS_DIRECT_BGR = Self(1 << 15)
    comptime SWS_ERROR_DIFFUSION = Self(1 << 23)


@fieldwise_init
struct SwsIntent(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var value: Self.ENUM_DTYPE

    comptime SWS_INTENT_PERCEPTUAL = Self(0)
    comptime SWS_INTENT_RELATIVE_COLORIMETRIC = Self(1)
    comptime SWS_INTENT_SATURATION = Self(2)
    comptime SWS_INTENT_ABSOLUTE_COLORIMETRIC = Self(3)
    comptime SWS_INTENT_NB = Self(4)


###################################
# Context creation and management #
###################################


@fieldwise_init
struct SwsContext(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structSwsContext.html."
    var av_class: UnsafePointer[AVClass, ImmutExternalOrigin]
    var opaque: OpaquePointer[MutExternalOrigin]
    var flags: SwsFlags.ENUM_DTYPE
    var scaler_params: StaticTuple[c_double, 2]
    var threads: c_int
    var dither: SwsDither.ENUM_DTYPE
    var alpha_blend: SwsAlphaBlend.ENUM_DTYPE
    var gamma_flag: c_int

    # Deprecated frame property overrides, for the legacy API only.
    # Ignored by sws_scale_frame() when used in dynamic mode, in which
    # case all properties are instead taken from the frame directly.
    var src_w: c_int
    var src_h: c_int
    var src_format: c_int
    var dst_format: c_int
    var src_range: c_int
    var dst_range: c_int
    var src_v_chr_pos: c_int
    var src_h_chr_pos: c_int
    var dst_v_chr_pos: c_int
    var dst_h_chr_pos: c_int

    var intent: c_int

    # Remember to add new fields to graph.c:opts_equal()


####################################################
# Supported frame formats #
####################################################


fn sws_test_format(format: AVPixelFormat.ENUM_DTYPE, output: c_int) -> c_int:
    return external_call["sws_test_format", c_int](format, output)


fn sws_test_colorspace(
    colorspace: AVColorSpace.ENUM_DTYPE, output: c_int
) -> c_int:
    return external_call["sws_test_colorspace", c_int](colorspace, output)


fn sws_test_primaries(
    primaries: AVColorPrimaries.ENUM_DTYPE, output: c_int
) -> c_int:
    return external_call["sws_test_primaries", c_int](primaries, output)


fn sws_test_transfer(
    transfer: AVColorTransferCharacteristic.ENUM_DTYPE, output: c_int
) -> c_int:
    return external_call["sws_test_transfer", c_int](transfer, output)


fn sws_test_frame(
    frame: UnsafePointer[AVFrame, ImmutExternalOrigin], output: c_int
) -> c_int:
    return external_call["sws_test_frame", c_int](frame, output)


fn sws_frame_setup(
    ctx: UnsafePointer[SwsContext, MutExternalOrigin],
    dst: UnsafePointer[AVFrame, ImmutExternalOrigin],
    src: UnsafePointer[AVFrame, ImmutExternalOrigin],
) -> c_int:
    return external_call["sws_frame_setup", c_int](ctx, dst, src)


####################################################
# Main scaling API #
####################################################


fn sws_is_noop(
    dst: UnsafePointer[AVFrame, ImmutExternalOrigin],
    src: UnsafePointer[AVFrame, ImmutExternalOrigin],
) -> c_int:
    return external_call["sws_is_noop", c_int](dst, src)


fn sws_scale_frame(
    ctx: UnsafePointer[SwsContext, MutExternalOrigin],
    dst: UnsafePointer[AVFrame, MutExternalOrigin],
    src: UnsafePointer[AVFrame, ImmutExternalOrigin],
) -> c_int:
    return external_call["sws_scale_frame", c_int](ctx, dst, src)


####################################################
# Legacy (stateful) API #
####################################################

comptime SWS_SRC_V_CHR_DROP_MASK = 0x30000
comptime SWS_SRC_V_CHR_DROP_SHIFT = 16

comptime SWS_PARAM_DEFAULT = 123456
comptime SWS_MAX_REDUCE_CUTOFF = 0.002

comptime SWS_CS_ITU709 = 1
comptime SWS_CS_FCC = 4
comptime SWS_CS_ITU601 = 5
comptime SWS_CS_ITU624 = 5
comptime SWS_CS_SMPTE170M = 5
comptime SWS_CS_SMPTE240M = 7
comptime SWS_CS_DEFAULT = 5
comptime SWS_CS_BT2020 = 9


fn sws_getCoefficients(
    colorspace: c_int,
) -> UnsafePointer[c_int, ImmutExternalOrigin]:
    return external_call[
        "sws_getCoefficients", UnsafePointer[c_int, ImmutExternalOrigin]
    ](colorspace)


@fieldwise_init
struct SwsVector(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structSwsVector.html."
    var coeff: UnsafePointer[c_double, ImmutExternalOrigin]
    var length: c_int


@fieldwise_init
struct SwsFilter(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structSwsFilter.html."
    var lumH: UnsafePointer[SwsVector, ImmutExternalOrigin]
    var lumV: UnsafePointer[SwsVector, ImmutExternalOrigin]
    var chrH: UnsafePointer[SwsVector, ImmutExternalOrigin]
    var chrV: UnsafePointer[SwsVector, ImmutExternalOrigin]


fn sws_isSupportedInput(pix_fmt: AVPixelFormat.ENUM_DTYPE) -> c_int:
    return external_call["sws_isSupportedInput", c_int](pix_fmt)


fn sws_isSupportedOutput(pix_fmt: AVPixelFormat.ENUM_DTYPE) -> c_int:
    return external_call["sws_isSupportedOutput", c_int](pix_fmt)


fn sws_isSupportedEndiannessConversion(
    pix_fmt: AVPixelFormat.ENUM_DTYPE,
) -> c_int:
    return external_call["sws_isSupportedEndiannessConversion", c_int](pix_fmt)


fn sws_init_context(
    ctx: UnsafePointer[SwsContext, MutExternalOrigin],
    srcFilter: UnsafePointer[SwsFilter, MutExternalOrigin],
    dstFilter: UnsafePointer[SwsFilter, MutExternalOrigin],
) -> c_int:
    return external_call["sws_init_context", c_int](ctx, srcFilter, dstFilter)


fn sws_freeContext(ctx: UnsafePointer[SwsContext, MutExternalOrigin]):
    external_call["sws_freeContext", NoneType](ctx)


fn sws_getContext(
    srcW: c_int,
    srcH: c_int,
    srcFormat: AVPixelFormat.ENUM_DTYPE,
    dstW: c_int,
    dstH: c_int,
    dstFormat: AVPixelFormat.ENUM_DTYPE,
    flags: c_int,
    srcFilter: UnsafePointer[SwsFilter, MutExternalOrigin],
    dstFilter: UnsafePointer[SwsFilter, MutExternalOrigin],
    param: UnsafePointer[c_double, ImmutExternalOrigin],
) -> UnsafePointer[SwsContext, MutExternalOrigin]:
    return external_call[
        "sws_getContext", UnsafePointer[SwsContext, MutExternalOrigin]
    ](
        srcW,
        srcH,
        srcFormat,
        dstW,
        dstH,
        dstFormat,
        flags,
        srcFilter,
        dstFilter,
        param,
    )


fn sws_scale(
    ctx: UnsafePointer[SwsContext, MutExternalOrigin],
    srcSlice: UnsafePointer[
        UnsafePointer[c_uchar, ImmutExternalOrigin], ImmutExternalOrigin
    ],
    srcStride: UnsafePointer[c_int, ImmutExternalOrigin],
    srcSliceY: c_int,
    srcSliceH: c_int,
    dst: UnsafePointer[
        UnsafePointer[c_uchar, MutExternalOrigin], MutExternalOrigin
    ],
    dstStride: UnsafePointer[c_int, ImmutExternalOrigin],
) -> c_int:
    return external_call["sws_scale", c_int](
        ctx, srcSlice, srcStride, srcSliceY, srcSliceH, dst, dstStride
    )


fn sws_frame_start(
    ctx: UnsafePointer[SwsContext, MutExternalOrigin],
    dst: UnsafePointer[AVFrame, MutExternalOrigin],
    src: UnsafePointer[AVFrame, ImmutExternalOrigin],
) -> c_int:
    return external_call["sws_frame_start", c_int](ctx, dst, src)


fn sws_frame_end(ctx: UnsafePointer[SwsContext, MutExternalOrigin]):
    external_call["sws_frame_end", NoneType](ctx)


fn sws_send_slice(
    ctx: UnsafePointer[SwsContext, MutExternalOrigin],
    slice_start: c_uint,
    slice_height: c_uint,
) -> c_int:
    return external_call["sws_send_slice", c_int](
        ctx, slice_start, slice_height
    )


fn sws_receive_slice(
    ctx: UnsafePointer[SwsContext, MutExternalOrigin],
    slice_start: c_uint,
    slice_height: c_uint,
) -> c_int:
    return external_call["sws_receive_slice", c_int](
        ctx, slice_start, slice_height
    )


fn sws_receive_slice_alignment(
    ctx: UnsafePointer[SwsContext, ImmutExternalOrigin]
) -> c_uint:
    return external_call["sws_receive_slice_alignment", c_uint](ctx)


fn sws_setColorspaceDetails(
    ctx: UnsafePointer[SwsContext, MutExternalOrigin],
    inv_table: UnsafePointer[c_int, ImmutExternalOrigin],
    srcRange: c_int,
    table: UnsafePointer[c_int, ImmutExternalOrigin],
    dstRange: c_int,
    brightness: c_int,
    contrast: c_int,
    saturation: c_int,
) -> c_int:
    return external_call["sws_setColorspaceDetails", c_int](
        ctx,
        inv_table,
        srcRange,
        table,
        dstRange,
        brightness,
        contrast,
        saturation,
    )


fn sws_allocVec(length: c_int) -> UnsafePointer[SwsVector, MutExternalOrigin]:
    return external_call[
        "sws_allocVec", UnsafePointer[SwsVector, MutExternalOrigin]
    ](length)


fn sws_getGaussianVec(
    variance: c_double, quality: c_double
) -> UnsafePointer[SwsVector, MutExternalOrigin]:
    return external_call[
        "sws_getGaussianVec", UnsafePointer[SwsVector, MutExternalOrigin]
    ](variance, quality)


fn sws_scaleVec(
    a: UnsafePointer[SwsVector, MutExternalOrigin], scalar: c_double
):
    external_call["sws_scaleVec", NoneType](a, scalar)


fn sws_normalizeVec(
    a: UnsafePointer[SwsVector, MutExternalOrigin], height: c_double
):
    external_call["sws_normalizeVec", NoneType](a, height)


fn sws_freeVec(a: UnsafePointer[SwsVector, MutExternalOrigin]):
    external_call["sws_freeVec", NoneType](a)


fn sws_getDefaultFilter(
    lumaGBlur: c_float,
    chromaGBlur: c_float,
    lumaSharpen: c_float,
    chromaSharpen: c_float,
    chromaHShift: c_float,
    chromaVShift: c_float,
    verbose: c_int,
) -> UnsafePointer[SwsFilter, MutExternalOrigin]:
    return external_call[
        "sws_getDefaultFilter", UnsafePointer[SwsFilter, MutExternalOrigin]
    ](
        lumaGBlur,
        chromaGBlur,
        lumaSharpen,
        chromaSharpen,
        chromaHShift,
        chromaVShift,
        verbose,
    )


fn sws_freeFilter(filter: UnsafePointer[SwsFilter, MutExternalOrigin]):
    external_call["sws_freeFilter", NoneType](filter)


fn sws_getCachedContext(
    ctx: UnsafePointer[SwsContext, MutExternalOrigin],
    srcW: c_int,
    srcH: c_int,
    srcFormat: AVPixelFormat.ENUM_DTYPE,
    dstW: c_int,
    dstH: c_int,
    dstFormat: AVPixelFormat.ENUM_DTYPE,
    flags: c_int,
    srcFilter: UnsafePointer[SwsFilter, MutExternalOrigin],
    dstFilter: UnsafePointer[SwsFilter, MutExternalOrigin],
    param: UnsafePointer[c_double, ImmutExternalOrigin],
) -> UnsafePointer[SwsContext, MutExternalOrigin]:
    return external_call[
        "sws_getCachedContext", UnsafePointer[SwsContext, MutExternalOrigin]
    ](
        ctx,
        srcW,
        srcH,
        srcFormat,
        dstW,
        dstH,
        dstFormat,
        flags,
        srcFilter,
        dstFilter,
        param,
    )


fn sws_convertPalette8ToPacked32(
    src: UnsafePointer[c_uchar, ImmutExternalOrigin],
    dst: UnsafePointer[c_uchar, MutExternalOrigin],
    num_pixels: c_int,
    palette: UnsafePointer[c_uchar, ImmutExternalOrigin],
):
    external_call["sws_convertPalette8ToPacked32", NoneType](
        src, dst, num_pixels, palette
    )


fn sws_convertPalette8ToPacked24(
    src: UnsafePointer[c_uchar, ImmutExternalOrigin],
    dst: UnsafePointer[c_uchar, MutExternalOrigin],
    num_pixels: c_int,
    palette: UnsafePointer[c_uchar, ImmutExternalOrigin],
):
    external_call["sws_convertPalette8ToPacked24", NoneType](
        src, dst, num_pixels, palette
    )
