"See https://www.ffmpeg.org/doxygen/8.0/swresample_8h.html."
from std.ffi import (
    c_int,
    c_uchar,
    c_long_long,
    c_double,
    c_size_t,
    external_call,
)
from mav._clib import ExternalFunction, c_ptrdiff_t
from mav.ffmpeg.avutil.log import AVClass
from mav.ffmpeg.avutil.channel_layout import (
    AVChannelLayout,
    AVMatrixEncoding,
)
from mav.ffmpeg.avutil.samplefmt import AVSampleFormat


########################################################
# ===                Option constants                ===
########################################################
#
# These constants are used for the ref avoptions interface for lswr.
########################################################

comptime SWR_FLAG_RESAMPLE = Int(1)


@fieldwise_init
struct SwrDitherType(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var value: Self.ENUM_DTYPE

    comptime SWR_DITHER_NONE = Self(0)
    comptime SWR_DITHER_RECTANGULAR = Self(1)
    comptime SWR_DITHER_TRIANGULAR = Self(2)
    comptime SWR_DITHER_TRIANGULAR_HIGHPASS = Self(3)

    comptime SWR_DITHER_NS = Self(64)
    comptime SWR_DITHER_NS_LIPSHITZ = Self(65)
    comptime SWR_DITHER_NS_F_WEIGHTED = Self(66)
    comptime SWR_DITHER_NS_MODIFIED_E_WEIGHTED = Self(67)
    comptime SWR_DITHER_NS_IMPROVED_E_WEIGHTED = Self(68)
    comptime SWR_DITHER_NS_SHIBATA = Self(69)
    comptime SWR_DITHER_NS_LOW_SHIBATA = Self(70)
    comptime SWR_DITHER_NS_HIGH_SHIBATA = Self(71)
    comptime SWR_DITHER_NB = Self(72)


@fieldwise_init
struct SwrEngine(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var value: Self.ENUM_DTYPE

    comptime SWR_ENGINE_SWR = Self(0)
    comptime SWR_ENGINE_SOXR = Self(1)
    comptime SWR_ENGINE_NB = Self(2)


@fieldwise_init
struct SwrFilterType(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var value: Self.ENUM_DTYPE

    comptime SWR_FILTER_TYPE_CUBIC = Self(0)
    comptime SWR_FILTER_TYPE_BLACKMAN_NUTTALL = Self(1)
    comptime SWR_FILTER_TYPE_KAISER = Self(2)


@fieldwise_init
struct SwrContext(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structSwrContext.html."
    pass


fn swr_get_class() -> UnsafePointer[AVClass, ImmutExternalOrigin]:
    return external_call[
        "swr_get_class", UnsafePointer[AVClass, ImmutExternalOrigin]
    ]()


fn swr_alloc() -> UnsafePointer[SwrContext, MutExternalOrigin]:
    return external_call[
        "swr_alloc", UnsafePointer[SwrContext, MutExternalOrigin]
    ]()


fn swr_init(context: UnsafePointer[SwrContext, MutExternalOrigin]) -> c_int:
    return external_call["swr_init", c_int](context)


fn swr_is_initialized(
    context: UnsafePointer[SwrContext, ImmutExternalOrigin]
) -> c_int:
    return external_call["swr_is_initialized", c_int](context)


fn swr_alloc_set_opts2(
    context: UnsafePointer[
        UnsafePointer[SwrContext, MutExternalOrigin], MutExternalOrigin
    ],
    out_ch_layout: UnsafePointer[AVChannelLayout, ImmutExternalOrigin],
    out_sample_fmt: AVSampleFormat.ENUM_DTYPE,
    out_sample_rate: c_int,
    in_ch_layout: UnsafePointer[AVChannelLayout, ImmutExternalOrigin],
    in_sample_fmt: AVSampleFormat.ENUM_DTYPE,
    in_sample_rate: c_int,
    log_offset: c_int,
    log_ctx: OpaquePointer[MutExternalOrigin],
) -> c_int:
    return external_call["swr_alloc_set_opts2", c_int](
        context,
        out_ch_layout,
        out_sample_fmt,
        out_sample_rate,
        in_ch_layout,
        in_sample_fmt,
        in_sample_rate,
        log_offset,
        log_ctx,
    )


fn swr_free(
    context: UnsafePointer[
        UnsafePointer[SwrContext, MutExternalOrigin], MutExternalOrigin
    ]
):
    external_call["swr_free", NoneType](context)


fn swr_close(context: UnsafePointer[SwrContext, MutExternalOrigin]):
    external_call["swr_close", NoneType](context)


fn swr_convert(
    s: UnsafePointer[SwrContext, MutExternalOrigin],
    out_: UnsafePointer[
        UnsafePointer[c_uchar, MutExternalOrigin], ImmutExternalOrigin
    ],
    out_count: c_int,
    in_: UnsafePointer[
        UnsafePointer[c_uchar, ImmutExternalOrigin], ImmutExternalOrigin
    ],
    in_count: c_int,
) -> c_int:
    return external_call["swr_convert", c_int](
        s, out_, out_count, in_, in_count
    )


fn swr_next_pts(
    s: UnsafePointer[SwrContext, MutExternalOrigin],
    pts: c_long_long,
) -> c_long_long:
    return external_call["swr_next_pts", c_long_long](s, pts)


fn swr_set_compensation(
    s: UnsafePointer[SwrContext, MutExternalOrigin],
    sample_delta: c_int,
    compensation_distance: c_int,
) -> c_int:
    return external_call["swr_set_compensation", c_int](
        s, sample_delta, compensation_distance
    )


fn swr_set_channel_mapping(
    s: UnsafePointer[SwrContext, MutExternalOrigin],
    channel_map: UnsafePointer[c_int, ImmutExternalOrigin],
) -> c_int:
    return external_call["swr_set_channel_mapping", c_int](s, channel_map)


fn swr_build_matrix2(
    in_layout: UnsafePointer[AVChannelLayout, ImmutExternalOrigin],
    out_layout: UnsafePointer[AVChannelLayout, ImmutExternalOrigin],
    center_mix_level: c_double,
    surround_mix_level: c_double,
    lfe_mix_level: c_double,
    rematrix_maxval: c_double,
    rematrix_volume: c_double,
    matrix: UnsafePointer[c_double, MutExternalOrigin],
    stride: c_ptrdiff_t,
    matrix_encoding: AVMatrixEncoding.ENUM_DTYPE,
    log_ctx: OpaquePointer[MutExternalOrigin],
) -> c_int:
    return external_call["swr_build_matrix2", c_int](
        in_layout,
        out_layout,
        center_mix_level,
        surround_mix_level,
        lfe_mix_level,
        rematrix_maxval,
        rematrix_volume,
        matrix,
        stride,
        matrix_encoding,
        log_ctx,
    )
