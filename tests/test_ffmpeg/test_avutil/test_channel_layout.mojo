from std.testing import TestSuite, assert_true, assert_equal
from std.memory import alloc, memset
from std.ffi import c_char, c_int, c_size_t, c_ulong_long
from mav.ffmpeg.avutil.channel_layout import (
    AVChannel,
    AVChannelLayout,
    AVChannelOrder,
    AV_CH_LAYOUT_STEREO,
)
from mav.ffmpeg import avutil


def test_av_channel_name() raises:
    var buf = alloc[c_char](64)
    var ret = avutil.av_channel_name(
        buf.unsafe_origin_cast[MutExternalOrigin](),
        64,
        AVChannel.AV_CHAN_FRONT_LEFT._value,
    )
    assert_true(ret >= 0)


def test_av_channel_description() raises:
    var buf = alloc[c_char](64)
    var ret = avutil.av_channel_description(
        buf.unsafe_origin_cast[MutExternalOrigin](),
        64,
        AVChannel.AV_CHAN_FRONT_LEFT._value,
    )
    assert_true(ret >= 0)


def test_av_channel_from_string() raises:
    var ch = avutil.av_channel_from_string(
        "FL".as_c_string_slice()
        .unsafe_ptr()
        .as_immutable()
        .unsafe_origin_cast[ImmutExternalOrigin]()
    )
    assert_equal(Int(ch), Int(AVChannel.AV_CHAN_FRONT_LEFT._value))


def test_av_channel_layout_custom_init() raises:
    var layout = alloc[AVChannelLayout](1)
    memset(layout, 0, 1)
    var ret = avutil.av_channel_layout_custom_init(
        layout.unsafe_origin_cast[MutExternalOrigin](),
        2,
    )
    assert_equal(ret, 0)
    avutil.av_channel_layout_uninit(
        layout.unsafe_origin_cast[MutExternalOrigin]()
    )


def test_av_channel_layout_from_mask() raises:
    var layout = alloc[AVChannelLayout](1)
    memset(layout, 0, 1)
    var ret = avutil.av_channel_layout_from_mask(
        layout.unsafe_origin_cast[MutExternalOrigin](),
        AV_CH_LAYOUT_STEREO,
    )
    assert_equal(ret, 0)
    assert_equal(layout[].nb_channels, 2)
    avutil.av_channel_layout_uninit(
        layout.unsafe_origin_cast[MutExternalOrigin]()
    )


def test_av_channel_layout_from_string() raises:
    var layout = alloc[AVChannelLayout](1)
    memset(layout, 0, 1)
    var ret = avutil.av_channel_layout_from_string(
        layout.unsafe_origin_cast[MutExternalOrigin](),
        "stereo".as_c_string_slice()
        .unsafe_ptr()
        .as_immutable()
        .unsafe_origin_cast[ImmutExternalOrigin](),
    )
    assert_equal(ret, 0)
    assert_equal(layout[].nb_channels, 2)
    avutil.av_channel_layout_uninit(
        layout.unsafe_origin_cast[MutExternalOrigin]()
    )


def test_av_channel_layout_default() raises:
    var layout = alloc[AVChannelLayout](1)
    memset(layout, 0, 1)
    avutil.av_channel_layout_default(
        layout.unsafe_origin_cast[MutExternalOrigin](),
        2,
    )
    avutil.av_channel_layout_uninit(
        layout.unsafe_origin_cast[MutExternalOrigin]()
    )


def test_av_channel_layout_standard() raises:
    var opaque = alloc[OpaquePointer[MutExternalOrigin]](1)
    memset(opaque, 0, 1)
    var layout = avutil.av_channel_layout_standard(
        opaque.unsafe_origin_cast[MutExternalOrigin](),
    )
    assert_true(Bool(layout))


def test_av_channel_layout_uninit() raises:
    var layout = alloc[AVChannelLayout](1)
    memset(layout, 0, 1)
    var ret = avutil.av_channel_layout_from_mask(
        layout.unsafe_origin_cast[MutExternalOrigin](),
        AV_CH_LAYOUT_STEREO,
    )
    assert_equal(ret, 0)
    avutil.av_channel_layout_uninit(
        layout.unsafe_origin_cast[MutExternalOrigin]()
    )


def test_av_channel_layout_copy() raises:
    var src = alloc[AVChannelLayout](1)
    memset(src, 0, 1)
    var ret1 = avutil.av_channel_layout_from_mask(
        src.unsafe_origin_cast[MutExternalOrigin](),
        AV_CH_LAYOUT_STEREO,
    )
    assert_equal(ret1, 0)
    var dst = alloc[AVChannelLayout](1)
    memset(dst, 0, 1)
    var ret2 = avutil.av_channel_layout_copy(
        dst.unsafe_origin_cast[MutExternalOrigin](),
        src.as_immutable().unsafe_origin_cast[ImmutExternalOrigin](),
    )
    assert_equal(ret2, 0)
    assert_equal(dst[].nb_channels, 2)
    avutil.av_channel_layout_uninit(dst.unsafe_origin_cast[MutExternalOrigin]())
    avutil.av_channel_layout_uninit(src.unsafe_origin_cast[MutExternalOrigin]())


def test_av_channel_layout_describe() raises:
    var layout = alloc[AVChannelLayout](1)
    memset(layout, 0, 1)
    var ret1 = avutil.av_channel_layout_from_mask(
        layout.unsafe_origin_cast[MutExternalOrigin](),
        AV_CH_LAYOUT_STEREO,
    )
    assert_equal(ret1, 0)
    var buf = alloc[c_char](64)
    var ret2 = avutil.av_channel_layout_describe(
        layout.as_immutable().unsafe_origin_cast[ImmutExternalOrigin](),
        buf.unsafe_origin_cast[MutExternalOrigin](),
        64,
    )
    assert_true(ret2 >= 0)
    avutil.av_channel_layout_uninit(
        layout.unsafe_origin_cast[MutExternalOrigin]()
    )


def test_av_channel_layout_channel_from_index() raises:
    var layout = alloc[AVChannelLayout](1)
    memset(layout, 0, 1)
    var ret1 = avutil.av_channel_layout_from_mask(
        layout.unsafe_origin_cast[MutExternalOrigin](),
        AV_CH_LAYOUT_STEREO,
    )
    assert_equal(ret1, 0)
    var ch = avutil.av_channel_layout_channel_from_index(
        layout.as_immutable().unsafe_origin_cast[ImmutExternalOrigin](),
        0,
    )
    assert_equal(Int(ch), Int(AVChannel.AV_CHAN_FRONT_LEFT._value))
    avutil.av_channel_layout_uninit(
        layout.unsafe_origin_cast[MutExternalOrigin]()
    )


def test_av_channel_layout_index_from_channel() raises:
    var layout = alloc[AVChannelLayout](1)
    memset(layout, 0, 1)
    var ret1 = avutil.av_channel_layout_from_mask(
        layout.unsafe_origin_cast[MutExternalOrigin](),
        AV_CH_LAYOUT_STEREO,
    )
    assert_equal(ret1, 0)
    var idx = avutil.av_channel_layout_index_from_channel(
        layout.as_immutable().unsafe_origin_cast[ImmutExternalOrigin](),
        AVChannel.AV_CHAN_FRONT_RIGHT._value,
    )
    assert_true(idx >= 0)
    avutil.av_channel_layout_uninit(
        layout.unsafe_origin_cast[MutExternalOrigin]()
    )


def test_av_channel_layout_index_from_string() raises:
    var layout = alloc[AVChannelLayout](1)
    memset(layout, 0, 1)
    var ret1 = avutil.av_channel_layout_from_mask(
        layout.unsafe_origin_cast[MutExternalOrigin](),
        AV_CH_LAYOUT_STEREO,
    )
    assert_equal(ret1, 0)
    var idx = avutil.av_channel_layout_index_from_string(
        layout.as_immutable().unsafe_origin_cast[ImmutExternalOrigin](),
        "FR".as_c_string_slice()
        .unsafe_ptr()
        .as_immutable()
        .unsafe_origin_cast[ImmutExternalOrigin](),
    )
    assert_equal(idx, 1)
    avutil.av_channel_layout_uninit(
        layout.unsafe_origin_cast[MutExternalOrigin]()
    )


def test_av_channel_layout_channel_from_string() raises:
    var layout = alloc[AVChannelLayout](1)
    memset(layout, 0, 1)
    var ret1 = avutil.av_channel_layout_from_mask(
        layout.unsafe_origin_cast[MutExternalOrigin](),
        AV_CH_LAYOUT_STEREO,
    )
    assert_equal(ret1, 0)
    var ch = avutil.av_channel_layout_channel_from_string(
        layout.as_immutable().unsafe_origin_cast[ImmutExternalOrigin](),
        "FR".as_c_string_slice()
        .unsafe_ptr()
        .as_immutable()
        .unsafe_origin_cast[ImmutExternalOrigin](),
    )
    assert_equal(Int(ch), Int(AVChannel.AV_CHAN_FRONT_RIGHT._value))
    avutil.av_channel_layout_uninit(
        layout.unsafe_origin_cast[MutExternalOrigin]()
    )


def test_av_channel_layout_subset() raises:
    var layout = alloc[AVChannelLayout](1)
    memset(layout, 0, 1)
    var ret1 = avutil.av_channel_layout_from_mask(
        layout.unsafe_origin_cast[MutExternalOrigin](),
        AV_CH_LAYOUT_STEREO,
    )
    assert_equal(ret1, 0)
    var mask = avutil.av_channel_layout_subset(
        layout.as_immutable().unsafe_origin_cast[ImmutExternalOrigin](),
        AV_CH_LAYOUT_STEREO,
    )
    assert_equal(Int(mask), Int(AV_CH_LAYOUT_STEREO))
    avutil.av_channel_layout_uninit(
        layout.unsafe_origin_cast[MutExternalOrigin]()
    )


def test_av_channel_layout_check() raises:
    var layout = alloc[AVChannelLayout](1)
    memset(layout, 0, 1)
    var ret1 = avutil.av_channel_layout_from_mask(
        layout.unsafe_origin_cast[MutExternalOrigin](),
        AV_CH_LAYOUT_STEREO,
    )
    assert_equal(ret1, 0)
    var ret2 = avutil.av_channel_layout_check(
        layout.as_immutable().unsafe_origin_cast[ImmutExternalOrigin](),
    )
    assert_true(ret2 >= 0)
    avutil.av_channel_layout_uninit(
        layout.unsafe_origin_cast[MutExternalOrigin]()
    )


def test_av_channel_layout_compare() raises:
    var layout1 = alloc[AVChannelLayout](1)
    var layout2 = alloc[AVChannelLayout](1)
    memset(layout1, 0, 1)
    memset(layout2, 0, 1)
    var ret1 = avutil.av_channel_layout_from_mask(
        layout1.unsafe_origin_cast[MutExternalOrigin](),
        AV_CH_LAYOUT_STEREO,
    )
    var ret2 = avutil.av_channel_layout_from_mask(
        layout2.unsafe_origin_cast[MutExternalOrigin](),
        AV_CH_LAYOUT_STEREO,
    )
    assert_equal(ret1, 0)
    assert_equal(ret2, 0)
    var cmp_ret = avutil.av_channel_layout_compare(
        layout1.as_immutable().unsafe_origin_cast[ImmutExternalOrigin](),
        layout2.as_immutable().unsafe_origin_cast[ImmutExternalOrigin](),
    )
    assert_equal(cmp_ret, 0)
    avutil.av_channel_layout_uninit(
        layout1.unsafe_origin_cast[MutExternalOrigin]()
    )
    avutil.av_channel_layout_uninit(
        layout2.unsafe_origin_cast[MutExternalOrigin]()
    )


def test_av_channel_layout_ambisonic_order() raises:
    # Stereo is not ambisonic; function returns negative AVERROR. Just check no crash.
    var layout = alloc[AVChannelLayout](1)
    memset(layout, 0, 1)
    var ret1 = avutil.av_channel_layout_from_mask(
        layout.unsafe_origin_cast[MutExternalOrigin](),
        AV_CH_LAYOUT_STEREO,
    )
    assert_equal(ret1, 0)
    var order = avutil.av_channel_layout_ambisonic_order(
        layout.as_immutable().unsafe_origin_cast[ImmutExternalOrigin](),
    )
    assert_true(order < 0)
    avutil.av_channel_layout_uninit(
        layout.unsafe_origin_cast[MutExternalOrigin]()
    )


def test_av_channel_layout_retype() raises:
    var layout = alloc[AVChannelLayout](1)
    memset(layout, 0, 1)
    var ret1 = avutil.av_channel_layout_from_mask(
        layout.unsafe_origin_cast[MutExternalOrigin](),
        AV_CH_LAYOUT_STEREO,
    )
    assert_equal(ret1, 0)
    var ret2 = avutil.av_channel_layout_retype(
        layout.unsafe_origin_cast[MutExternalOrigin](),
        AVChannelOrder.AV_CHANNEL_ORDER_NATIVE._value,
        0,
    )
    assert_equal(ret2, 0)
    avutil.av_channel_layout_uninit(
        layout.unsafe_origin_cast[MutExternalOrigin]()
    )


def main() raises:
    # TestSuite.discover_tests[__functions_in_module()]().run()
    test_av_channel_name()
    test_av_channel_description()
    test_av_channel_from_string()
    test_av_channel_layout_custom_init()
    test_av_channel_layout_from_mask()
    test_av_channel_layout_from_string()
    test_av_channel_layout_default()
    test_av_channel_layout_standard()
    test_av_channel_layout_uninit()
    test_av_channel_layout_describe()
    test_av_channel_layout_channel_from_index()
    test_av_channel_layout_index_from_channel()
    test_av_channel_layout_index_from_string()
    test_av_channel_layout_channel_from_string()
    test_av_channel_layout_subset()
    test_av_channel_layout_check()
    test_av_channel_layout_compare()
    test_av_channel_layout_ambisonic_order()
    test_av_channel_layout_retype()
