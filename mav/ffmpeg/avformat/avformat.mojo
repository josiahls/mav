"""https://www.ffmpeg.org/doxygen/8.0/avformat_8h.html

Main libavformat public API header

I/O and Muxing/Demuxing Library
"""
from std.ffi import (
    c_int,
    c_char,
    c_uchar,
    c_long_long,
    c_uint,
    c_size_t,
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


fn av_get_packet(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    pkt: UnsafePointer[AVPacket, MutExternalOrigin],
    size: c_int,
) -> c_int:
    return external_call["av_get_packet", c_int](s, pkt, size)


fn av_append_packet(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    pkt: UnsafePointer[AVPacket, MutExternalOrigin],
    size: c_int,
) -> c_int:
    return external_call["av_append_packet", c_int](s, pkt, size)


########################## input / output formats ##############################

# TODO: Is this a forward declaration?
# struct AVCodecTag;


@fieldwise_init
struct AVProbeData(Movable, Writable):
    """See https://www.ffmpeg.org/doxygen/8.0/structAVProbeData.html."""

    var filename: UnsafePointer[c_char, origin=ImmutExternalOrigin]
    var buf: UnsafePointer[c_uchar, origin=MutExternalOrigin]
    var buf_size: c_int
    var mime_type: UnsafePointer[c_char, origin=ImmutExternalOrigin]

    comptime AVPROBE_SCORE_MAX = 100
    comptime AVPROBE_SCORE_RETRY = Self.AVPROBE_SCORE_MAX / 4
    comptime AVPROBE_SCORE_STREAM_RETRY = Self.AVPROBE_SCORE_MAX / 4 - 1

    comptime AVPROBE_SCORE_EXTENSION = 50
    comptime AVPROBE_SCORE_MIME_BONUS = 30

    comptime AVPROBE_PADDING_SIZE = 32

    fn __init__(
        out self,
        var filename: String,
        buf: UnsafePointer[c_uchar, MutExternalOrigin],
        buf_size: c_int,
        mime_type: Optional[String] = None,
    ):
        self.filename = (
            filename.as_c_string_slice()
            .unsafe_ptr()
            .unsafe_origin_cast[ImmutExternalOrigin]()
        )
        self.buf = buf
        self.buf_size = buf_size
        if mime_type:
            var mime_type_str = mime_type.value()
            self.mime_type = (
                mime_type_str.as_c_string_slice()
                .unsafe_ptr()
                .unsafe_origin_cast[ImmutExternalOrigin]()
            )
        else:
            self.mime_type = UnsafePointer[c_char, ImmutExternalOrigin]()


comptime AVFMT_NOFILE = 0x0001
comptime AVFMT_NEEDNUMBER = 0x0002

# The muxer/demuxer is experimental and should be used with caution.
# It will not be selected automatically, and must be specified explicitly.
comptime AVFMT_EXPERIMENTAL = 0x0004
comptime AVFMT_SHOW_IDS = 0x0008
comptime AVFMT_GLOBALHEADER = 0x0040
comptime AVFMT_NOTIMESTAMPS = 0x0080
comptime AVFMT_GENERIC_INDEX = 0x0100
comptime AVFMT_TS_DISCONT = 0x0200
comptime AVFMT_VARIABLE_FPS = 0x0400
comptime AVFMT_NODIMENSIONS = 0x0800
comptime AVFMT_NOSTREAMS = 0x1000
comptime AVFMT_NOBINSEARCH = 0x2000
comptime AVFMT_NOGENSEARCH = 0x4000
comptime AVFMT_NO_BYTE_SEEK = 0x8000
comptime AVFMT_TS_NONSTRICT = 0x20000
comptime AVFMT_TS_NEGATIVE = 0x40000
comptime AVFMT_SEEK_TO_PTS = 0x4000000


@fieldwise_init
struct AVOutputFormat(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVOutputFormat.html."
    var name: UnsafePointer[c_char, origin=ImmutExternalOrigin]
    var long_name: UnsafePointer[c_char, origin=ImmutExternalOrigin]
    var mime_type: UnsafePointer[c_char, origin=ImmutExternalOrigin]
    var extensions: UnsafePointer[c_char, origin=ImmutExternalOrigin]

    var audio_codec: AVCodecID.ENUM_DTYPE
    var video_codec: AVCodecID.ENUM_DTYPE
    var subtitle_codec: AVCodecID.ENUM_DTYPE

    var flags: c_int

    var codec_tag: UnsafePointer[
        UnsafePointer[AVCodecTag, ImmutExternalOrigin], ImmutExternalOrigin
    ]
    var priv_class: UnsafePointer[AVClass, ImmutExternalOrigin]


@fieldwise_init
struct AVInputFormat(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVInputFormat.html."
    var name: UnsafePointer[c_char, origin=ImmutExternalOrigin]
    var long_name: UnsafePointer[c_char, origin=ImmutExternalOrigin]
    var flags: c_int
    var extensions: UnsafePointer[c_char, origin=ImmutExternalOrigin]
    var codec_tag: UnsafePointer[
        UnsafePointer[AVCodecTag, ImmutExternalOrigin], ImmutExternalOrigin
    ]
    var priv_class: UnsafePointer[AVClass, ImmutExternalOrigin]
    var mime_type: UnsafePointer[c_char, origin=ImmutExternalOrigin]


@fieldwise_init
struct AVStreamParseType(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var value: Self.ENUM_DTYPE

    comptime AVSTREAM_PARSE_NONE = Self(0)
    comptime AVSTREAM_PARSE_FULL = Self(1)
    comptime AVSTREAM_PARSE_HEADERS = Self(2)
    comptime AVSTREAM_PARSE_TIMESTAMPS = Self(3)
    comptime AVSTREAM_PARSE_FULL_ONCE = Self(4)
    comptime AVSTREAM_PARSE_FULL_RAW = Self(5)


@fieldwise_init
struct AVIndexEntry(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVIndexEntry.html."
    var pos: c_long_long
    var timestamp: c_long_long

    comptime AVINDEX_KEYFRAME = 0x0001
    comptime AVINDEX_DISCARD_FRAME = 0x0002

    var flags_size: c_int
    var min_distance: c_int


comptime AV_DISPOSITION_DEFAULT = 1 << 0
comptime AV_DISPOSITION_DUB = 1 << 1
comptime AV_DISPOSITION_ORIGINAL = 1 << 2
comptime AV_DISPOSITION_COMMENT = 1 << 3
comptime AV_DISPOSITION_LYRICS = 1 << 4
comptime AV_DISPOSITION_KARAOKE = 1 << 5
comptime AV_DISPOSITION_FORCED = 1 << 6
comptime AV_DISPOSITION_HEARING_IMPAIRED = 1 << 7
comptime AV_DISPOSITION_VISUAL_IMPAIRED = 1 << 8
comptime AV_DISPOSITION_CLEAN_EFFECTS = 1 << 9
comptime AV_DISPOSITION_ATTACHED_PIC = 1 << 10
comptime AV_DISPOSITION_TIMED_THUMBNAILS = 1 << 11
comptime AV_DISPOSITION_NON_DIEGETIC = 1 << 12
comptime AV_DISPOSITION_CAPTIONS = 1 << 16
comptime AV_DISPOSITION_DESCRIPTIONS = 1 << 17
comptime AV_DISPOSITION_METADATA = 1 << 18
comptime AV_DISPOSITION_DEPENDENT = 1 << 19
comptime AV_DISPOSITION_STILL_IMAGE = 1 << 20
comptime AV_DISPOSITION_MULTILAYER = 1 << 21


fn av_disposition_from_string(mut disp: String) -> c_int:
    var disp_ptr = disp.as_c_string_slice().unsafe_ptr().as_immutable()
    return external_call["av_disposition_from_string", c_int](disp_ptr)


fn av_disposition_to_string(
    disposition: c_int,
) -> UnsafePointer[c_char, ImmutExternalOrigin]:
    return external_call[
        "av_disposition_to_string", UnsafePointer[c_char, ImmutExternalOrigin]
    ](disposition)


# Options for behavior on timestamp wrap detection.
comptime AV_PTS_WRAP_IGNORE = 0
comptime AV_PTS_WRAP_ADD_OFFSET = 1
comptime AV_PTS_WRAP_SUB_OFFSET = -1


@fieldwise_init
struct AVStream(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVStream.html."

    var av_class: UnsafePointer[AVClass, ImmutExternalOrigin]
    var index: c_int
    var id: c_int
    var codecpar: UnsafePointer[AVCodecParameters, MutExternalOrigin]
    var priv_data: OpaquePointer[MutExternalOrigin]
    var time_base: AVRational

    var start_time: c_long_long
    var duration: c_long_long

    var nb_frames: c_long_long

    var disposition: c_int

    var discard: AVDiscard.ENUM_DTYPE

    var sample_aspect_ratio: AVRational

    var metadata: UnsafePointer[AVDictionary, MutExternalOrigin]

    var avg_frame_rate: AVRational

    var attached_pic: AVPacket

    var event_flags: c_int

    comptime AVSTREAM_EVENT_FLAG_METADATA_UPDATED = 0x0001
    comptime AVSTREAM_EVENT_FLAG_NEW_PACKETS = 1 << 1

    var r_frame_rate: AVRational

    var pts_wrap_bits: c_int


@fieldwise_init
struct _AVStreamGroupTileGrid_offsets(Movable, Writable):
    """Binding note: In the original header this is a anonymous struct.
    Mojo does not support this, so we define this as a private, name spaced
    struct outside of AVStreamGroupTileGrid.
    """

    var idx: c_uint
    var horizontal: c_int
    var vertical: c_int


@fieldwise_init
struct AVStreamGroupTileGrid(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVStreamGroupTileGrid.html."

    var av_class: UnsafePointer[AVClass, ImmutExternalOrigin]
    var nb_tiles: c_uint
    var coded_width: c_int
    var coded_height: c_int
    var offsets: UnsafePointer[
        _AVStreamGroupTileGrid_offsets, MutExternalOrigin
    ]

    var background: StaticTuple[c_uchar, 4]
    var horizontal_offset: c_int
    var vertical_offset: c_int
    var width: c_int
    var height: c_int
    var coded_side_data: UnsafePointer[AVPacketSideData, MutExternalOrigin]
    var nb_coded_side_data: c_int


@fieldwise_init
struct AVStreamGroupLCEVC(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVStreamGroupLCEVC.html."

    var av_class: UnsafePointer[AVClass, ImmutExternalOrigin]
    var lcevc_index: c_uint
    var width: c_int
    var height: c_int


@fieldwise_init
struct AVStreamGroupParamsType(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var value: Self.ENUM_DTYPE

    comptime AV_STREAM_GROUP_PARAMS_NONE = Self(0)
    comptime AV_STREAM_GROUP_PARAMS_IAMF_AUDIO_ELEMENT = Self(1)
    comptime AV_STREAM_GROUP_PARAMS_IAMF_MIX_PRESENTATION = Self(2)
    comptime AV_STREAM_GROUP_PARAMS_TILE_GRID = Self(3)
    comptime AV_STREAM_GROUP_PARAMS_LCEVC = Self(4)


# TODO: Are these forward declaraions?
# struct AVIAMFAudioElement;
# struct AVIAMFMixPresentation;


@fieldwise_init
struct AVStreamGroup(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVStreamGroup.html."

    var av_class: UnsafePointer[AVClass, ImmutExternalOrigin]
    var priv_data: OpaquePointer[MutExternalOrigin]
    var index: c_uint
    var id: c_long_long
    var type: AVStreamGroupParamsType.ENUM_DTYPE
    var params: C_Union[
        UnsafePointer[AVIAMFAudioElement, MutExternalOrigin],
        UnsafePointer[AVIAMFMixPresentation, MutExternalOrigin],
        UnsafePointer[AVStreamGroupTileGrid, MutExternalOrigin],
        UnsafePointer[AVStreamGroupLCEVC, MutExternalOrigin],
    ]
    var metadata: UnsafePointer[AVDictionary, MutExternalOrigin]
    var nb_streams: c_uint
    var streams: UnsafePointer[
        UnsafePointer[AVStream, MutExternalOrigin], MutExternalOrigin
    ]
    var disposition: c_int


fn av_stream_get_parser(
    s: UnsafePointer[AVStream, ImmutExternalOrigin]
) -> UnsafePointer[AVCodecParserContext, ImmutExternalOrigin]:
    return external_call[
        "av_stream_get_parser",
        UnsafePointer[AVCodecParserContext, ImmutExternalOrigin],
    ](s)


comptime AV_PROGRAM_RUNNING = 1


@fieldwise_init
struct AVProgram(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVProgram.html."

    var id: c_int
    var flags: c_int
    var discard: AVDiscard.ENUM_DTYPE
    var stream_index: UnsafePointer[c_uint, MutExternalOrigin]
    var nb_stream_indexes: c_uint
    var metadata: UnsafePointer[AVDictionary, MutExternalOrigin]

    var program_num: c_int
    var pmt_pid: c_int
    var pcr_pid: c_int
    var pmt_version: c_int

    # All fields below this line are not part of the public API. They
    # may not be used outside of libavformat and can be changed and
    # removed at will.
    # New public fields should be added right above.

    var start_time: c_long_long
    var end_time: c_long_long

    var pts_wrap_reference: c_long_long
    var pts_wrap_behavior: c_int


comptime AVFMTCTX_NOHEADER = 0x0001
comptime AVFMTCTX_UNSEEKABLE = 0x0002


@fieldwise_init
struct AVChapter(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVChapter.html."
    var id: c_long_long
    var time_base: AVRational
    var start: c_long_long
    var end: c_long_long
    var metadata: UnsafePointer[AVDictionary, MutExternalOrigin]


# TODO: This is not a real function. This is a prototype used by AVFormatContext.control_message_cb.
# comptime av_format_control_message = ExternalFunction[
#     "av_format_control_message",
#     fn (
#         s: UnsafePointer[AVFormatContext, MutExternalOrigin],
#         type: c_int,
#         data: OpaquePointer[MutExternalOrigin],
#         data_size: c_size_t,
#     ) -> c_int,
# ]


comptime AVOpenCallback = fn(
    s: UnsafePointer[AVFormatContext, MutExternalOrigin],
    pb: UnsafePointer[
        UnsafePointer[AVIOContext, MutExternalOrigin], MutExternalOrigin
    ],
    url: UnsafePointer[c_char, ImmutExternalOrigin],
    flags: c_int,
    int_cb: UnsafePointer[AVIOInterruptCB, ImmutExternalOrigin],
    options: UnsafePointer[
        UnsafePointer[AVDictionary, MutExternalOrigin], MutExternalOrigin
    ],
) -> c_int


@fieldwise_init
struct AVDurationEstimationMethod(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var value: Self.ENUM_DTYPE

    comptime AVFMT_DURATION_FROM_PTS = Self(0)
    comptime AVFMT_DURATION_FROM_STREAM = Self(1)
    comptime AVFMT_DURATION_FROM_BITRATE = Self(2)


# @register_passable("trivial")
@fieldwise_init
struct AVFormatContext(Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVFormatContext.html."

    var av_class: UnsafePointer[AVClass, ImmutExternalOrigin]
    var iformat: UnsafePointer[AVInputFormat, ImmutExternalOrigin]
    var oformat: UnsafePointer[AVOutputFormat, ImmutExternalOrigin]
    var priv_data: OpaquePointer[MutExternalOrigin]
    var pb: UnsafePointer[AVIOContext, MutExternalOrigin]
    # Stream info
    var ctx_flags: c_int
    var nb_streams: c_uint
    var streams: UnsafePointer[
        UnsafePointer[AVStream, MutExternalOrigin], MutExternalOrigin
    ]
    var nb_stream_groups: c_uint
    var stream_groups: UnsafePointer[
        UnsafePointer[AVStreamGroup, MutExternalOrigin], MutExternalOrigin
    ]

    var nb_chapters: c_uint

    var chapters: UnsafePointer[
        UnsafePointer[AVChapter, MutExternalOrigin], MutExternalOrigin
    ]

    var url: UnsafePointer[c_char, MutExternalOrigin]
    var start_time: c_long_long
    var duration: c_long_long
    var bit_rate: c_long_long
    var packet_size: c_uint
    var max_delay: c_int

    var flags: c_int
    comptime AVFMT_FLAG_GENPTS = 0x0001
    comptime AVFMT_FLAG_IGNIDX = 0x0002
    comptime AVFMT_FLAG_NONBLOCK = 0x0004
    comptime AVFMT_FLAG_IGNDTS = 0x0008
    comptime AVFMT_FLAG_NOFILLIN = 0x0010
    comptime AVFMT_FLAG_NOPARSE = 0x0020
    comptime AVFMT_FLAG_NOBUFFER = 0x0040
    comptime AVFMT_FLAG_CUSTOM_IO = 0x0080
    comptime AVFMT_FLAG_DISCARD_CORRUPT = 0x0100
    comptime AVFMT_FLAG_FLUSH_PACKETS = 0x0200

    comptime AVFMT_FLAG_BITEXACT = 0x0400
    comptime AVFMT_FLAG_SORT_DTS = 0x10000
    comptime AVFMT_FLAG_FAST_SEEK = 0x80000
    comptime AVFMT_FLAG_AUTO_BSF = 0x200000

    var probesize: c_long_long
    var max_analyze_duration: c_long_long

    var key: UnsafePointer[c_uchar, ImmutExternalOrigin]
    var keylen: c_int

    var nb_programs: c_uint
    var programs: UnsafePointer[
        UnsafePointer[AVProgram, MutExternalOrigin], MutExternalOrigin
    ]

    var video_codec_id: AVCodecID.ENUM_DTYPE
    var audio_codec_id: AVCodecID.ENUM_DTYPE
    var subtitle_codec_id: AVCodecID.ENUM_DTYPE
    var data_codec_id: AVCodecID.ENUM_DTYPE
    var metadata: UnsafePointer[AVDictionary, MutExternalOrigin]
    var start_time_realtime: c_long_long
    var fps_probe_size: c_int
    var error_recognition: c_int
    var interrupt_callback: AVIOInterruptCB
    var debug: c_int
    comptime FF_FDEBUG_TS = 0x0001

    var max_streams: c_int
    var max_index_size: c_uint
    var max_picture_buffer: c_uint
    var max_interleave_delta: c_long_long

    var max_ts_probe: c_int
    var max_chunk_duration: c_int
    var max_chunk_size: c_int
    var max_probe_packets: c_int
    var strict_std_compliance: c_int
    var event_flags: c_int

    comptime AVFMT_EVENT_FLAG_METADATA_UPDATED = 0x0001

    var avoid_negative_ts: c_int
    comptime AVFMT_AVOID_NEG_TS_AUTO = -1
    comptime AVFMT_AVOID_NEG_TS_DISABLED = 0
    comptime AVFMT_AVOID_NEG_TS_MAKE_NON_NEGATIVE = 1
    comptime AVFMT_AVOID_NEG_TS_MAKE_ZERO = 2
    var audio_preload: c_int
    var use_wallclock_as_timestamps: c_int
    var skip_estimate_duration_from_pts: c_int
    var avio_flags: c_int
    var duration_estimation_method: AVDurationEstimationMethod.ENUM_DTYPE
    var skip_initial_bytes: c_long_long
    var correct_ts_overflow: c_uint
    var seek2any: c_int
    var flush_packets: c_int
    var probe_score: c_int
    var format_probesize: c_int
    var codec_whitelist: UnsafePointer[c_char, MutExternalOrigin]
    var format_whitelist: UnsafePointer[c_char, MutExternalOrigin]
    var protocol_whitelist: UnsafePointer[c_char, MutExternalOrigin]
    var protocol_blacklist: UnsafePointer[c_char, MutExternalOrigin]
    var io_repositioned: c_int
    var video_codec: UnsafePointer[AVCodec, ImmutExternalOrigin]
    var audio_codec: UnsafePointer[AVCodec, ImmutExternalOrigin]
    var subtitle_codec: UnsafePointer[AVCodec, ImmutExternalOrigin]
    var data_codec: UnsafePointer[AVCodec, ImmutExternalOrigin]
    var metadata_header_padding: c_int
    var opaque: OpaquePointer[MutExternalOrigin]

    # TODO: should these be pointers? How does this impact struct size?
    # For some reason I can't define this under: av_format_control_message
    # var control_message_cb: type_of(av_format_control_message)
    var control_message_cb: fn(
        s: UnsafePointer[AVFormatContext, MutExternalOrigin],
        type: c_int,
        data: OpaquePointer[MutExternalOrigin],
        data_size: c_size_t,
    ) -> c_int
    var output_ts_offset: c_long_long
    var dump_separator: UnsafePointer[c_uchar, MutExternalOrigin]
    var io_open: fn(
        s: UnsafePointer[AVFormatContext, MutExternalOrigin],
        pb: UnsafePointer[
            UnsafePointer[AVIOContext, MutExternalOrigin], MutExternalOrigin
        ],
        url: UnsafePointer[c_char, ImmutExternalOrigin],
        flags: c_int,
        options: UnsafePointer[
            UnsafePointer[AVDictionary, MutExternalOrigin], MutExternalOrigin
        ],
    ) -> c_int
    var io_close2: fn(
        s: UnsafePointer[AVFormatContext, MutExternalOrigin],
        pb: UnsafePointer[AVIOContext, MutExternalOrigin],
    ) -> c_int

    var duration_probesize: c_long_long


fn avformat_version() -> c_uint:
    return external_call["avformat_version", c_uint]()


fn avformat_configuration() -> UnsafePointer[c_char, ImmutExternalOrigin]:
    return external_call[
        "avformat_configuration", UnsafePointer[c_char, ImmutExternalOrigin]
    ]()


fn avformat_license() -> UnsafePointer[c_char, ImmutExternalOrigin]:
    return external_call[
        "avformat_license", UnsafePointer[c_char, ImmutExternalOrigin]
    ]()


fn avformat_network_init() -> c_int:
    return external_call["avformat_network_init", c_int]()


fn avformat_network_deinit() -> c_int:
    return external_call["avformat_network_deinit", c_int]()


fn av_muxer_iterate(
    opaque: UnsafePointer[OpaquePointer[MutExternalOrigin], MutExternalOrigin]
) -> UnsafePointer[AVOutputFormat, ImmutExternalOrigin]:
    return external_call[
        "av_muxer_iterate", UnsafePointer[AVOutputFormat, ImmutExternalOrigin]
    ](opaque)


fn av_demuxer_iterate(
    opaque: UnsafePointer[OpaquePointer[MutExternalOrigin], MutExternalOrigin]
) -> UnsafePointer[AVInputFormat, ImmutExternalOrigin]:
    return external_call[
        "av_demuxer_iterate", UnsafePointer[AVInputFormat, ImmutExternalOrigin]
    ](opaque)


fn avformat_alloc_context() -> (
    UnsafePointer[AVFormatContext, MutExternalOrigin]
):
    return external_call[
        "avformat_alloc_context",
        UnsafePointer[AVFormatContext, MutExternalOrigin],
    ]()


fn avformat_free_context(s: UnsafePointer[AVFormatContext, MutExternalOrigin]):
    external_call["avformat_free_context", NoneType](s)


fn avformat_get_class() -> UnsafePointer[AVClass, ImmutExternalOrigin]:
    return external_call[
        "avformat_get_class", UnsafePointer[AVClass, ImmutExternalOrigin]
    ]()


fn av_stream_get_class() -> UnsafePointer[AVClass, ImmutExternalOrigin]:
    return external_call[
        "av_stream_get_class", UnsafePointer[AVClass, ImmutExternalOrigin]
    ]()


fn av_stream_group_get_class() -> UnsafePointer[AVClass, ImmutExternalOrigin]:
    return external_call[
        "av_stream_group_get_class", UnsafePointer[AVClass, ImmutExternalOrigin]
    ]()


fn avformat_stream_group_name(
    type: AVStreamGroupParamsType.ENUM_DTYPE,
) -> UnsafePointer[c_char, ImmutExternalOrigin]:
    return external_call[
        "avformat_stream_group_name", UnsafePointer[c_char, ImmutExternalOrigin]
    ](type)


fn avformat_stream_group_create(
    s: UnsafePointer[AVFormatContext, MutExternalOrigin],
    type: AVStreamGroupParamsType.ENUM_DTYPE,
    options: UnsafePointer[
        UnsafePointer[AVDictionary, MutExternalOrigin], MutExternalOrigin
    ],
) -> UnsafePointer[AVStreamGroup, MutExternalOrigin]:
    return external_call[
        "avformat_stream_group_create",
        UnsafePointer[AVStreamGroup, MutExternalOrigin],
    ](s, type, options)


fn avformat_new_stream(
    s: UnsafePointer[AVFormatContext, MutExternalOrigin],
    c: UnsafePointer[AVCodec, ImmutExternalOrigin],
) -> UnsafePointer[AVStream, MutExternalOrigin]:
    return external_call[
        "avformat_new_stream", UnsafePointer[AVStream, MutExternalOrigin]
    ](s, c)


fn avformat_stream_group_add_stream(
    stg: UnsafePointer[AVStreamGroup, MutExternalOrigin],
    st: UnsafePointer[AVStream, MutExternalOrigin],
) -> c_int:
    return external_call["avformat_stream_group_add_stream", c_int](stg, st)


fn av_new_program(
    s: UnsafePointer[AVFormatContext, MutExternalOrigin], id: c_int
) -> UnsafePointer[AVProgram, MutExternalOrigin]:
    return external_call[
        "av_new_program", UnsafePointer[AVProgram, MutExternalOrigin]
    ](s, id)


fn avformat_alloc_output_context2(
    ctx: UnsafePointer[
        UnsafePointer[AVFormatContext, MutExternalOrigin],
        MutExternalOrigin,
    ],
    oformat: UnsafePointer[AVOutputFormat, ImmutExternalOrigin],
    format_name: UnsafePointer[c_char, ImmutExternalOrigin],
    filename: UnsafePointer[c_char, ImmutAnyOrigin],
) -> c_int:
    return external_call["avformat_alloc_output_context2", c_int](
        ctx, oformat, format_name, filename
    )


fn alloc_output_context(
    ctx: UnsafePointer[
        UnsafePointer[AVFormatContext, MutExternalOrigin], MutExternalOrigin
    ],
    oformat: UnsafePointer[AVOutputFormat, ImmutExternalOrigin],
    format_name: UnsafePointer[c_char, ImmutExternalOrigin],
    mut filename: String,
) -> c_int:
    return avformat_alloc_output_context2(
        ctx=ctx,
        oformat=oformat,
        format_name=format_name,
        filename=filename.as_c_string_slice().unsafe_ptr().as_immutable(),
    )


fn alloc_output_context(
    ctx: UnsafePointer[
        UnsafePointer[AVFormatContext, MutExternalOrigin], MutExternalOrigin
    ],
    mut filename: String,
) -> c_int:
    return avformat_alloc_output_context2(
        ctx=ctx,
        oformat=UnsafePointer[AVOutputFormat, ImmutExternalOrigin](),
        format_name=UnsafePointer[c_char, ImmutExternalOrigin](),
        filename=filename.as_c_string_slice().unsafe_ptr().as_immutable(),
    )


fn av_find_input_format(
    mut short_name: String,
) -> UnsafePointer[AVInputFormat, ImmutExternalOrigin]:
    var short_name_ptr = (
        short_name.as_c_string_slice().unsafe_ptr().as_immutable()
    )
    return external_call[
        "av_find_input_format",
        UnsafePointer[AVInputFormat, ImmutExternalOrigin],
    ](short_name_ptr)


fn av_probe_input_format(
    pd: UnsafePointer[AVProbeData, ImmutExternalOrigin], is_opened: c_int
) -> UnsafePointer[AVInputFormat, ImmutExternalOrigin]:
    return external_call[
        "av_probe_input_format",
        UnsafePointer[AVInputFormat, ImmutExternalOrigin],
    ](pd, is_opened)


fn av_probe_input_format2(
    pd: UnsafePointer[AVProbeData, ImmutExternalOrigin],
    is_opened: c_int,
    score_max: UnsafePointer[c_int, MutExternalOrigin],
) -> UnsafePointer[AVInputFormat, ImmutExternalOrigin]:
    return external_call[
        "av_probe_input_format2",
        UnsafePointer[AVInputFormat, ImmutExternalOrigin],
    ](pd, is_opened, score_max)


fn av_probe_input_format3(
    pd: UnsafePointer[AVProbeData, ImmutExternalOrigin],
    is_opened: c_int,
    score_ret: UnsafePointer[c_int, MutExternalOrigin],
) -> UnsafePointer[AVInputFormat, ImmutExternalOrigin]:
    return external_call[
        "av_probe_input_format3",
        UnsafePointer[AVInputFormat, ImmutExternalOrigin],
    ](pd, is_opened, score_ret)


fn av_probe_input_buffer2(
    pb: UnsafePointer[AVIOContext, MutExternalOrigin],
    fmt: UnsafePointer[
        UnsafePointer[AVInputFormat, ImmutExternalOrigin], MutExternalOrigin
    ],
    mut url: String,
    logctx: OpaquePointer[MutExternalOrigin],
    offset: c_uint,
    max_probe_size: c_uint,
) -> c_int:
    var url_ptr = url.as_c_string_slice().unsafe_ptr().as_immutable()
    return external_call["av_probe_input_buffer2", c_int](
        pb, fmt, url_ptr, logctx, offset, max_probe_size
    )


fn av_probe_input_buffer(
    pb: UnsafePointer[AVIOContext, MutExternalOrigin],
    fmt: UnsafePointer[
        UnsafePointer[AVInputFormat, ImmutExternalOrigin], MutExternalOrigin
    ],
    mut url: String,
    logctx: OpaquePointer[MutExternalOrigin],
    offset: c_uint,
    max_probe_size: c_uint,
) -> c_int:
    var url_ptr = url.as_c_string_slice().unsafe_ptr().as_immutable()
    return external_call["av_probe_input_buffer", c_int](
        pb, fmt, url_ptr, logctx, offset, max_probe_size
    )


fn avformat_open_input(
    s: UnsafePointer[
        UnsafePointer[AVFormatContext, MutExternalOrigin], MutExternalOrigin
    ],
    mut url: String,
    fmt: Optional[UnsafePointer[AVInputFormat, ImmutExternalOrigin]],
    options: Optional[
        UnsafePointer[
            UnsafePointer[AVDictionary, MutExternalOrigin], MutExternalOrigin
        ]
    ],
) -> c_int:
    var empty_options = options.Element()
    var empty_fmt = UnsafePointer[AVInputFormat, MutExternalOrigin]()
    var url_ptr = url.as_c_string_slice().unsafe_ptr().as_immutable()
    var res = external_call["avformat_open_input", c_int](
        s, url_ptr, fmt.or_else(empty_fmt), options.or_else(empty_options)
    )
    empty_fmt.free()
    empty_options.free()
    return res


fn avformat_find_stream_info(
    ic: UnsafePointer[AVFormatContext, MutExternalOrigin],
    options: UnsafePointer[
        UnsafePointer[AVDictionary, MutExternalOrigin], MutExternalOrigin
    ],
) -> c_int:
    return external_call["avformat_find_stream_info", c_int](ic, options)


fn av_find_program_from_stream(
    ic: UnsafePointer[AVFormatContext, MutExternalOrigin],
    last: UnsafePointer[AVProgram, MutExternalOrigin],
    s: c_int,
) -> UnsafePointer[AVProgram, MutExternalOrigin]:
    return external_call[
        "av_find_program_from_stream",
        UnsafePointer[AVProgram, MutExternalOrigin],
    ](ic, last, s)


fn av_program_add_stream_index(
    ac: UnsafePointer[AVFormatContext, MutExternalOrigin],
    progid: c_int,
    idx: c_uint,
):
    external_call["av_program_add_stream_index", NoneType](ac, progid, idx)


fn av_find_best_stream(
    ic: UnsafePointer[AVFormatContext, MutExternalOrigin],
    type: AVMediaType.ENUM_DTYPE,
    wanted_stream_nb: c_int,
    related_stream: c_int,
    # TODO: I think only 1 of these needs to be immut.
    decoder_ret: UnsafePointer[
        UnsafePointer[AVCodec, ImmutExternalOrigin], MutExternalOrigin
    ],
    flags: c_int,
) -> c_int:
    return external_call["av_find_best_stream", c_int](
        ic, type, wanted_stream_nb, related_stream, decoder_ret, flags
    )


fn av_read_frame(
    s: UnsafePointer[AVFormatContext, MutExternalOrigin],
    pkt: UnsafePointer[AVPacket, MutExternalOrigin],
) -> c_int:
    return external_call["av_read_frame", c_int](s, pkt)


fn av_seek_frame(
    s: UnsafePointer[AVFormatContext, MutExternalOrigin],
    stream_index: c_int,
    timestamp: c_long_long,
    flags: c_int,
) -> c_int:
    return external_call["av_seek_frame", c_int](
        s, stream_index, timestamp, flags
    )


fn avformat_seek_file(
    s: UnsafePointer[AVFormatContext, MutExternalOrigin],
    stream_index: c_int,
    min_ts: c_long_long,
    ts: c_long_long,
    max_ts: c_long_long,
    flags: c_int,
) -> c_int:
    return external_call["avformat_seek_file", c_int](
        s, stream_index, min_ts, ts, max_ts, flags
    )


fn avformat_flush(s: UnsafePointer[AVFormatContext, MutExternalOrigin]):
    external_call["avformat_flush", NoneType](s)


fn av_read_play(s: UnsafePointer[AVFormatContext, MutExternalOrigin]) -> c_int:
    return external_call["av_read_play", c_int](s)


fn av_read_pause(s: UnsafePointer[AVFormatContext, MutExternalOrigin]) -> c_int:
    return external_call["av_read_pause", c_int](s)


fn avformat_close_input(
    s: UnsafePointer[
        UnsafePointer[AVFormatContext, MutExternalOrigin], MutExternalOrigin
    ]
):
    external_call["avformat_close_input", NoneType](s)


comptime AVSEEK_FLAG_BACKWARD = 1
comptime AVSEEK_FLAG_BYTE = 2
comptime AVSEEK_FLAG_ANY = 4
comptime AVSEEK_FLAG_FRAME = 8
comptime AVSTREAM_INIT_IN_WRITE_HEADER = 0
comptime AVSTREAM_INIT_IN_INIT_OUTPUT = 1


fn avformat_write_header(
    s: UnsafePointer[AVFormatContext, MutExternalOrigin],
    options: UnsafePointer[
        UnsafePointer[AVDictionary, MutExternalOrigin], MutExternalOrigin
    ],
) -> c_int:
    return external_call["avformat_write_header", c_int](s, options)


fn avformat_init_output(
    s: UnsafePointer[AVFormatContext, MutExternalOrigin],
    options: UnsafePointer[
        UnsafePointer[AVDictionary, MutExternalOrigin], MutExternalOrigin
    ],
) -> c_int:
    return external_call["avformat_init_output", c_int](s, options)


fn av_write_frame(
    s: UnsafePointer[AVFormatContext, MutExternalOrigin],
    pkt: UnsafePointer[AVPacket, MutExternalOrigin],
) -> c_int:
    return external_call["av_write_frame", c_int](s, pkt)


fn av_interleaved_write_frame(
    s: UnsafePointer[AVFormatContext, MutExternalOrigin],
    pkt: UnsafePointer[AVPacket, MutExternalOrigin],
) -> c_int:
    return external_call["av_interleaved_write_frame", c_int](s, pkt)


fn av_write_uncoded_frame(
    s: UnsafePointer[AVFormatContext, MutExternalOrigin],
    stream_index: c_int,
    frame: UnsafePointer[AVFrame, MutExternalOrigin],
) -> c_int:
    return external_call["av_write_uncoded_frame", c_int](
        s, stream_index, frame
    )


fn av_interleaved_write_uncoded_frame(
    s: UnsafePointer[AVFormatContext, MutExternalOrigin],
    stream_index: c_int,
    frame: UnsafePointer[AVFrame, MutExternalOrigin],
) -> c_int:
    return external_call["av_interleaved_write_uncoded_frame", c_int](
        s, stream_index, frame
    )


fn av_write_uncoded_frame_query(
    s: UnsafePointer[AVFormatContext, MutExternalOrigin], stream_index: c_int
) -> c_int:
    return external_call["av_write_uncoded_frame_query", c_int](s, stream_index)


fn av_write_trailer(
    s: UnsafePointer[AVFormatContext, MutExternalOrigin]
) -> c_int:
    return external_call["av_write_trailer", c_int](s)


fn av_guess_format(
    short_name: Optional[String] = None,
    filename: Optional[String] = None,
    mime_type: Optional[String] = None,
) -> UnsafePointer[AVOutputFormat, ImmutExternalOrigin]:
    var short_name_ptr = UnsafePointer[c_char, ImmutAnyOrigin]()
    var filename_ptr = UnsafePointer[c_char, ImmutAnyOrigin]()
    var mime_type_ptr = UnsafePointer[c_char, ImmutAnyOrigin]()

    if short_name:
        var short_name_str = short_name.value()
        short_name_ptr = (
            short_name_str.as_c_string_slice().unsafe_ptr().as_immutable()
        )
    if filename:
        var filename_str = filename.value()
        filename_ptr = (
            filename_str.as_c_string_slice().unsafe_ptr().as_immutable()
        )
    if mime_type:
        var mime_type_str = mime_type.value()
        mime_type_ptr = (
            mime_type_str.as_c_string_slice().unsafe_ptr().as_immutable()
        )
    return external_call[
        "av_guess_format", UnsafePointer[AVOutputFormat, ImmutExternalOrigin]
    ](short_name_ptr, filename_ptr, mime_type_ptr)


fn av_guess_codec(
    fmt: UnsafePointer[AVOutputFormat, ImmutExternalOrigin],
    short_name: Optional[String],
    filename: Optional[String],
    mime_type: Optional[String],
    type: AVMediaType.ENUM_DTYPE,
) -> AVCodecID.ENUM_DTYPE:
    var short_name_ptr = UnsafePointer[c_char, ImmutAnyOrigin]()
    var filename_ptr = UnsafePointer[c_char, ImmutAnyOrigin]()
    var mime_type_ptr = UnsafePointer[c_char, ImmutAnyOrigin]()
    if short_name:
        var short_name_str = short_name.value()
        short_name_ptr = (
            short_name_str.as_c_string_slice().unsafe_ptr().as_immutable()
        )
    if filename:
        var filename_str = filename.value()
        filename_ptr = (
            filename_str.as_c_string_slice().unsafe_ptr().as_immutable()
        )
    if mime_type:
        var mime_type_str = mime_type.value()
        mime_type_ptr = (
            mime_type_str.as_c_string_slice().unsafe_ptr().as_immutable()
        )
    return external_call["av_guess_codec", AVCodecID.ENUM_DTYPE](
        fmt, short_name_ptr, filename_ptr, mime_type_ptr, type
    )


fn av_get_output_timestamp(
    s: UnsafePointer[AVFormatContext, MutExternalOrigin],
    stream: c_int,
    dts: UnsafePointer[c_long_long, MutExternalOrigin],
    wall: UnsafePointer[c_long_long, MutExternalOrigin],
) -> c_int:
    return external_call["av_get_output_timestamp", c_int](s, stream, dts, wall)


fn av_hex_dump(
    f: FILE_ptr, buf: UnsafePointer[c_uchar, ImmutExternalOrigin], size: c_int
):
    external_call["av_hex_dump", NoneType](f, buf, size)


fn av_hex_dump_log(
    avcl: OpaquePointer[MutExternalOrigin],
    level: c_int,
    buf: UnsafePointer[c_uchar, ImmutExternalOrigin],
    size: c_int,
):
    external_call["av_hex_dump_log", NoneType](avcl, level, buf, size)


fn av_pkt_dump2(
    f: FILE_ptr,
    pkt: UnsafePointer[AVPacket, ImmutExternalOrigin],
    dump_payload: c_int,
    st: UnsafePointer[AVStream, ImmutExternalOrigin],
):
    external_call["av_pkt_dump2", NoneType](f, pkt, dump_payload, st)


fn av_pkt_dump_log2(
    avcl: OpaquePointer[MutExternalOrigin],
    level: c_int,
    pkt: UnsafePointer[AVPacket, ImmutExternalOrigin],
    dump_payload: c_int,
    st: UnsafePointer[AVStream, ImmutExternalOrigin],
):
    external_call["av_pkt_dump_log2", NoneType](
        avcl, level, pkt, dump_payload, st
    )


fn av_codec_get_id(
    tags: UnsafePointer[
        UnsafePointer[AVCodecTag, ImmutExternalOrigin], ImmutExternalOrigin
    ],
    tag: c_uint,
) -> AVCodecID.ENUM_DTYPE:
    return external_call["av_codec_get_id", AVCodecID.ENUM_DTYPE](tags, tag)


fn av_codec_get_tag(
    tags: UnsafePointer[
        UnsafePointer[AVCodecTag, ImmutExternalOrigin], ImmutExternalOrigin
    ],
    id: AVCodecID.ENUM_DTYPE,
) -> c_uint:
    return external_call["av_codec_get_tag", c_uint](tags, id)


fn av_codec_get_tag2(
    tags: UnsafePointer[
        UnsafePointer[AVCodecTag, ImmutExternalOrigin], ImmutExternalOrigin
    ],
    id: AVCodecID.ENUM_DTYPE,
    tag: UnsafePointer[c_uint, MutExternalOrigin],
) -> c_int:
    return external_call["av_codec_get_tag2", c_int](tags, id, tag)


fn av_find_default_stream_index(
    s: UnsafePointer[AVFormatContext, MutExternalOrigin]
) -> c_int:
    return external_call["av_find_default_stream_index", c_int](s)


fn av_index_search_timestamp(
    st: UnsafePointer[AVStream, MutExternalOrigin],
    timestamp: c_long_long,
    flags: c_int,
) -> c_int:
    return external_call["av_index_search_timestamp", c_int](
        st, timestamp, flags
    )


fn avformat_index_get_entries_count(
    st: UnsafePointer[AVStream, MutExternalOrigin]
) -> c_int:
    return external_call["avformat_index_get_entries_count", c_int](st)


fn avformat_index_get_entry(
    st: UnsafePointer[AVStream, MutExternalOrigin], idx: c_int
) -> UnsafePointer[AVIndexEntry, ImmutExternalOrigin]:
    return external_call[
        "avformat_index_get_entry",
        UnsafePointer[AVIndexEntry, ImmutExternalOrigin],
    ](st, idx)


fn avformat_index_get_entry_from_timestamp(
    st: UnsafePointer[AVStream, MutExternalOrigin],
    timestamp: c_long_long,
    flags: c_int,
) -> UnsafePointer[AVIndexEntry, ImmutExternalOrigin]:
    return external_call[
        "avformat_index_get_entry_from_timestamp",
        UnsafePointer[AVIndexEntry, ImmutExternalOrigin],
    ](st, timestamp, flags)


fn av_add_index_entry(
    st: UnsafePointer[AVStream, MutExternalOrigin],
    pos: c_long_long,
    timestamp: c_long_long,
    size: c_int,
    distance: c_int,
    flags: c_int,
) -> c_int:
    return external_call["av_add_index_entry", c_int](
        st, pos, timestamp, size, distance, flags
    )


fn av_url_split(
    proto: UnsafePointer[c_char, MutExternalOrigin],
    proto_size: c_int,
    authorization: UnsafePointer[c_char, MutExternalOrigin],
    authorization_size: c_int,
    hostname: UnsafePointer[c_char, MutExternalOrigin],
    hostname_size: c_int,
    port_ptr: UnsafePointer[c_int, MutExternalOrigin],
    path: UnsafePointer[c_char, MutExternalOrigin],
    path_size: c_int,
    url: UnsafePointer[c_char, ImmutAnyOrigin],
):
    external_call["av_url_split", NoneType](
        proto,
        proto_size,
        authorization,
        authorization_size,
        hostname,
        hostname_size,
        port_ptr,
        path,
        path_size,
        url,
    )


fn av_dump_format(
    ic: UnsafePointer[AVFormatContext, MutExternalOrigin],
    index: c_int,
    mut url: String,
    is_output: c_int,
):
    var url_ptr = url.as_c_string_slice().unsafe_ptr().as_immutable()
    external_call["av_dump_format", NoneType](ic, index, url_ptr, is_output)


comptime AV_FRAME_FILENAME_FLAGS_MULTIPLE = 1


fn av_get_frame_filename2(
    buf: UnsafePointer[c_char, MutExternalOrigin],
    buf_size: c_int,
    mut path: String,
    number: c_int,
    flags: c_int,
) -> c_int:
    var path_ptr = path.as_c_string_slice().unsafe_ptr().as_immutable()
    return external_call["av_get_frame_filename2", c_int](
        buf, buf_size, path_ptr, number, flags
    )


fn av_get_frame_filename(
    buf: UnsafePointer[c_char, MutExternalOrigin],
    buf_size: c_int,
    mut path: String,
    number: c_int,
) -> c_int:
    var path_ptr = path.as_c_string_slice().unsafe_ptr().as_immutable()
    return external_call["av_get_frame_filename", c_int](
        buf, buf_size, path_ptr, number
    )


fn av_filename_number_test(mut filename: String) -> c_int:
    var filename_ptr = filename.as_c_string_slice().unsafe_ptr().as_immutable()
    return external_call["av_filename_number_test", c_int](filename_ptr)


fn av_sdp_create(
    ac: UnsafePointer[
        UnsafePointer[AVFormatContext, MutExternalOrigin], MutExternalOrigin
    ],
    n_files: c_int,
    buf: UnsafePointer[c_char, MutExternalOrigin],
    size: c_int,
) -> c_int:
    return external_call["av_sdp_create", c_int](ac, n_files, buf, size)


fn av_match_ext(
    mut filename: String,
    mut extensions: String,
) -> c_int:
    var filename_ptr = filename.as_c_string_slice().unsafe_ptr().as_immutable()
    var extensions_ptr = (
        extensions.as_c_string_slice().unsafe_ptr().as_immutable()
    )
    return external_call["av_match_ext", c_int](filename_ptr, extensions_ptr)


fn avformat_query_codec(
    ofmt: UnsafePointer[AVOutputFormat, ImmutExternalOrigin],
    codec_id: AVCodecID.ENUM_DTYPE,
    std_compliance: c_int,
) -> c_int:
    return external_call["avformat_query_codec", c_int](
        ofmt, codec_id, std_compliance
    )


# Get the tables mapping RIFF FourCCs for video to libavcodec AVCodecID. The
# tables are meant to be passed to av_codec_get_id()/av_codec_get_tag() as in the
# following code:
# @code
# uint32_t tag = MKTAG('H', '2', '6', '4');
# const struct AVCodecTag *table[] = { avformat_get_riff_video_tags(), 0 };
# enum AVCodecID id = av_codec_get_id(table, tag);
# @endcode
fn avformat_get_riff_video_tags() -> (
    UnsafePointer[AVCodecTag, ImmutExternalOrigin]
):
    return external_call[
        "avformat_get_riff_video_tags",
        UnsafePointer[AVCodecTag, ImmutExternalOrigin],
    ]()


fn avformat_get_riff_audio_tags() -> (
    UnsafePointer[AVCodecTag, ImmutExternalOrigin]
):
    return external_call[
        "avformat_get_riff_audio_tags",
        UnsafePointer[AVCodecTag, ImmutExternalOrigin],
    ]()


fn avformat_get_mov_video_tags() -> (
    UnsafePointer[AVCodecTag, ImmutExternalOrigin]
):
    return external_call[
        "avformat_get_mov_video_tags",
        UnsafePointer[AVCodecTag, ImmutExternalOrigin],
    ]()


fn avformat_get_mov_audio_tags() -> (
    UnsafePointer[AVCodecTag, ImmutExternalOrigin]
):
    return external_call[
        "avformat_get_mov_audio_tags",
        UnsafePointer[AVCodecTag, ImmutExternalOrigin],
    ]()


fn av_guess_sample_aspect_ratio(
    format: UnsafePointer[AVFormatContext, MutExternalOrigin],
    stream: UnsafePointer[AVStream, MutExternalOrigin],
    frame: UnsafePointer[AVFrame, MutExternalOrigin],
) -> AVRational:
    return external_call["av_guess_sample_aspect_ratio", AVRational](
        format, stream, frame
    )


fn av_guess_frame_rate(
    ctx: UnsafePointer[AVFormatContext, MutExternalOrigin],
    stream: UnsafePointer[AVStream, MutExternalOrigin],
    frame: UnsafePointer[AVFrame, MutExternalOrigin],
) -> AVRational:
    return external_call["av_guess_frame_rate", AVRational](ctx, stream, frame)


fn avformat_match_stream_specifier(
    s: UnsafePointer[AVFormatContext, MutExternalOrigin],
    st: UnsafePointer[AVStream, MutExternalOrigin],
    # spec: UnsafePointer[c_char, ImmutExternalOrigin],
    mut spec: String,
) -> c_int:
    var spec_ptr = spec.as_c_string_slice().unsafe_ptr().as_immutable()
    return external_call["avformat_match_stream_specifier", c_int](
        s, st, spec_ptr
    )


fn avformat_queue_attached_pictures(
    s: UnsafePointer[AVFormatContext, MutExternalOrigin]
) -> c_int:
    return external_call["avformat_queue_attached_pictures", c_int](s)


# Note: this section is in the original header file, however is being deprecated.
# AVTimebaseSource
# avformat_transfer_internal_stream_timing_info
# av_stream_get_codec_timebase
# Are all behind a macro flag with APIs that are being deprecated.
