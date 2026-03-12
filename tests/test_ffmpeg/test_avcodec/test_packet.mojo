from std.testing import TestSuite, assert_equal, assert_true
from std.memory import alloc, memset
from std.ffi import c_uchar, c_int, c_char, c_size_t

from mav.ffmpeg import avcodec
from mav.ffmpeg.avcodec.packet import (
    AVPacket,
    AVPacketSideDataType,
    AVContainerFifo,
)
from mav.ffmpeg.avutil.rational import AVRational
from mav.ffmpeg.avutil.dict import AVDictionary


def test_av_packet_alloc() raises:
    var packet = avcodec.av_packet_alloc()
    assert_true(Bool(packet))
    var pkt_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    pkt_ptr[0] = packet
    avcodec.av_packet_free(pkt_ptr)


def test_av_packet_clone() raises:
    var src = avcodec.av_packet_alloc()
    assert_true(Bool(src))
    var ret = avcodec.av_new_packet(src, 64)
    assert_equal(ret, 0)
    var clone = avcodec.av_packet_clone(src.as_immutable())
    assert_true(Bool(clone))
    assert_equal(clone[].size, 64)
    var src_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    src_ptr[0] = src
    avcodec.av_packet_free(src_ptr)
    var clone_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    clone_ptr[0] = clone
    avcodec.av_packet_free(clone_ptr)


def test_av_packet_free() raises:
    var packet = avcodec.av_packet_alloc()
    var pkt_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    pkt_ptr[0] = packet
    avcodec.av_packet_free(pkt_ptr)


def test_av_new_packet() raises:
    var packet = avcodec.av_packet_alloc()
    var ret = avcodec.av_new_packet(packet, 128)
    assert_equal(ret, 0)
    assert_equal(packet[].size, 128)
    assert_true(Bool(packet[].data))
    var pkt_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    pkt_ptr[0] = packet
    avcodec.av_packet_free(pkt_ptr)


def test_av_shrink_packet() raises:
    var packet = avcodec.av_packet_alloc()
    var ret = avcodec.av_new_packet(packet, 64)
    assert_equal(ret, 0)
    avcodec.av_shrink_packet(packet, 32)
    assert_equal(packet[].size, 32)
    var pkt_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    pkt_ptr[0] = packet
    avcodec.av_packet_free(pkt_ptr)


def test_av_grow_packet() raises:
    var packet = avcodec.av_packet_alloc()
    var ret = avcodec.av_new_packet(packet, 32)
    assert_equal(ret, 0)
    ret = avcodec.av_grow_packet(packet, 32)
    assert_equal(ret, 0)
    assert_equal(packet[].size, 64)
    var pkt_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    pkt_ptr[0] = packet
    avcodec.av_packet_free(pkt_ptr)


def test_av_packet_new_side_data() raises:
    var packet = avcodec.av_packet_alloc()
    var ret = avcodec.av_new_packet(packet, 16)
    assert_equal(ret, 0)
    var sd = avcodec.av_packet_new_side_data(
        packet,
        AVPacketSideDataType.AV_PKT_DATA_PALETTE._value,
        256,
    )
    assert_true(Bool(sd))
    assert_equal(packet[].side_data_elems, 1)
    var pkt_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    pkt_ptr[0] = packet
    avcodec.av_packet_free(pkt_ptr)


def test_av_packet_shrink_side_data() raises:
    var packet = avcodec.av_packet_alloc()
    var ret = avcodec.av_new_packet(packet, 16)
    assert_equal(ret, 0)
    var sd = avcodec.av_packet_new_side_data(
        packet,
        AVPacketSideDataType.AV_PKT_DATA_PALETTE._value,
        256,
    )
    assert_true(Bool(sd))
    ret = avcodec.av_packet_shrink_side_data(
        packet,
        AVPacketSideDataType.AV_PKT_DATA_PALETTE._value,
        128,
    )
    assert_equal(ret, 0)
    var pkt_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    pkt_ptr[0] = packet
    avcodec.av_packet_free(pkt_ptr)


def test_av_packet_get_side_data() raises:
    var packet = avcodec.av_packet_alloc()
    var ret = avcodec.av_new_packet(packet, 16)
    assert_equal(ret, 0)
    var sd = avcodec.av_packet_new_side_data(
        packet,
        AVPacketSideDataType.AV_PKT_DATA_PALETTE._value,
        4,
    )
    assert_true(Bool(sd))
    var size_out = alloc[c_size_t](1)
    size_out[0] = 0
    var got = avcodec.av_packet_get_side_data(
        packet.as_immutable(),
        AVPacketSideDataType.AV_PKT_DATA_PALETTE._value,
        size_out.unsafe_origin_cast[MutExternalOrigin](),
    )
    assert_true(Bool(got))
    assert_equal(size_out[], 4)
    var pkt_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    pkt_ptr[0] = packet
    avcodec.av_packet_free(pkt_ptr)


def test_av_packet_pack_dictionary() raises:
    var size_out = alloc[c_size_t](1)
    size_out[0] = 0
    var data = avcodec.av_packet_pack_dictionary(
        UnsafePointer[AVDictionary, ImmutExternalOrigin](unsafe_from_address=0),
        size_out.unsafe_origin_cast[MutExternalOrigin](),
    )
    assert_equal(Bool(data), False)
    assert_equal(size_out[], 0)


def test_av_packet_unpack_dictionary() raises:
    var dict_ptr = alloc[AVDictionary](0)
    var dict_ptr_ptr = alloc[UnsafePointer[AVDictionary, MutExternalOrigin]](1)
    dict_ptr_ptr[] = dict_ptr

    var ret = avcodec.av_packet_unpack_dictionary(
        UnsafePointer[c_uchar, ImmutExternalOrigin](unsafe_from_address=0),
        c_size_t(0),
        dict_ptr_ptr,
    )
    assert_equal(ret, 0)


def test_av_packet_free_side_data() raises:
    var packet = avcodec.av_packet_alloc()
    var ret = avcodec.av_new_packet(packet, 16)
    assert_equal(ret, 0)
    var sd = avcodec.av_packet_new_side_data(
        packet,
        AVPacketSideDataType.AV_PKT_DATA_PALETTE._value,
        4,
    )
    assert_true(Bool(sd))
    avcodec.av_packet_free_side_data(packet)
    assert_equal(packet[].side_data_elems, 0)
    var pkt_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    pkt_ptr[0] = packet
    avcodec.av_packet_free(pkt_ptr)


def test_av_packet_ref() raises:
    var src = avcodec.av_packet_alloc()
    var ret = avcodec.av_new_packet(src, 32)
    assert_equal(ret, 0)
    var dst = avcodec.av_packet_alloc()
    ret = avcodec.av_packet_ref(dst, src.as_immutable())
    assert_equal(ret, 0)
    assert_equal(dst[].size, 32)
    avcodec.av_packet_unref(src)
    avcodec.av_packet_unref(dst)
    var src_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    src_ptr[0] = src
    avcodec.av_packet_free(src_ptr)
    var dst_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    dst_ptr[0] = dst
    avcodec.av_packet_free(dst_ptr)


def test_av_packet_unref() raises:
    var packet = avcodec.av_packet_alloc()
    var ret = avcodec.av_new_packet(packet, 32)
    assert_equal(ret, 0)
    avcodec.av_packet_unref(packet)
    var pkt_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    pkt_ptr[0] = packet
    avcodec.av_packet_free(pkt_ptr)


def test_av_packet_move_ref() raises:
    var src = avcodec.av_packet_alloc()
    var ret = avcodec.av_new_packet(src, 32)
    assert_equal(ret, 0)
    var dst = avcodec.av_packet_alloc()
    avcodec.av_packet_move_ref(dst, src)
    assert_equal(dst[].size, 32)
    assert_equal(src[].size, 0)
    var src_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    src_ptr[0] = src
    avcodec.av_packet_free(src_ptr)
    var dst_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    dst_ptr[0] = dst
    avcodec.av_packet_free(dst_ptr)


def test_av_packet_copy_props() raises:
    var src = avcodec.av_packet_alloc()
    var ret = avcodec.av_new_packet(src, 32)
    assert_equal(ret, 0)
    src[].pts = 100
    src[].dts = 90
    src[].duration = 10
    src[].stream_index = 1
    var dst = avcodec.av_packet_alloc()
    ret = avcodec.av_packet_copy_props(
        dst,
        src.as_immutable(),
    )
    assert_equal(ret, 0)
    assert_equal(dst[].pts, 100)
    assert_equal(dst[].dts, 90)
    assert_equal(dst[].duration, 10)
    assert_equal(dst[].stream_index, 1)
    var src_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    src_ptr[0] = src
    avcodec.av_packet_free(src_ptr)
    var dst_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    dst_ptr[0] = dst
    avcodec.av_packet_free(dst_ptr)


def test_av_packet_make_refcounted() raises:
    var packet = avcodec.av_packet_alloc()
    var ret = avcodec.av_new_packet(packet, 32)
    assert_equal(ret, 0)
    ret = avcodec.av_packet_make_refcounted(packet)
    assert_equal(ret, 0)
    var pkt_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    pkt_ptr[0] = packet
    avcodec.av_packet_free(pkt_ptr)


def test_av_packet_make_writable() raises:
    var packet = avcodec.av_packet_alloc()
    var ret = avcodec.av_new_packet(packet, 32)
    assert_equal(ret, 0)
    ret = avcodec.av_packet_make_writable(packet)
    assert_equal(ret, 0)
    var pkt_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    pkt_ptr[0] = packet
    avcodec.av_packet_free(pkt_ptr)


def test_av_packet_rescale_ts() raises:
    var packet = avcodec.av_packet_alloc()
    var ret = avcodec.av_new_packet(packet, 32)
    assert_equal(ret, 0)
    packet[].pts = 0
    packet[].dts = 0
    packet[].duration = 25
    avcodec.av_packet_rescale_ts(
        packet,
        AVRational(num=1, den=25),
        AVRational(num=1, den=12800),
    )
    _ = packet[].pts
    _ = packet[].dts
    _ = packet[].duration
    var pkt_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    pkt_ptr[0] = packet
    avcodec.av_packet_free(pkt_ptr)


def test_av_container_fifo_alloc_avpacket() raises:
    var fifo = avcodec.av_container_fifo_alloc_avpacket(0)
    assert_true(Bool(fifo))
    var fifo_ptr = alloc[UnsafePointer[AVContainerFifo, MutExternalOrigin]](1)
    fifo_ptr[0] = fifo
    avcodec.av_container_fifo_free(fifo_ptr)
    fifo_ptr.free()


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
