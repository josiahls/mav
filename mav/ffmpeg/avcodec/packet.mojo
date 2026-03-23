"See https://www.ffmpeg.org/doxygen/8.0/packet_8h.html."
from std.ffi import (
    c_uchar,
    c_uint,
    c_int,
    c_long_long,
    c_size_t,
    c_char,
    external_call,
)
from std.os.atomic import Atomic
from mav.ffmpeg.avutil.buffer import AVBufferRef
from mav.ffmpeg.avutil.rational import AVRational

from mav.ffmpeg.avutil.dict import AVDictionary


@fieldwise_init("implicit")
struct AVPacketSideDataType(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var _value: Self.ENUM_DTYPE

    comptime AV_PKT_DATA_PALETTE = Self(0)
    comptime AV_PKT_DATA_NEW_EXTRADATA = Self(1)
    comptime AV_PKT_DATA_PARAM_CHANGE = Self(2)
    comptime AV_PKT_DATA_H263_MB_INFO = Self(3)
    comptime AV_PKT_DATA_REPLAYGAIN = Self(4)
    comptime AV_PKT_DATA_DISPLAYMATRIX = Self(5)
    comptime AV_PKT_DATA_STEREO3D = Self(6)
    comptime AV_PKT_DATA_AUDIO_SERVICE_TYPE = Self(7)
    comptime AV_PKT_DATA_QUALITY_STATS = Self(8)
    comptime AV_PKT_DATA_FALLBACK_TRACK = Self(9)
    comptime AV_PKT_DATA_CPB_PROPERTIES = Self(10)
    comptime AV_PKT_DATA_SKIP_SAMPLES = Self(11)
    comptime AV_PKT_DATA_JP_DUALMONO = Self(12)
    comptime AV_PKT_DATA_STRINGS_METADATA = Self(13)
    comptime AV_PKT_DATA_SUBTITLE_POSITION = Self(14)
    comptime AV_PKT_DATA_MATROSKA_BLOCKADDITIONAL = Self(15)
    comptime AV_PKT_DATA_WEBVTT_IDENTIFIER = Self(16)

    comptime AV_PKT_DATA_WEBVTT_SETTINGS = Self(17)

    comptime AV_PKT_DATA_METADATA_UPDATE = Self(18)

    comptime AV_PKT_DATA_MPEGTS_STREAM_ID = Self(19)

    comptime AV_PKT_DATA_MASTERING_DISPLAY_METADATA = Self(20)

    comptime AV_PKT_DATA_SPHERICAL = Self(21)

    comptime AV_PKT_DATA_CONTENT_LIGHT_LEVEL = Self(22)

    comptime AV_PKT_DATA_A53_CC = Self(23)

    comptime AV_PKT_DATA_ENCRYPTION_INIT_INFO = Self(24)

    comptime AV_PKT_DATA_ENCRYPTION_INFO = Self(25)

    comptime AV_PKT_DATA_AFD = Self(26)

    comptime AV_PKT_DATA_PRFT = Self(27)

    comptime AV_PKT_DATA_ICC_PROFILE = Self(28)

    comptime AV_PKT_DATA_DOVI_CONF = Self(29)

    comptime AV_PKT_DATA_S12M_TIMECODE = Self(30)

    comptime AV_PKT_DATA_DYNAMIC_HDR10_PLUS = Self(31)

    comptime AV_PKT_DATA_IAMF_MIX_GAIN_PARAM = Self(32)

    comptime AV_PKT_DATA_IAMF_DEMIXING_INFO_PARAM = Self(33)

    comptime AV_PKT_DATA_IAMF_RECON_GAIN_INFO_PARAM = Self(34)

    comptime AV_PKT_DATA_AMBIENT_VIEWING_ENVIRONMENT = Self(35)

    comptime AV_PKT_DATA_FRAME_CROPPING = Self(36)

    comptime AV_PKT_DATA_LCEVC = Self(37)

    comptime AV_PKT_DATA_3D_REFERENCE_DISPLAYS = Self(38)

    comptime AV_PKT_DATA_RTCP_SR = Self(39)

    comptime AV_PKT_DATA_NB = Self(40)


@fieldwise_init
struct AVPacketSideData(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVPacketSideData.html."

    var data: UnsafePointer[c_uchar, MutAnyOrigin]
    var size: c_size_t
    var type: AVPacketSideDataType.ENUM_DTYPE


fn av_packet_side_data_new(
    psd: UnsafePointer[
        UnsafePointer[AVPacketSideData, MutExternalOrigin], MutExternalOrigin
    ],
    pnb_sd: UnsafePointer[c_int, MutExternalOrigin],
    type: AVPacketSideDataType.ENUM_DTYPE,
    size: c_size_t,
    flags: c_int,
) -> UnsafePointer[AVPacketSideData, MutExternalOrigin]:
    return external_call[
        "av_packet_side_data_new",
        UnsafePointer[AVPacketSideData, MutExternalOrigin],
    ](psd, pnb_sd, type, size, flags)


fn av_packet_side_data_add(
    psd: UnsafePointer[
        UnsafePointer[AVPacketSideData, MutExternalOrigin], MutExternalOrigin
    ],
    pnb_sd: UnsafePointer[c_int, MutExternalOrigin],
    type: AVPacketSideDataType.ENUM_DTYPE,
    data: OpaquePointer[MutExternalOrigin],
    size: c_size_t,
    flags: c_int,
) -> UnsafePointer[AVPacketSideData, MutExternalOrigin]:
    return external_call[
        "av_packet_side_data_add",
        UnsafePointer[AVPacketSideData, MutExternalOrigin],
    ](psd, pnb_sd, type, data, size, flags)


fn av_packet_side_data_get(
    sd: UnsafePointer[AVPacketSideData, ImmutExternalOrigin],
    nb_sd: c_int,
    type: AVPacketSideDataType.ENUM_DTYPE,
) -> UnsafePointer[AVPacketSideData, ImmutExternalOrigin]:
    return external_call[
        "av_packet_side_data_get",
        UnsafePointer[AVPacketSideData, ImmutExternalOrigin],
    ](sd, nb_sd, type)


fn av_packet_side_data_remove(
    psd: UnsafePointer[AVPacketSideData, MutExternalOrigin],
    pnb_sd: UnsafePointer[c_int, MutExternalOrigin],
    type: AVPacketSideDataType.ENUM_DTYPE,
):
    external_call["av_packet_side_data_remove", NoneType](psd, pnb_sd, type)


fn av_packet_side_data_free(
    psd: UnsafePointer[
        UnsafePointer[AVPacketSideData, MutExternalOrigin], MutExternalOrigin
    ],
    pnb_sd: UnsafePointer[c_int, MutExternalOrigin],
):
    external_call["av_packet_side_data_free", NoneType](psd, pnb_sd)


fn av_packet_side_data_name(
    type: AVPacketSideDataType.ENUM_DTYPE,
) -> UnsafePointer[c_char, ImmutExternalOrigin]:
    return external_call[
        "av_packet_side_data_name", UnsafePointer[c_char, ImmutExternalOrigin]
    ](type)


@fieldwise_init
struct AVPacket(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVPacket.html."

    var buf: UnsafePointer[AVBufferRef, origin=MutExternalOrigin]
    var pts: c_long_long
    var dts: c_long_long
    var data: UnsafePointer[c_uchar, origin=MutExternalOrigin]
    var size: c_int
    var stream_index: c_int

    comptime AV_PKT_FLAG_KEY: c_int = 0x0001
    comptime AV_PKT_FLAG_CORRUPT: c_int = 0x0002
    comptime AV_PKT_FLAG_DISCARD: c_int = 0x0004
    comptime AV_PKT_FLAG_TRUSTED: c_int = 0x0008
    comptime AV_PKT_FLAG_DISPOSABLE: c_int = 0x0010

    var flags: c_int
    var side_data: UnsafePointer[AVPacketSideData, origin=MutExternalOrigin]
    var side_data_elems: c_int
    var duration: c_long_long
    var pos: c_long_long
    var opaque: OpaquePointer[MutExternalOrigin]
    var opaque_ref: UnsafePointer[AVBufferRef, origin=MutExternalOrigin]
    var time_base: AVRational


# NOTE: AVPacketList is an optional struct that is being deprecated.
# I don't think we need to implement this, but leaving this here as a reference.
# #if FF_API_INIT_PACKET
# attribute_deprecated
# typedef struct AVPacketList {
#     AVPacket pkt;
#     struct AVPacketList *next;
# } AVPacketList;
# #endif


comptime AV_PKT_FLAG_KEY = c_int(0x0001)
comptime AV_PKT_FLAG_CORRUPT = c_int(0x0002)
comptime AV_PKT_FLAG_DISCARD = c_int(0x0004)
comptime AV_PKT_FLAG_TRUSTED = c_int(0x0008)
comptime AV_PKT_FLAG_DISPOSABLE = c_int(0x0010)


@fieldwise_init
struct AVSideDataParamChangeFlags(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var _value: Self.ENUM_DTYPE
    comptime AV_SIDE_DATA_PARAM_CHANGE_SAMPLE_RATE = Self(0x0004)
    comptime AV_SIDE_DATA_PARAM_CHANGE_DIMENSIONS = Self(0x0008)


fn av_packet_alloc() -> UnsafePointer[AVPacket, MutExternalOrigin]:
    return external_call[
        "av_packet_alloc", UnsafePointer[AVPacket, MutExternalOrigin]
    ]()


fn av_packet_clone(
    src: UnsafePointer[AVPacket, ImmutExternalOrigin]
) -> UnsafePointer[AVPacket, MutExternalOrigin]:
    return external_call[
        "av_packet_clone", UnsafePointer[AVPacket, MutExternalOrigin]
    ](src)


fn av_packet_free(
    pkt: UnsafePointer[
        UnsafePointer[AVPacket, MutExternalOrigin], MutExternalOrigin
    ]
):
    external_call["av_packet_free", NoneType](pkt)


# NOTE: av_init_packet is an optional function that is being deprecated.
# I don't think we need to implement this, but leaving this here as a reference.
# #if FF_API_INIT_PACKET
# /**
#  * Initialize optional fields of a packet with default values.
#  *
#  * Note, this does not touch the data and size members, which have to be
#  * initialized separately.
#  *
#  * @param pkt packet
#  *
#  * @see av_packet_alloc
#  * @see av_packet_unref
#  *
#  * @deprecated This function is deprecated. Once it's removed,
#                sizeof(AVPacket) will not be a part of the ABI anymore.
#  */
# attribute_deprecated
# void av_init_packet(AVPacket *pkt);
# #endif


fn av_new_packet(
    pkt: UnsafePointer[AVPacket, MutExternalOrigin], size: c_int
) -> c_int:
    return external_call["av_new_packet", c_int](pkt, size)


fn av_shrink_packet(
    pkt: UnsafePointer[AVPacket, MutExternalOrigin], size: c_int
):
    external_call["av_shrink_packet", NoneType](pkt, size)


fn av_grow_packet(
    pkt: UnsafePointer[AVPacket, MutExternalOrigin], grow_by: c_int
) -> c_int:
    return external_call["av_grow_packet", c_int](pkt, grow_by)


fn av_packet_from_data(
    pkt: UnsafePointer[AVPacket, MutExternalOrigin],
    data: UnsafePointer[c_uchar, MutExternalOrigin],
    size: c_int,
) -> c_int:
    return external_call["av_packet_from_data", c_int](pkt, data, size)


fn av_packet_new_side_data(
    pkt: UnsafePointer[AVPacket, MutExternalOrigin],
    type: AVPacketSideDataType.ENUM_DTYPE,
    size: c_size_t,
) -> UnsafePointer[c_uchar, MutExternalOrigin]:
    return external_call[
        "av_packet_new_side_data", UnsafePointer[c_uchar, MutExternalOrigin]
    ](pkt, type, size)


fn av_packet_add_side_data(
    pkt: UnsafePointer[AVPacket, MutExternalOrigin],
    type: AVPacketSideDataType.ENUM_DTYPE,
    data: UnsafePointer[c_uchar, MutExternalOrigin],
    size: c_size_t,
) -> c_int:
    return external_call["av_packet_add_side_data", c_int](
        pkt, type, data, size
    )


fn av_packet_shrink_side_data(
    pkt: UnsafePointer[AVPacket, MutExternalOrigin],
    type: AVPacketSideDataType.ENUM_DTYPE,
    size: c_size_t,
) -> c_int:
    return external_call["av_packet_shrink_side_data", c_int](pkt, type, size)


fn av_packet_get_side_data(
    pkt: UnsafePointer[AVPacket, ImmutExternalOrigin],
    type: AVPacketSideDataType.ENUM_DTYPE,
    size: UnsafePointer[c_size_t, MutExternalOrigin],
) -> UnsafePointer[c_uchar, ImmutExternalOrigin]:
    return external_call[
        "av_packet_get_side_data", UnsafePointer[c_uchar, ImmutExternalOrigin]
    ](pkt, type, size)


fn av_packet_pack_dictionary(
    dict: UnsafePointer[AVDictionary, ImmutExternalOrigin],
    size: UnsafePointer[c_size_t, MutExternalOrigin],
) -> UnsafePointer[c_uchar, ImmutExternalOrigin]:
    return external_call[
        "av_packet_pack_dictionary", UnsafePointer[c_uchar, ImmutExternalOrigin]
    ](dict, size)


fn av_packet_unpack_dictionary(
    data: UnsafePointer[c_uchar, ImmutExternalOrigin],
    size: c_size_t,
    dict: UnsafePointer[
        UnsafePointer[AVDictionary, MutExternalOrigin], MutExternalOrigin
    ],
) -> c_int:
    return external_call["av_packet_unpack_dictionary", c_int](data, size, dict)


fn av_packet_free_side_data(pkt: UnsafePointer[AVPacket, MutExternalOrigin]):
    external_call["av_packet_free_side_data", NoneType](pkt)


fn av_packet_ref(
    dst: UnsafePointer[AVPacket, MutExternalOrigin],
    src: UnsafePointer[AVPacket, ImmutExternalOrigin],
) -> c_int:
    return external_call["av_packet_ref", c_int](dst, src)


fn av_packet_unref(pkt: UnsafePointer[AVPacket, MutExternalOrigin]):
    external_call["av_packet_unref", NoneType](pkt)


fn av_packet_move_ref(
    dst: UnsafePointer[AVPacket, MutExternalOrigin],
    src: UnsafePointer[AVPacket, MutExternalOrigin],
):
    external_call["av_packet_move_ref", NoneType](dst, src)


fn av_packet_copy_props(
    dst: UnsafePointer[AVPacket, MutExternalOrigin],
    src: UnsafePointer[AVPacket, ImmutExternalOrigin],
) -> c_int:
    return external_call["av_packet_copy_props", c_int](dst, src)


fn av_packet_make_refcounted(
    pkt: UnsafePointer[AVPacket, MutExternalOrigin]
) -> c_int:
    return external_call["av_packet_make_refcounted", c_int](pkt)


fn av_packet_make_writable(
    pkt: UnsafePointer[AVPacket, MutExternalOrigin]
) -> c_int:
    return external_call["av_packet_make_writable", c_int](pkt)


fn av_packet_rescale_ts(
    pkt: UnsafePointer[AVPacket, MutExternalOrigin],
    tb_src: c_long_long,
    tb_dst: c_long_long,
):
    external_call["av_packet_rescale_ts", NoneType](pkt, tb_src, tb_dst)


fn av_packet_rescale_ts(
    pkt: UnsafePointer[AVPacket, MutExternalOrigin],
    tb_src: AVRational,
    tb_dst: AVRational,
):
    external_call["av_packet_rescale_ts", NoneType](
        pkt, tb_src.as_long_long(), tb_dst.as_long_long()
    )


struct AVContainerFifo(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVContainerFifo.html."

    pass


fn av_container_fifo_alloc_avpacket(
    flags: c_int,
) -> UnsafePointer[AVContainerFifo, MutExternalOrigin]:
    return external_call[
        "av_container_fifo_alloc_avpacket",
        UnsafePointer[AVContainerFifo, MutExternalOrigin],
    ](flags)


fn av_container_fifo_free(
    cf: UnsafePointer[
        UnsafePointer[AVContainerFifo, MutExternalOrigin], MutExternalOrigin
    ],
):
    external_call["av_container_fifo_free", NoneType](cf)
