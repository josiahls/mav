from std.testing import TestSuite, assert_true, assert_equal
from std.memory import alloc, memset
from std.ffi import c_double, c_int, c_uchar
from mav.ffmpeg.swscale.swscale import SwsFilter
from mav.ffmpeg.swscale import swscale as sws
from mav.ffmpeg import avutil
from mav.ffmpeg.avutil.frame import AVFrame
from mav.ffmpeg.avutil.pixfmt import (
    AVPixelFormat,
    AVColorSpace,
    AVColorPrimaries,
    AVColorTransferCharacteristic,
)


def test_swscale_version() raises:
    var v = sws.swscale_version()
    assert_true(v > 0)


def test_swscale_configuration() raises:
    var cfg = sws.swscale_configuration()
    assert_true(Bool(cfg))


def test_swscale_license() raises:
    var lic = sws.swscale_license()
    assert_true(Bool(lic))


def test_sws_get_class() raises:
    var cls = sws.sws_get_class()
    assert_true(Bool(cls))


def test_sws_test_format() raises:
    var ret = sws.sws_test_format(AVPixelFormat.AV_PIX_FMT_YUV420P._value, 0)
    assert_true(ret >= 0)


def test_sws_test_colorspace() raises:
    var ret = sws.sws_test_colorspace(AVColorSpace.AVCOL_SPC_BT709._value, 0)
    assert_true(ret >= 0)


def test_sws_test_primaries() raises:
    var ret = sws.sws_test_primaries(AVColorPrimaries.AVCOL_PRI_BT709._value, 0)
    assert_true(ret >= 0)


def test_sws_test_transfer() raises:
    var ret = sws.sws_test_transfer(
        AVColorTransferCharacteristic.AVCOL_TRC_BT709._value, 0
    )
    assert_true(ret >= 0)


def test_sws_isSupportedInput() raises:
    var ret = sws.sws_isSupportedInput(AVPixelFormat.AV_PIX_FMT_YUV420P._value)
    assert_true(ret >= 0)


def test_sws_isSupportedOutput() raises:
    var ret = sws.sws_isSupportedOutput(AVPixelFormat.AV_PIX_FMT_YUV420P._value)
    assert_true(ret >= 0)


def test_sws_isSupportedEndiannessConversion() raises:
    var ret = sws.sws_isSupportedEndiannessConversion(
        AVPixelFormat.AV_PIX_FMT_YUV420P._value
    )
    assert_true(ret >= 0)


def test_sws_getCoefficients() raises:
    var coeffs = sws.sws_getCoefficients(5)
    assert_true(Bool(coeffs))


def test_sws_getContext_and_free() raises:
    var ctx = sws.sws_getContext(
        640,
        480,
        AVPixelFormat.AV_PIX_FMT_YUV420P._value,
        320,
        240,
        AVPixelFormat.AV_PIX_FMT_YUV420P._value,
        0,
        UnsafePointer[SwsFilter, MutExternalOrigin](unsafe_from_address=0),
        UnsafePointer[SwsFilter, MutExternalOrigin](unsafe_from_address=0),
        UnsafePointer[c_double, ImmutExternalOrigin](unsafe_from_address=0),
    )
    assert_true(Bool(ctx))
    sws.sws_freeContext(ctx)


def test_sws_getDefaultFilter_and_free() raises:
    var f = sws.sws_getDefaultFilter(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0)
    assert_true(Bool(f))
    sws.sws_freeFilter(f)


def test_sws_allocVec_and_free() raises:
    var v = sws.sws_allocVec(16)
    assert_true(Bool(v))
    sws.sws_freeVec(v)


def test_sws_getGaussianVec() raises:
    var v = sws.sws_getGaussianVec(1.0, 1.0)
    assert_true(Bool(v))
    sws.sws_freeVec(v)


def test_sws_scaleVec() raises:
    var v = sws.sws_allocVec(8)
    assert_true(Bool(v))
    sws.sws_scaleVec(v, 2.0)
    sws.sws_freeVec(v)


def test_sws_normalizeVec() raises:
    var v = sws.sws_allocVec(8)
    assert_true(Bool(v))
    sws.sws_normalizeVec(v, 1.0)
    sws.sws_freeVec(v)


def test_sws_test_frame() raises:
    var frame = avutil.av_frame_alloc()
    frame[].width = 640
    frame[].height = 480
    frame[].format = AVPixelFormat.AV_PIX_FMT_YUV420P._value
    var ret = avutil.av_frame_get_buffer(frame, 0)
    assert_equal(ret, 0)
    var test_ret = sws.sws_test_frame(frame.as_immutable(), 0)
    assert_true(test_ret >= 0)
    var _ptr = alloc[UnsafePointer[AVFrame, MutExternalOrigin]](1)
    _ptr[] = frame
    avutil.av_frame_free(_ptr)
    _ptr.free()


def test_sws_scale_frame() raises:
    var src = avutil.av_frame_alloc()
    src[].width = 640
    src[].height = 480
    src[].format = AVPixelFormat.AV_PIX_FMT_YUV420P._value
    var ret1 = avutil.av_frame_get_buffer(src, 0)
    assert_equal(ret1, 0)
    memset(src[].data[0], 0, Int(src[].linesize[0]) * Int(src[].height))
    memset(src[].data[1], 0, Int(src[].linesize[1]) * (Int(src[].height) // 2))
    memset(src[].data[2], 0, Int(src[].linesize[2]) * (Int(src[].height) // 2))
    var dst = avutil.av_frame_alloc()
    dst[].width = 320
    dst[].height = 240
    dst[].format = AVPixelFormat.AV_PIX_FMT_YUV420P._value
    var ret2 = avutil.av_frame_get_buffer(dst, 0)
    assert_equal(ret2, 0)
    var ctx = sws.sws_getContext(
        640,
        480,
        AVPixelFormat.AV_PIX_FMT_YUV420P._value,
        320,
        240,
        AVPixelFormat.AV_PIX_FMT_YUV420P._value,
        0,
        UnsafePointer[SwsFilter, MutExternalOrigin](unsafe_from_address=0),
        UnsafePointer[SwsFilter, MutExternalOrigin](unsafe_from_address=0),
        UnsafePointer[c_double, ImmutExternalOrigin](unsafe_from_address=0),
    )
    assert_true(Bool(ctx))
    var scale_ret = sws.sws_scale_frame(
        ctx,
        dst,
        src.as_immutable(),
    )
    assert_equal(scale_ret, 240)
    sws.sws_freeContext(ctx)
    var _ptr = alloc[UnsafePointer[AVFrame, MutExternalOrigin]](1)
    _ptr[] = src
    avutil.av_frame_free(_ptr)
    _ptr.free()
    _ptr = alloc[UnsafePointer[AVFrame, MutExternalOrigin]](1)
    _ptr[] = dst
    avutil.av_frame_free(_ptr)
    _ptr.free()


def test_sws_scale() raises:
    var src_frame = avutil.av_frame_alloc()
    src_frame[].width = 64
    src_frame[].height = 48
    src_frame[].format = AVPixelFormat.AV_PIX_FMT_YUV420P._value
    var ret1 = avutil.av_frame_get_buffer(src_frame, 0)
    assert_equal(ret1, 0)
    memset(
        src_frame[].data[0],
        0,
        Int(src_frame[].linesize[0]) * Int(src_frame[].height),
    )
    memset(
        src_frame[].data[1],
        0,
        Int(src_frame[].linesize[1]) * (Int(src_frame[].height) // 2),
    )
    memset(
        src_frame[].data[2],
        0,
        Int(src_frame[].linesize[2]) * (Int(src_frame[].height) // 2),
    )
    var dst_frame = avutil.av_frame_alloc()
    dst_frame[].width = 32
    dst_frame[].height = 24
    dst_frame[].format = AVPixelFormat.AV_PIX_FMT_YUV420P._value
    var ret2 = avutil.av_frame_get_buffer(dst_frame, 0)
    assert_equal(ret2, 0)
    var ctx = sws.sws_getContext(
        64,
        48,
        AVPixelFormat.AV_PIX_FMT_YUV420P._value,
        32,
        24,
        AVPixelFormat.AV_PIX_FMT_YUV420P._value,
        0,
        UnsafePointer[SwsFilter, MutExternalOrigin](unsafe_from_address=0),
        UnsafePointer[SwsFilter, MutExternalOrigin](unsafe_from_address=0),
        UnsafePointer[c_double, ImmutExternalOrigin](unsafe_from_address=0),
    )
    assert_true(Bool(ctx))
    var src_slice = alloc[UnsafePointer[c_uchar, ImmutExternalOrigin]](8)
    for i in range(8):
        src_slice[i] = src_frame[].data[i].as_immutable()
    var dst_slice = alloc[UnsafePointer[c_uchar, MutExternalOrigin]](8)
    for i in range(8):
        dst_slice[i] = dst_frame[].data[i]
    var scale_ret = sws.sws_scale(
        ctx,
        src_slice.as_immutable(),
        src_frame[].linesize.unsafe_ptr().as_immutable(),
        0,
        48,
        dst_slice,
        dst_frame[].linesize.unsafe_ptr().as_immutable(),
    )
    assert_equal(scale_ret, 24)
    sws.sws_freeContext(ctx)
    src_slice.free()
    dst_slice.free()
    var _ptr = alloc[UnsafePointer[AVFrame, MutExternalOrigin]](1)
    _ptr[] = src_frame
    avutil.av_frame_free(_ptr)
    _ptr.free()
    _ptr = alloc[UnsafePointer[AVFrame, MutExternalOrigin]](1)
    _ptr[] = dst_frame
    avutil.av_frame_free(_ptr)
    _ptr.free()


def test_sws_is_noop() raises:
    var src = avutil.av_frame_alloc()
    src[].width = 64
    src[].height = 48
    src[].format = AVPixelFormat.AV_PIX_FMT_YUV420P._value
    _ = avutil.av_frame_get_buffer(src, 0)
    var dst = avutil.av_frame_alloc()
    dst[].width = 64
    dst[].height = 48
    dst[].format = AVPixelFormat.AV_PIX_FMT_YUV420P._value
    _ = avutil.av_frame_get_buffer(dst, 0)
    var noop = sws.sws_is_noop(
        dst.as_immutable(),
        src.as_immutable(),
    )
    assert_equal(noop, 1)
    var _ptr = alloc[UnsafePointer[AVFrame, MutExternalOrigin]](1)
    _ptr[] = src
    avutil.av_frame_free(_ptr)
    _ptr.free()
    _ptr = alloc[UnsafePointer[AVFrame, MutExternalOrigin]](1)
    _ptr[] = dst
    avutil.av_frame_free(_ptr)
    _ptr.free()


def test_sws_frame_setup() raises:
    var ctx = sws.sws_getContext(
        64,
        48,
        AVPixelFormat.AV_PIX_FMT_YUV420P._value,
        32,
        24,
        AVPixelFormat.AV_PIX_FMT_YUV420P._value,
        0,
        UnsafePointer[SwsFilter, MutExternalOrigin](unsafe_from_address=0),
        UnsafePointer[SwsFilter, MutExternalOrigin](unsafe_from_address=0),
        UnsafePointer[c_double, ImmutExternalOrigin](unsafe_from_address=0),
    )
    assert_true(Bool(ctx))
    var src = avutil.av_frame_alloc()
    src[].width = 64
    src[].height = 48
    src[].format = AVPixelFormat.AV_PIX_FMT_YUV420P._value
    _ = avutil.av_frame_get_buffer(src, 0)
    var dst = avutil.av_frame_alloc()
    dst[].width = 32
    dst[].height = 24
    dst[].format = AVPixelFormat.AV_PIX_FMT_YUV420P._value
    _ = avutil.av_frame_get_buffer(dst, 0)
    var ret = sws.sws_frame_setup(
        ctx,
        dst.as_immutable(),
        src.as_immutable(),
    )
    assert_equal(ret, 0)
    sws.sws_freeContext(ctx)
    var _ptr = alloc[UnsafePointer[AVFrame, MutExternalOrigin]](1)
    _ptr[] = src
    avutil.av_frame_free(_ptr)
    _ptr.free()
    _ptr = alloc[UnsafePointer[AVFrame, MutExternalOrigin]](1)
    _ptr[] = dst
    avutil.av_frame_free(_ptr)
    _ptr.free()


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
    # test_swscale_version()
    # test_swscale_configuration()
    # test_swscale_license()
    # test_s
    # test_sws_get_class()
    # test_sws_test_format()
    # test_sws_test_colorspace()
    # test_sws_test_primaries()
    # test_sws_test_transfer()
    # test_sws_isSupportedInput()
    # test_sws_isSupportedOutput()
    # test_sws_isSupportedEndiannessConversion()
    # test_sws_getCoefficients()
    # test_sws_getContext_and_free()
    # test_sws_getDefaultFilter_and_free()
    # test_sws_allocVec_and_free()
    # test_sws_getGaussianVec()
    # test_sws_scaleVec()
    # test_sws_normalizeVec()
    # test_sws_test_frame()
    # test_sws_scale_frame()
    # test_sws_scale()
    # test_sws_is_noop()
    # test_sws_frame_setup()
