from std.testing import TestSuite, assert_true, assert_equal
from std.memory import alloc, memset
from std.ffi import c_int, c_uchar, c_long_long, c_double
from mav.ffmpeg import avutil
from mav.ffmpeg.avutil.channel_layout import (
    AVChannelLayout,
    AV_CH_LAYOUT_STEREO,
    AVMatrixEncoding,
)
from mav.ffmpeg.avutil.samplefmt import AVSampleFormat
from mav.ffmpeg.swrsample import swrsample


def test_swr_get_class() raises:
    var cls = swrsample.swr_get_class()
    assert_true(Bool(cls))


def test_swr_alloc() raises:
    var ctx = swrsample.swr_alloc()
    assert_true(Bool(ctx))
    var ctx_ptr = alloc[UnsafePointer[swrsample.SwrContext, MutExternalOrigin]](
        1
    )
    ctx_ptr[0] = ctx
    swrsample.swr_free(ctx_ptr)


def test_swr_alloc_and_init() raises:
    var out_layout = alloc[AVChannelLayout](1)
    var in_layout = alloc[AVChannelLayout](1)
    memset(out_layout, 0, 1)
    memset(in_layout, 0, 1)
    _ = avutil.av_channel_layout_from_mask(
        out_layout,
        AV_CH_LAYOUT_STEREO,
    )
    _ = avutil.av_channel_layout_from_mask(
        in_layout,
        AV_CH_LAYOUT_STEREO,
    )
    var ctx_ptr = alloc[UnsafePointer[swrsample.SwrContext, MutExternalOrigin]](
        1
    )
    memset(ctx_ptr, 0, 1)
    var ret = swrsample.swr_alloc_set_opts2(
        ctx_ptr,
        out_layout.as_immutable(),
        AVSampleFormat.AV_SAMPLE_FMT_S16._value,
        48000,
        in_layout.as_immutable(),
        AVSampleFormat.AV_SAMPLE_FMT_S16._value,
        44100,
        0,
        OpaquePointer[MutExternalOrigin](unsafe_from_address=0),
    )
    assert_equal(ret, 0)
    assert_true(Bool(ctx_ptr[0]))
    var init_ret = swrsample.swr_init(ctx_ptr[0])
    assert_equal(init_ret, 0)
    swrsample.swr_free(ctx_ptr)
    avutil.av_channel_layout_uninit(out_layout)
    avutil.av_channel_layout_uninit(in_layout)


def test_swr_is_initialized() raises:
    var ctx = swrsample.swr_alloc()
    assert_equal(
        swrsample.swr_is_initialized(ctx.as_immutable()),
        0,
    )
    var ctx_ptr = alloc[UnsafePointer[swrsample.SwrContext, MutExternalOrigin]](
        1
    )
    ctx_ptr[0] = ctx
    swrsample.swr_free(ctx_ptr)


def test_swr_close() raises:
    var out_layout = alloc[AVChannelLayout](1)
    var in_layout = alloc[AVChannelLayout](1)
    memset(out_layout, 0, 1)
    memset(in_layout, 0, 1)
    _ = avutil.av_channel_layout_from_mask(
        out_layout,
        AV_CH_LAYOUT_STEREO,
    )
    _ = avutil.av_channel_layout_from_mask(
        in_layout,
        AV_CH_LAYOUT_STEREO,
    )
    var ctx_ptr = alloc[UnsafePointer[swrsample.SwrContext, MutExternalOrigin]](
        1
    )
    memset(ctx_ptr, 0, 1)
    var ret = swrsample.swr_alloc_set_opts2(
        ctx_ptr,
        out_layout.as_immutable(),
        AVSampleFormat.AV_SAMPLE_FMT_S16._value,
        48000,
        in_layout.as_immutable(),
        AVSampleFormat.AV_SAMPLE_FMT_S16._value,
        44100,
        0,
        OpaquePointer[MutExternalOrigin](unsafe_from_address=0),
    )
    _ = swrsample.swr_init(ctx_ptr[0])
    swrsample.swr_close(ctx_ptr[0])
    swrsample.swr_free(ctx_ptr)
    avutil.av_channel_layout_uninit(out_layout)
    avutil.av_channel_layout_uninit(in_layout)


def test_swr_convert() raises:
    var out_layout = alloc[AVChannelLayout](1)
    var in_layout = alloc[AVChannelLayout](1)
    memset(out_layout, 0, 1)
    memset(in_layout, 0, 1)
    _ = avutil.av_channel_layout_from_mask(
        out_layout,
        AV_CH_LAYOUT_STEREO,
    )
    _ = avutil.av_channel_layout_from_mask(
        in_layout,
        AV_CH_LAYOUT_STEREO,
    )
    var ctx_ptr = alloc[UnsafePointer[swrsample.SwrContext, MutExternalOrigin]](
        1
    )
    memset(ctx_ptr, 0, 1)
    var ret = swrsample.swr_alloc_set_opts2(
        ctx_ptr,
        out_layout.as_immutable(),
        AVSampleFormat.AV_SAMPLE_FMT_S16._value,
        48000,
        in_layout.as_immutable(),
        AVSampleFormat.AV_SAMPLE_FMT_S16._value,
        44100,
        0,
        OpaquePointer[MutExternalOrigin](unsafe_from_address=0),
    )
    assert_equal(ret, 0)
    var init_ret = swrsample.swr_init(ctx_ptr[0])
    assert_equal(init_ret, 0)
    var in_buf = alloc[c_uchar](1024)
    var out_buf = alloc[c_uchar](1024)
    var in_ptrs = alloc[UnsafePointer[c_uchar, ImmutExternalOrigin]](1)
    var out_ptrs = alloc[UnsafePointer[c_uchar, MutExternalOrigin]](1)
    in_ptrs[0] = in_buf.as_immutable()
    out_ptrs[0] = out_buf
    var n = swrsample.swr_convert(
        ctx_ptr[0],
        out_ptrs.as_immutable(),
        256,
        in_ptrs.as_immutable(),
        256,
    )
    assert_true(n >= 0)
    swrsample.swr_free(ctx_ptr)
    avutil.av_channel_layout_uninit(out_layout)
    avutil.av_channel_layout_uninit(in_layout)


def test_swr_next_pts() raises:
    var out_layout = alloc[AVChannelLayout](1)
    var in_layout = alloc[AVChannelLayout](1)
    memset(out_layout, 0, 1)
    memset(in_layout, 0, 1)
    _ = avutil.av_channel_layout_from_mask(
        out_layout,
        AV_CH_LAYOUT_STEREO,
    )
    _ = avutil.av_channel_layout_from_mask(
        in_layout,
        AV_CH_LAYOUT_STEREO,
    )
    var ctx_ptr = alloc[UnsafePointer[swrsample.SwrContext, MutExternalOrigin]](
        1
    )
    memset(ctx_ptr, 0, 1)
    var ret = swrsample.swr_alloc_set_opts2(
        ctx_ptr,
        out_layout.as_immutable(),
        AVSampleFormat.AV_SAMPLE_FMT_S16._value,
        48000,
        in_layout.as_immutable(),
        AVSampleFormat.AV_SAMPLE_FMT_S16._value,
        44100,
        0,
        OpaquePointer[MutExternalOrigin](unsafe_from_address=0),
    )
    assert_equal(ret, 0)
    var init_ret = swrsample.swr_init(ctx_ptr[0])
    assert_equal(init_ret, 0)
    var pts = swrsample.swr_next_pts(ctx_ptr[0], 0)
    assert_true(pts >= -1)
    swrsample.swr_free(ctx_ptr)
    avutil.av_channel_layout_uninit(out_layout)
    avutil.av_channel_layout_uninit(in_layout)


def test_swr_set_compensation() raises:
    var out_layout = alloc[AVChannelLayout](1)
    var in_layout = alloc[AVChannelLayout](1)
    memset(out_layout, 0, 1)
    memset(in_layout, 0, 1)
    _ = avutil.av_channel_layout_from_mask(
        out_layout,
        AV_CH_LAYOUT_STEREO,
    )
    _ = avutil.av_channel_layout_from_mask(
        in_layout,
        AV_CH_LAYOUT_STEREO,
    )
    var ctx_ptr = alloc[UnsafePointer[swrsample.SwrContext, MutExternalOrigin]](
        1
    )
    memset(ctx_ptr, 0, 1)
    var ret = swrsample.swr_alloc_set_opts2(
        ctx_ptr,
        out_layout.as_immutable(),
        AVSampleFormat.AV_SAMPLE_FMT_S16._value,
        48000,
        in_layout.as_immutable(),
        AVSampleFormat.AV_SAMPLE_FMT_S16._value,
        44100,
        0,
        OpaquePointer[MutExternalOrigin](unsafe_from_address=0),
    )
    assert_equal(ret, 0)
    var init_ret = swrsample.swr_init(ctx_ptr[0])
    assert_equal(init_ret, 0)
    var ret1 = swrsample.swr_set_compensation(ctx_ptr[0], 0, 0)
    assert_equal(ret1, 0)
    swrsample.swr_free(ctx_ptr)
    avutil.av_channel_layout_uninit(out_layout)
    avutil.av_channel_layout_uninit(in_layout)


def test_swr_set_channel_mapping() raises:
    var out_layout = alloc[AVChannelLayout](1)
    var in_layout = alloc[AVChannelLayout](1)
    memset(out_layout, 0, 1)
    memset(in_layout, 0, 1)
    _ = avutil.av_channel_layout_from_mask(
        out_layout,
        AV_CH_LAYOUT_STEREO,
    )
    _ = avutil.av_channel_layout_from_mask(
        in_layout,
        AV_CH_LAYOUT_STEREO,
    )
    var ctx_ptr = alloc[UnsafePointer[swrsample.SwrContext, MutExternalOrigin]](
        1
    )
    memset(ctx_ptr, 0, 1)
    var ret = swrsample.swr_alloc_set_opts2(
        ctx_ptr,
        out_layout.as_immutable(),
        AVSampleFormat.AV_SAMPLE_FMT_S16._value,
        48000,
        in_layout.as_immutable(),
        AVSampleFormat.AV_SAMPLE_FMT_S16._value,
        44100,
        0,
        OpaquePointer[MutExternalOrigin](unsafe_from_address=0),
    )
    # Must be called before swr_init: context allocated but not yet initialized.
    var map = alloc[c_int](2)
    map[0] = 0
    map[1] = 1
    var ret1 = swrsample.swr_set_channel_mapping(
        ctx_ptr[0],
        map.as_immutable(),
    )
    assert_equal(ret1, 0)
    var init_ret = swrsample.swr_init(ctx_ptr[0])
    assert_equal(init_ret, 0)
    swrsample.swr_free(ctx_ptr)
    avutil.av_channel_layout_uninit(out_layout)
    avutil.av_channel_layout_uninit(in_layout)


def test_swr_build_matrix2() raises:
    var out_layout = alloc[AVChannelLayout](1)
    var in_layout = alloc[AVChannelLayout](1)
    memset(out_layout, 0, 1)
    memset(in_layout, 0, 1)
    _ = avutil.av_channel_layout_from_mask(
        out_layout,
        AV_CH_LAYOUT_STEREO,
    )
    _ = avutil.av_channel_layout_from_mask(
        in_layout,
        AV_CH_LAYOUT_STEREO,
    )
    var matrix = alloc[c_double](4)
    var ret1 = swrsample.swr_build_matrix2(
        in_layout.as_immutable(),
        out_layout.as_immutable(),
        1.0,
        1.0,
        1.0,
        1.0,
        1.0,
        matrix,
        2,
        AVMatrixEncoding.AV_MATRIX_ENCODING_NONE._value,
        OpaquePointer[MutExternalOrigin](unsafe_from_address=0),
    )
    assert_equal(ret1, 0)
    avutil.av_channel_layout_uninit(out_layout)
    avutil.av_channel_layout_uninit(in_layout)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
    # test_swr_get_class()
    # test_swr_alloc()
    # test_swr_alloc_and_init()
    # test_swr_is_initialized()
    # test_swr_close()
    # test_swr_convert()
    # test_swr_next_pts()
    # test_swr_set_compensation()
    # test_swr_set_channel_mapping()
    # test_swr_build_matrix2()
