from std.testing import TestSuite, assert_equal, assert_true
from std.memory import memset, alloc
from std.ffi import c_uchar, c_int, c_char, external_call
from std.sys._libc_errno import ErrNo
from mav.ffmpeg.avutil.pixfmt import AVPixelFormat

from mav.ffmpeg.avutil.frame import (
    AVFrame,
    AVFrameSideData,
    AVFrameSideDataType,
)
from mav.ffmpeg.avutil.buffer import AVBufferRef
from mav.ffmpeg import avutil


def test_av_frame_alloc() raises:
    var frame = avutil.av_frame_alloc()
    assert_equal(frame[].width, 0)
    assert_equal(frame[].height, 0)
    assert_equal(frame[].format, -1)
    assert_equal(frame[].nb_samples, 0)
    assert_equal(frame[].nb_side_data, 0)
    assert_equal(frame[].flags, 0)

    fn accept_frame(frame: UnsafePointer[AVFrame, MutExternalOrigin]) raises:
        "Test whether frame survives being passed by reference."
        assert_equal(frame[].width, 0)

    accept_frame(frame)
    assert_equal(frame[].flags, 0)
    avutil.av_frame_free(frame)


def test_av_frame_free() raises:
    var frame_ptr = alloc[UnsafePointer[AVFrame, MutExternalOrigin]](1)
    frame_ptr[] = avutil.av_frame_alloc()
    avutil.av_frame_free(frame_ptr)
    frame_ptr.free()


def test_av_frame_ref() raises:
    var src = avutil.av_frame_alloc()
    var dst = avutil.av_frame_alloc()
    memset(dst, 0, 1)
    src[].width = 640
    src[].height = 480
    src[].format = AVPixelFormat.AV_PIX_FMT_YUV420P._value
    var ret1 = avutil.av_frame_get_buffer(src, 0)
    assert_equal(ret1, 0)
    var immut_ptr = src
    var ret2 = avutil.av_frame_ref(
        dst,
        immut_ptr,
    )
    assert_equal(ret2, 0)
    assert_equal(dst[].width, 640)
    assert_equal(dst[].height, 480)
    avutil.av_frame_unref(dst)
    avutil.av_frame_free(src)
    avutil.av_frame_free(dst)


def test_av_frame_replace() raises:
    var src = avutil.av_frame_alloc()
    var dst = avutil.av_frame_alloc()
    src[].width = 320
    src[].height = 240
    var ret = avutil.av_frame_replace(
        dst,
        src,
    )
    assert_equal(ret, 0)
    assert_equal(dst[].width, 320)
    assert_equal(dst[].height, 240)
    avutil.av_frame_free(src)
    avutil.av_frame_free(dst)


def test_av_frame_clone() raises:
    var src = avutil.av_frame_alloc()
    src[].width = 1280
    src[].height = 720
    src[].format = AVPixelFormat.AV_PIX_FMT_YUV420P._value
    _ = avutil.av_frame_get_buffer(src, 0)
    var clone = avutil.av_frame_clone(src)
    assert_true(Bool(clone))
    assert_equal(clone[].width, 1280)
    assert_equal(clone[].height, 720)
    avutil.av_frame_free(src)
    var clone_ptr = alloc[UnsafePointer[AVFrame, MutExternalOrigin]](1)
    clone_ptr[] = clone
    avutil.av_frame_free(clone_ptr)
    clone_ptr.free()


def test_av_frame_unref() raises:
    var frame = avutil.av_frame_alloc()
    frame[].width = 100
    avutil.av_frame_unref(frame)
    assert_equal(frame[].width, 0)
    avutil.av_frame_free(frame)


def test_av_frame_move_ref() raises:
    var src = avutil.av_frame_alloc()
    var dst = avutil.av_frame_alloc()
    src[].width = 800
    src[].height = 600
    avutil.av_frame_move_ref(
        dst,
        src,
    )
    assert_equal(dst[].width, 800)
    assert_equal(dst[].height, 600)
    assert_equal(src[].width, 0)
    avutil.av_frame_free(src)
    avutil.av_frame_free(dst)


def test_av_frame_get_buffer() raises:
    var frame = avutil.av_frame_alloc()
    frame[].width = 64
    frame[].height = 64
    frame[].format = AVPixelFormat.AV_PIX_FMT_YUV420P._value

    # Side data should be null before buffer init (av_frame_alloc zeroes the frame)
    assert_equal(frame[].nb_side_data, 0)
    assert_true(not Bool(frame[].side_data))

    var ret = avutil.av_frame_get_buffer(frame, 0)
    assert_equal(ret, 0)

    # Input fields should be unchanged
    assert_equal(frame[].width, 64)
    assert_equal(frame[].height, 64)
    assert_equal(frame[].format, AVPixelFormat.AV_PIX_FMT_YUV420P._value)

    # YUV420P has 3 planes; data and buf should be populated for each
    assert_true(Bool(frame[].data[0]))
    assert_true(Bool(frame[].data[1]))
    assert_true(Bool(frame[].data[2]))
    assert_true(Bool(frame[].buf[0]))

    # extended_data should point to the data array
    assert_true(Bool(frame[].extended_data))

    # linesize should be set for each plane (Y=64, U/V=32 for 64x64)
    assert_true(frame[].linesize[0] >= 64)
    assert_true(frame[].linesize[1] >= 32)
    assert_true(frame[].linesize[2] >= 32)

    # Side data should stay null after buffer init; if corrupted, av_frame_free will crash
    assert_equal(frame[].nb_side_data, 0)
    assert_true(not Bool(frame[].side_data))
    avutil.av_frame_free(frame)


def test_av_frame_is_writable() raises:
    var frame = avutil.av_frame_alloc()
    # A frame without a buffer is not writable.
    assert_equal(
        avutil.av_frame_is_writable(frame),
        0,
    )
    avutil.av_frame_free(frame)


def test_av_frame_make_writable() raises:
    var frame = avutil.av_frame_alloc()
    frame[].width = 64
    frame[].height = 64
    frame[].format = 0  # AV_PIX_FMT_YUV420P
    _ = avutil.av_frame_get_buffer(frame, 0)
    var ret = avutil.av_frame_make_writable(frame)
    assert_equal(ret, 0)
    assert_equal(
        avutil.av_frame_is_writable(frame),
        1,
    )
    avutil.av_frame_free(frame)


def test_av_frame_copy() raises:
    var src = avutil.av_frame_alloc()
    var dst = avutil.av_frame_alloc()
    src[].width = 64
    src[].height = 64
    src[].format = 0  # AV_PIX_FMT_YUV420P
    dst[].width = 64
    dst[].height = 64
    dst[].format = 0
    _ = avutil.av_frame_get_buffer(src, 0)
    _ = avutil.av_frame_get_buffer(dst, 0)
    var ret = avutil.av_frame_copy(
        dst,
        src,
    )
    assert_equal(ret, 0)
    avutil.av_frame_free(src)
    avutil.av_frame_free(dst)


def test_av_frame_copy_props() raises:
    var src = avutil.av_frame_alloc()
    var dst = avutil.av_frame_alloc()
    src[].pts = 42
    src[].flags = 1
    var ret = avutil.av_frame_copy_props(
        dst,
        src,
    )
    assert_equal(ret, 0)
    assert_equal(dst[].pts, 42)
    assert_equal(dst[].flags, 1)
    avutil.av_frame_free(src)
    avutil.av_frame_free(dst)


def test_av_frame_get_plane_buffer() raises:
    var frame = avutil.av_frame_alloc()
    frame[].width = 64
    frame[].height = 64
    frame[].format = 0  # AV_PIX_FMT_YUV420P
    _ = avutil.av_frame_get_buffer(frame, 0)
    var buf = avutil.av_frame_get_plane_buffer(frame, 0)
    assert_true(Bool(buf))
    avutil.av_frame_free(frame)


def test_av_frame_new_side_data() raises:
    var frame = avutil.av_frame_alloc()
    var sd = avutil.av_frame_new_side_data(
        frame,
        AVFrameSideDataType.AV_FRAME_DATA_REPLAYGAIN._value,
        128,
    )
    assert_true(Bool(sd))
    assert_equal(frame[].nb_side_data, 1)
    avutil.av_frame_free(frame)


def test_av_frame_new_side_data_from_buf() raises:
    var frame = avutil.av_frame_alloc()
    var buf = avutil.av_buffer_alloc(128)
    var sd = avutil.av_frame_new_side_data_from_buf(
        frame,
        AVFrameSideDataType.AV_FRAME_DATA_REPLAYGAIN._value,
        buf,
    )
    assert_true(Bool(sd))
    assert_equal(frame[].nb_side_data, 1)
    avutil.av_frame_free(frame)


def test_av_frame_get_side_data() raises:
    var frame = avutil.av_frame_alloc()
    _ = avutil.av_frame_new_side_data(
        frame,
        AVFrameSideDataType.AV_FRAME_DATA_REPLAYGAIN._value,
        128,
    )
    var sd = avutil.av_frame_get_side_data(
        frame,
        AVFrameSideDataType.AV_FRAME_DATA_REPLAYGAIN._value,
    )
    assert_true(Bool(sd))
    avutil.av_frame_free(frame)


def test_av_frame_remove_side_data() raises:
    var frame = avutil.av_frame_alloc()
    _ = avutil.av_frame_new_side_data(
        frame,
        AVFrameSideDataType.AV_FRAME_DATA_REPLAYGAIN._value,
        128,
    )
    assert_equal(frame[].nb_side_data, 1)
    avutil.av_frame_remove_side_data(
        frame,
        AVFrameSideDataType.AV_FRAME_DATA_REPLAYGAIN._value,
    )
    assert_equal(frame[].nb_side_data, 0)
    avutil.av_frame_free(frame)


def test_av_frame_apply_cropping() raises:
    var frame = avutil.av_frame_alloc()
    frame[].width = 64
    frame[].height = 64
    frame[].format = 0  # AV_PIX_FMT_YUV420P
    _ = avutil.av_frame_get_buffer(frame, 0)
    frame[].crop_top = 8
    frame[].crop_bottom = 8
    frame[].crop_left = 8
    frame[].crop_right = 8
    var ret = avutil.av_frame_apply_cropping(frame, 0)
    if ret != 0:
        print(
            "av_frame_apply_cropping error: {}".format(avutil.av_err2str(ret))
        )
    assert_equal(ret, 0)
    avutil.av_frame_free(frame)


def test_av_frame_side_data_name() raises:
    var name = avutil.av_frame_side_data_name(
        AVFrameSideDataType.AV_FRAME_DATA_PANSCAN._value
    )
    assert_true(Bool(name))


def test_av_frame_side_data_desc() raises:
    var desc = avutil.av_frame_side_data_desc(
        AVFrameSideDataType.AV_FRAME_DATA_PANSCAN._value
    )
    assert_true(Bool(desc))


def test_av_frame_side_data_free() raises:
    var sd = AVFrameSideData.alloc_triple_ptr()
    var nb_sd = alloc[c_int](1)
    nb_sd[] = 0
    var entry = avutil.av_frame_side_data_new(
        sd,
        nb_sd,
        AVFrameSideDataType.AV_FRAME_DATA_REPLAYGAIN._value,
        128,
        0,
    )
    assert_true(Bool(entry))
    assert_equal(nb_sd[], 1)
    avutil.av_frame_side_data_free(
        sd,
        nb_sd,
    )
    assert_equal(nb_sd[], 0)
    avutil.av_freep(sd)
    # nb_sd.free()


def test_av_frame_side_data_new() raises:
    var sd = AVFrameSideData.alloc_triple_ptr()

    var nb_sd = alloc[c_int](1)
    nb_sd[] = 0
    var entry = avutil.av_frame_side_data_new(
        sd,
        nb_sd,
        AVFrameSideDataType.AV_FRAME_DATA_REPLAYGAIN._value,
        1,
        0,
    )
    assert_true(Bool(entry))
    assert_equal(nb_sd[], 1)
    avutil.av_frame_side_data_free(
        sd,
        nb_sd,
    )
    assert_equal(nb_sd[], 0)


def test_av_frame_side_data_add() raises:
    var sd = AVFrameSideData.alloc_triple_ptr()
    var nb_sd = alloc[c_int](1)
    nb_sd[] = 0
    var buf_ptr = alloc[UnsafePointer[AVBufferRef, MutExternalOrigin]](1)
    buf_ptr[] = avutil.av_buffer_alloc(128)
    var entry = avutil.av_frame_side_data_add(
        sd,
        nb_sd,
        AVFrameSideDataType.AV_FRAME_DATA_REPLAYGAIN._value,
        buf_ptr,
        0,
    )
    assert_true(Bool(entry))
    assert_equal(nb_sd[], 1)
    avutil.av_freep(buf_ptr)
    avutil.av_frame_side_data_free(sd, nb_sd)


def test_av_frame_side_data_clone() raises:
    var src_sd = AVFrameSideData.alloc_triple_ptr()
    var src_nb_sd = alloc[c_int](1)
    src_nb_sd[] = 0
    var src_entry = avutil.av_frame_side_data_new(
        src_sd,
        src_nb_sd,
        AVFrameSideDataType.AV_FRAME_DATA_REPLAYGAIN._value,
        1,
        0,
    )
    assert_true(Bool(src_entry))
    assert_equal(src_nb_sd[], 1)
    var dst_sd = AVFrameSideData.alloc_triple_ptr()
    var dst_nb_sd = alloc[c_int](1)
    dst_nb_sd[] = 0
    var ret = avutil.av_frame_side_data_clone(
        dst_sd,
        dst_nb_sd,
        src_entry.as_immutable(),
        0,
    )
    assert_equal(ret, 0)
    assert_equal(dst_nb_sd[], 1)
    avutil.av_frame_side_data_free(dst_sd, dst_nb_sd)
    avutil.av_frame_side_data_free(
        src_sd,
        src_nb_sd,
    )


def test_av_frame_side_data_get_c() raises:
    var sd = AVFrameSideData.alloc_triple_ptr()
    var nb_sd = alloc[c_int](1)
    nb_sd[] = 0
    var entry = avutil.av_frame_side_data_new(
        sd,
        nb_sd,
        AVFrameSideDataType.AV_FRAME_DATA_REPLAYGAIN._value,
        128,
        0,
    )
    assert_true(Bool(entry))
    assert_equal(nb_sd[], 1)

    var found = avutil.av_frame_side_data_get_c(
        sd[].bitcast[UnsafePointer[AVFrameSideData, ImmutExternalOrigin]](),
        nb_sd[],
        AVFrameSideDataType.AV_FRAME_DATA_REPLAYGAIN._value,
    )
    assert_true(Bool(found))
    avutil.av_frame_side_data_free(
        sd,
        nb_sd,
    )


def test_av_frame_side_data_remove() raises:
    var sd = AVFrameSideData.alloc_triple_ptr()
    var nb_sd = alloc[c_int](1)
    nb_sd[] = 0
    var entry = avutil.av_frame_side_data_new(
        sd,
        nb_sd,
        AVFrameSideDataType.AV_FRAME_DATA_REPLAYGAIN._value,
        128,
        0,
    )
    assert_true(Bool(entry))
    assert_equal(nb_sd[], 1)
    avutil.av_frame_side_data_remove(
        sd,
        nb_sd,
        AVFrameSideDataType.AV_FRAME_DATA_REPLAYGAIN._value,
    )
    assert_equal(nb_sd[], 0)
    avutil.av_freep(sd)


def test_av_frame_side_data_remove_by_props() raises:
    var sd = AVFrameSideData.alloc_triple_ptr()
    var nb_sd = alloc[c_int](1)
    nb_sd[] = 0
    var type = AVFrameSideDataType.AV_FRAME_DATA_REPLAYGAIN._value
    var entry = avutil.av_frame_side_data_new(
        sd,
        nb_sd,
        type,
        128,
        0,
    )
    assert_true(Bool(entry))
    assert_equal(nb_sd[], 1)
    # AV_FRAME_DATA_REPLAYGAIN has AV_SIDE_DATA_PROP_GLOBAL; removing by its
    # own props should free the entry and reset nb_sd to 0.
    var desc = avutil.av_frame_side_data_desc(type)
    avutil.av_frame_side_data_remove_by_props(
        sd,
        nb_sd,
        desc[].props,
    )
    assert_equal(nb_sd[], 0)
    avutil.av_freep(sd)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()

    # test_av_frame_alloc()
    # test_av_frame_free()
    # test_av_frame_ref()
    # test_av_frame_replace()
    # test_av_frame_clone()
    # test_av_frame_unref()
    # test_av_frame_move_ref()
    # test_av_frame_get_buffer()
    # test_av_frame_is_writable()
    # test_av_frame_make_writable()
    # test_av_frame_copy()
    # test_av_frame_copy_props()
    # test_av_frame_get_plane_buffer()
    # test_av_frame_new_side_data()
    # test_av_frame_new_side_data_from_buf()
    # test_av_frame_get_side_data()
    # test_av_frame_remove_side_data()
    # test_av_frame_side_data_name()
    # test_av_frame_side_data_desc()
    # test_av_frame_apply_cropping()
    # test_av_frame_side_data_new()
    # test_av_frame_side_data_add()
    # test_av_frame_side_data_free()
    # test_av_frame_side_data_clone()
    # test_av_frame_side_data_get_c()
    # test_av_frame_side_data_remove()
    # test_av_frame_side_data_remove_by_props()
