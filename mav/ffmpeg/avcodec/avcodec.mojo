"See https://www.ffmpeg.org/doxygen/8.0/avcodec_8h.html."
from std.ffi import (
    c_int,
    c_float,
    c_char,
    c_long_long,
    c_uchar,
    c_ushort,
    c_ulong_long,
    c_uint,
    c_size_t,
    external_call,
)
from mav._clib import TrivialOptionalField
from std.reflection import get_type_name
from mav.ffmpeg.avutil.avutil import AVMediaType
from mav.ffmpeg.avcodec.codec_id import AVCodecID
from mav.ffmpeg.avutil.pixfmt import AVPixelFormat
from mav.ffmpeg.avcodec.codec import AVCodec
from mav.ffmpeg.avutil.dict import AVDictionary
from mav.ffmpeg.avutil.frame import AVFrame
from mav.ffmpeg.avutil.log import AVClass
from mav.ffmpeg.avutil.rational import AVRational
from mav.ffmpeg.avutil.pixfmt import (
    AVPixelFormat,
    AVColorRange,
    AVColorPrimaries,
    AVColorTransferCharacteristic,
    AVColorSpace,
    AVChromaLocation,
)
from mav.ffmpeg.avcodec.defs import (
    AVFieldOrder,
    AVAudioServiceType,
    AVDiscard,
)
from mav.ffmpeg.avutil.buffer import AVBufferRef
from mav.ffmpeg.avutil.samplefmt import AVSampleFormat
from mav.ffmpeg.avutil.channel_layout import AVChannelLayout
from mav.ffmpeg.avcodec.packet import AVPacket, AVPacketSideData
from mav.ffmpeg.avutil.frame import AVFrameSideData
from mav.ffmpeg.avcodec.codec_desc import AVCodecDescriptor
from mav.ffmpeg.avcodec.codec_par import AVCodecParameters
from std.utils import StaticTuple
from mav.mojo_compat import (
    reflection_write_to_but_handle_static_tuples,
)


@fieldwise_init
struct RcOverride(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structRcOverride.html."
    var start_frame: c_int
    var end_frame: c_int
    var qscale: c_int
    var quality_factor: c_float


########################################################
####### Encoding support section #######################
########################################################

comptime AV_CODEC_FLAG_UNALIGNED = c_int(1 << 0)

comptime AV_CODEC_FLAG_QSCALE = c_int(1 << 1)
comptime AV_CODEC_FLAG_4MV = c_int(1 << 2)
comptime AV_CODEC_FLAG_OUTPUT_CORRUPT = c_int(1 << 3)
"See https://www.ffmpeg.org/doxygen/8.0/group__lavc__core.html#gad406c2774f1334e474256c7f04e1345e."
comptime AV_CODEC_FLAG_QPEL = c_int(1 << 4)
comptime AV_CODEC_FLAG_RECON_FRAME = c_int(1 << 6)
comptime AV_CODEC_FLAG_COPY_OPAQUE = c_int(1 << 7)

comptime AV_CODEC_FLAG_FRAME_DURATION = c_int(1 << 8)

comptime AV_CODEC_FLAG_PASS1 = c_int(1 << 9)
comptime AV_CODEC_FLAG_PASS2 = c_int(1 << 10)
comptime AV_CODEC_FLAG_LOOP_FILTER = c_int(1 << 11)
comptime AV_CODEC_FLAG_GRAY = c_int(1 << 13)
comptime AV_CODEC_FLAG_PSNR = c_int(1 << 15)
comptime AV_CODEC_FLAG_INTERLACED_DCT = c_int(1 << 18)
comptime AV_CODEC_FLAG_LOW_DELAY = c_int(1 << 19)
comptime AV_CODEC_FLAG_GLOBAL_HEADER = c_int(1 << 22)
comptime AV_CODEC_FLAG_BITEXACT = c_int(1 << 23)
# Fx: Flag for H.263+ extra options
comptime AV_CODEC_FLAG_AC_PRED = c_int(1 << 24)
comptime AV_CODEC_FLAG_CLOSED_GOP = c_int(1 << 31)
comptime AV_CODEC_FLAG2_FAST = c_int(1 << 0)
comptime AV_CODEC_FLAG2_NO_OUTPUT = c_int(1 << 2)
comptime AV_CODEC_FLAG2_LOCAL_HEADER = c_int(1 << 3)
comptime AV_CODEC_FLAG2_CHUNKS = c_int(1 << 15)
comptime AV_CODEC_FLAG2_IGNORE_CROP = c_int(1 << 16)
comptime AV_CODEC_FLAG2_SHOW_ALL = c_int(1 << 22)
comptime AV_CODEC_FLAG2_EXPORT_MVS = c_int(1 << 28)
comptime AV_CODEC_FLAG2_SKIP_MANUAL = c_int(1 << 29)
comptime AV_CODEC_FLAG2_RO_FLUSH_NOOP = c_int(1 << 30)

# TODO: The header has it as 1U << 31. Whats the difference?????
comptime AV_CODEC_FLAG2_ICC_PROFILES = c_int(1 << 31)

########################################################
# Before intializing AVCodecContext, these flags can be set in
# AVCodecContext.export_side_data.
########################################################

comptime AV_CODEC_EXPORT_DATA_MVS = c_int(1 << 0)
"See https://www.ffmpeg.org/doxygen/8.0/group__lavc__core.html#gace654396302da34e598d4192403326ea."
comptime AV_CODEC_EXPORT_DATA_PRFT = c_int(1 << 1)
"See https://www.ffmpeg.org/doxygen/8.0/group__lavc__core.html#ga3f723db5c7db407c53a61ddfed1f55d8."
comptime AV_CODEC_EXPORT_DATA_VIDEO_ENC_PARAMS = c_int(1 << 2)
"See https://www.ffmpeg.org/doxygen/8.0/group__lavc__core.html#gaf2ee3be17d31e2e6ef8b8096e7789ec5."
comptime AV_CODEC_EXPORT_DATA_FILM_GRAIN = c_int(1 << 3)
"See https://www.ffmpeg.org/doxygen/8.0/group__lavc__core.html#ga8aeef83bf8b28d1e06d67b50c9d3a994."
comptime AV_CODEC_EXPORT_DATA_ENHANCEMENTS = c_int(1 << 4)
"See https://www.ffmpeg.org/doxygen/8.0/group__lavc__core.html#ga4e1603e9861297330284d530796a14e1."

comptime AV_GET_BUFFER_FLAG_REF = c_int(1 << 0)
comptime AV_GET_ENCODE_BUFFER_FLAG_REF = c_int(1 << 0)

#########################################################
########## Main external API structure ##################
#########################################################

comptime FF_API_CODEC_PROPS = False


comptime AVCodecInternal = OpaquePointer[MutExternalOrigin]


@fieldwise_init
struct AVCodecContext(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVCodecContext.html."

    var av_class: UnsafePointer[AVClass, origin=ImmutExternalOrigin]
    var log_level_offset: c_int
    var codec_type: AVMediaType.ENUM_DTYPE
    var codec: UnsafePointer[AVCodec, origin=ImmutExternalOrigin]
    var codec_id: AVCodecID.ENUM_DTYPE

    var codec_tag: c_ushort
    var priv_data: OpaquePointer[MutExternalOrigin]

    var internal: UnsafePointer[AVCodecInternal, origin=ImmutExternalOrigin]
    var opaque: OpaquePointer[MutExternalOrigin]
    var bit_rate: c_long_long
    var flags: c_int
    var flags2: c_int

    var extradata: UnsafePointer[c_char, ImmutExternalOrigin]
    var extradata_size: c_int

    var time_base: AVRational
    var pkt_timebase: AVRational
    var framerate: AVRational
    var delay: c_int
    # Video only
    var width: c_int
    var height: c_int
    var coded_width: c_int
    var coded_height: c_int

    var sample_aspect_ratio: AVRational
    var pix_fmt: AVPixelFormat.ENUM_DTYPE
    var sw_pix_fmt: AVPixelFormat.ENUM_DTYPE
    var color_primaries: AVColorPrimaries.ENUM_DTYPE
    var color_trc: AVColorTransferCharacteristic.ENUM_DTYPE
    var color_space: AVColorSpace.ENUM_DTYPE
    var color_range: AVColorRange.ENUM_DTYPE
    var chroma_sample_location: AVChromaLocation.ENUM_DTYPE
    var field_order: AVFieldOrder.ENUM_DTYPE
    var refs: c_int
    var has_b_frames: c_int
    var slice_flags: c_int
    comptime SLICE_FLAG_CODED_ORDER = Int(0x0001)
    comptime SLICE_FLAG_ALLOW_FIELD = Int(0x0002)
    comptime SLICE_FLAG_ALLOW_PLANE = Int(0x0004)
    var draw_horiz_band: UnsafePointer[
        fn(
            s: UnsafePointer[Self, MutExternalOrigin],
            src: UnsafePointer[AVFrame, ImmutExternalOrigin],
            offset: StaticTuple[c_int, AVFrame.AV_NUM_DATA_POINTERS],
            y: c_int,
            type: c_int,
            height: c_int,
        ) -> NoneType, MutExternalOrigin
    ]
    var get_format: UnsafePointer[
        fn(
            s: UnsafePointer[Self, MutExternalOrigin],
            fmt: UnsafePointer[AVPixelFormat.ENUM_DTYPE, ImmutExternalOrigin],
        ) -> AVPixelFormat.ENUM_DTYPE, MutExternalOrigin
    ]
    var max_b_frames: c_int
    var b_quant_factor: c_float
    var b_quant_offset: c_float
    var i_quant_factor: c_float
    var i_quant_offset: c_float
    var lumi_masking: c_float
    var temporal_cplx_masking: c_float
    var spatial_cplx_masking: c_float
    var p_masking: c_float
    var dark_masking: c_float
    var nsse_weight: c_int
    var me_cmp: c_int
    var me_sub_cmp: c_int
    var mb_cmp: c_int
    var ildct_cmp: c_int
    # TODO: Actually source the definitions for this. The original header
    # didn't have any comments.
    comptime FF_CMP_SAD = Int(0)
    comptime FF_CMP_SSE = Int(1)
    comptime FF_CMP_SATD = Int(2)
    comptime FF_CMP_DCT = Int(3)
    comptime FF_CMP_PSNR = Int(4)
    comptime FF_CMP_BIT = Int(5)
    comptime FF_CMP_RD = Int(6)
    comptime FF_CMP_LUMA = Int(7)
    comptime FF_CMP_CHROMA = Int(256)

    var dia_size: c_int
    var last_predictor_count: c_int
    var me_pre_cmp: c_int
    var pre_dia_size: c_int
    var me_subpel_quality: c_int
    var me_range: c_int
    var mb_decision: c_int
    comptime FF_MB_DECISION_SIMPLE = Int(0)
    comptime FF_MB_DECISION_BITS = Int(1)
    comptime FF_MB_DECISION_RD = Int(2)

    var intra_matrix: UnsafePointer[c_ushort, ImmutExternalOrigin]
    var inter_matrix: UnsafePointer[c_ushort, ImmutExternalOrigin]
    var chroma_intra_matrix: UnsafePointer[c_ushort, ImmutExternalOrigin]
    var intra_dc_precision: c_int

    var mb_lmin: c_int
    var mb_lmax: c_int
    var bidir_refine: c_int

    var keyint_min: c_int
    var gop_size: c_int
    var mv0_threshold: c_int
    var slices: c_int
    # Audio only
    var sample_rate: c_int
    var sample_fmt: AVSampleFormat.ENUM_DTYPE
    var ch_layout: AVChannelLayout
    # The following data should not be initialized.
    var frame_size: c_int
    var block_align: c_int
    var cutoff: c_int
    var audio_service_type: AVAudioServiceType.ENUM_DTYPE
    var request_sample_fmt: AVSampleFormat.ENUM_DTYPE

    var initial_padding: c_int
    var trailing_padding: c_int
    var seek_preroll: c_int

    var get_buffer2: UnsafePointer[
        fn(
            s: UnsafePointer[Self, MutExternalOrigin],
            frame: UnsafePointer[AVFrame, MutExternalOrigin],
            flags: c_int,
        ) -> c_int, MutExternalOrigin
    ]

    # Encoding parameters
    var bit_rate_tolerance: c_int
    var global_quality: c_int
    var compression_level: c_int
    comptime FF_COMPRESSION_DEFAULT = Int(-1)
    var qcompress: c_float
    var qblur: c_float
    var qmin: c_int
    var qmax: c_int
    var max_qdiff: c_int
    var rc_buffer_size: c_int
    var rc_override_count: c_int
    var rc_override: UnsafePointer[RcOverride, ImmutExternalOrigin]
    var rc_max_rate: c_long_long
    var rc_min_rate: c_long_long
    var rc_max_available_vbv_use: c_float
    var rc_min_vbv_overflow_use: c_float
    var rc_initial_buffer_occupancy: c_int
    var trellis: c_int
    var stats_out: UnsafePointer[c_char, MutExternalOrigin]
    var stats_in: UnsafePointer[c_char, MutExternalOrigin]
    var workaround_bugs: c_int
    comptime FF_BUG_AUTODETECT = Int(1)
    comptime FF_BUG_XVID_ILACE = Int(4)
    comptime FF_BUG_UMP4 = Int(8)
    comptime FF_BUG_NO_PADDING = Int(16)
    comptime FF_BUG_AMV = Int(32)
    comptime FF_BUG_QPEL_CHROMA = Int(64)
    comptime FF_BUG_STD_QPEL = Int(128)
    comptime FF_BUG_QPEL_CHROMA2 = Int(256)
    comptime FF_BUG_DIRECT_BLOCKSIZE = Int(512)
    comptime FF_BUG_EDGE = Int(1024)
    comptime FF_BUG_HPEL_CHROMA = Int(2048)
    comptime FF_BUG_DC_CLIP = Int(4096)
    comptime FF_BUG_MS = Int(8192)
    comptime FF_BUG_TRUNCATED = Int(16384)
    comptime FF_BUG_IEDGE = Int(32768)

    var strict_std_compliance: c_int

    var error_concealment: c_int
    comptime FF_EC_GUESS_MVS = Int(1)
    comptime FF_EC_DEBLOCK = Int(2)
    comptime FF_EC_FAVOR_INTER = Int(256)

    var debug: c_int
    comptime FF_DEBUG_PICT_INFO = Int(1)
    comptime FF_DEBUG_RC = Int(2)
    comptime FF_DEBUG_BITSTREAM = Int(4)
    comptime FF_DEBUG_MB_TYPE = Int(8)
    comptime FF_DEBUG_QP = Int(16)
    comptime FF_DEBUG_DCT_COEFF = Int(0x00000040)
    comptime FF_DEBUG_SKIP = Int(0x00000080)
    comptime FF_DEBUG_STARTCODE = Int(0x00000100)
    comptime FF_DEBUG_ER = Int(0x00000400)
    comptime FF_DEBUG_MMCO = Int(0x00000800)
    comptime FF_DEBUG_BUGS = Int(0x00001000)
    comptime FF_DEBUG_BUFFERS = Int(0x00008000)
    comptime FF_DEBUG_THREADS = Int(0x00010000)
    comptime FF_DEBUG_GREEN_MD = Int(0x00800000)
    comptime FF_DEBUG_NOMC = Int(0x01000000)

    var err_recognition: c_int

    var hwaccel: UnsafePointer[AVHWAccel, ImmutExternalOrigin]

    var hwaccel_context: OpaquePointer[MutExternalOrigin]

    var hw_frames_ctx: UnsafePointer[AVBufferRef, MutExternalOrigin]
    var hw_device_ctx: UnsafePointer[AVBufferRef, MutExternalOrigin]
    var hwaccel_flags: c_int
    var extra_hw_frames: c_int
    var error: StaticTuple[c_ulong_long, AVFrame.AV_NUM_DATA_POINTERS]
    var dct_algo: c_int
    comptime FF_DCT_AUTO = Int(0)
    comptime FF_DCT_FASTINT = Int(1)
    comptime FF_DCT_INT = Int(2)
    comptime FF_DCT_MMX = Int(3)
    comptime FF_DCT_ALTIVEC = Int(5)
    comptime FF_DCT_FAAN = Int(6)
    comptime FF_DCT_NEON = Int(7)

    var idct_algo: c_int

    comptime FF_IDCT_AUTO = Int(0)
    comptime FF_IDCT_INT = Int(1)
    comptime FF_IDCT_SIMPLE = Int(2)
    comptime FF_IDCT_SIMPLEMMX = Int(3)
    comptime FF_IDCT_ARM = Int(7)
    comptime FF_IDCT_ALTIVEC = Int(8)
    comptime FF_IDCT_SIMPLEARM = Int(10)
    comptime FF_IDCT_XVID = Int(14)
    comptime FF_IDCT_SIMPLEARMV5TE = Int(16)
    comptime FF_IDCT_SIMPLEARMV6 = Int(17)
    comptime FF_IDCT_FAAN = Int(20)
    comptime FF_IDCT_SIMPLENEON = Int(22)
    comptime FF_IDCT_SIMPLEAUTO = Int(128)

    var bits_per_coded_sample: c_int

    var bits_per_raw_sample: c_int

    var thread_count: c_int

    var thread_type: c_int
    comptime FF_THREAD_FRAME = Int(1)
    comptime FF_THREAD_SLICE = Int(2)

    var active_thread_type: c_int

    var execute: UnsafePointer[
        fn(
            c: UnsafePointer[AVCodecContext, MutExternalOrigin],
            func: fn(
                c2: UnsafePointer[AVCodecContext, MutExternalOrigin],
                arg: OpaquePointer[MutExternalOrigin],
            ) -> c_int,
            arg2: OpaquePointer[MutExternalOrigin],
            ret: UnsafePointer[c_int, MutExternalOrigin],
            count: c_int,
            size: c_int,
        ) -> c_int, MutExternalOrigin
    ]

    var execute2: UnsafePointer[
        fn(
            c: UnsafePointer[AVCodecContext, MutExternalOrigin],
            func2: fn(
                c2: UnsafePointer[AVCodecContext, MutExternalOrigin],
                arg: OpaquePointer[MutExternalOrigin],
                jobnr: c_int,
                threadnr: c_int,
            ) -> c_int,
            arg2: OpaquePointer[MutExternalOrigin],
            ret: UnsafePointer[c_int, MutExternalOrigin],
            count: c_int,
        ) -> c_int, MutExternalOrigin
    ]

    var profile: c_int

    var level: c_int

    var properties: TrivialOptionalField[FF_API_CODEC_PROPS, c_int]
    comptime FF_CODEC_PROPERTY_LOSSLESS = Int(1)
    comptime FF_CODEC_PROPERTY_CLOSED_CAPTIONS = Int(2)
    comptime FF_CODEC_PROPERTY_FILM_GRAIN = Int(4)

    var skip_loop_filter: AVDiscard.ENUM_DTYPE
    var skip_idct: AVDiscard.ENUM_DTYPE
    var skip_frame: AVDiscard.ENUM_DTYPE
    var skip_alpha: c_int

    var skip_top: c_int
    var skip_bottom: c_int
    var lowres: c_int
    var codec_descriptor: UnsafePointer[AVCodecDescriptor, ImmutExternalOrigin]

    var sub_charenc: UnsafePointer[c_char, MutExternalOrigin]

    var sub_charenc_mode: c_int
    comptime FF_SUB_CHARENC_MODE_DO_NOTHING = Int(-1)
    comptime FF_SUB_CHARENC_MODE_AUTOMATIC = Int(0)
    comptime FF_SUB_CHARENC_MODE_PRE_DECODER = Int(1)
    comptime FF_SUB_CHARENC_MODE_IGNORE = Int(2)

    var subtitle_header_size: c_int
    var subtitle_header: UnsafePointer[c_uchar, MutExternalOrigin]

    var dump_separator: UnsafePointer[c_uchar, MutExternalOrigin]
    var codec_whitelist: UnsafePointer[c_char, MutExternalOrigin]

    var coded_side_data: UnsafePointer[AVPacketSideData, MutExternalOrigin]
    var nb_coded_side_data: c_int

    var export_side_data: c_int

    var max_pixels: c_long_long

    var apply_cropping: c_int

    var discard_damaged_percentage: c_int

    var max_samples: c_long_long

    var get_encode_buffer: UnsafePointer[
        fn(
            s: UnsafePointer[AVCodecContext, MutExternalOrigin],
            pkt: UnsafePointer[AVPacket, MutExternalOrigin],
            flags: c_int,
        ) -> c_int, MutExternalOrigin
    ]

    var frame_num: c_long_long

    var side_data_prefer_packet: UnsafePointer[c_int, MutExternalOrigin]

    var nb_side_data_prefer_packet: c_uint

    var decoded_side_data: UnsafePointer[AVFrameSideData, MutExternalOrigin]
    var nb_decoded_side_data: c_int

    fn write_to(self, mut writer: Some[Writer]):
        @always_inline
        fn call_write_to[
            FieldType: Writable
        ](field: FieldType, mut writer: type_of(writer)):
            field.write_to(writer)

        reflection_write_to_but_handle_static_tuples[f=call_write_to](
            self, writer
        )


@fieldwise_init
struct AVHWAccel(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVHWAccel.html."

    var name: UnsafePointer[c_char, ImmutExternalOrigin]

    var type: AVMediaType.ENUM_DTYPE

    var id: AVCodecID.ENUM_DTYPE

    var pix_fmt: AVPixelFormat.ENUM_DTYPE

    var capabilities: c_int


comptime AV_HWACCEL_CODEC_CAP_EXPERIMENTAL = c_int(0x0200)
comptime AV_HWACCEL_FLAG_IGNORE_LEVEL = c_int(1 << 0)

comptime AV_HWACCEL_FLAG_ALLOW_HIGH_DEPTH = c_int(1 << 1)

comptime AV_HWACCEL_FLAG_ALLOW_PROFILE_MISMATCH = c_int(1 << 2)

comptime AV_HWACCEL_FLAG_UNSAFE_OUTPUT = c_int(1 << 3)


@fieldwise_init
struct AVSubtitleType(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var value: Self.ENUM_DTYPE

    comptime SUBTITLE_NONE = Self(0)
    comptime SUBTITLE_BITMAP = Self(1)
    comptime SUBTITLE_TEXT = Self(2)
    comptime SUBTITLE_ASS = Self(3)


comptime AV_SUBTITLE_FLAG_FORCED = c_int(0x00000001)


@fieldwise_init
struct AVSubtitleRect(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVSubtitleRect.html."
    var x: c_int
    var y: c_int
    var w: c_int
    var h: c_int
    var nb_colors: c_int
    var data: UnsafePointer[c_uchar, MutExternalOrigin]
    var linesize: StaticTuple[c_int, 4]
    var flags: c_int
    var type: AVSubtitleType.ENUM_DTYPE

    var text: UnsafePointer[c_char, MutExternalOrigin]
    var ass: UnsafePointer[c_char, MutExternalOrigin]


@fieldwise_init
struct AVSubtitle(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVSubtitle.html."
    var format: c_ushort
    var start_display_time: c_uint
    var end_display_time: c_uint
    var num_rects: c_uint
    var rects: UnsafePointer[
        UnsafePointer[AVSubtitleRect, MutExternalOrigin], MutExternalOrigin
    ]
    var pts: c_long_long


fn avcodec_version() -> c_uint:
    return external_call["avcodec_version", c_uint]()


fn avcodec_configuration() -> UnsafePointer[c_char, ImmutExternalOrigin]:
    return external_call[
        "avcodec_configuration", UnsafePointer[c_char, ImmutExternalOrigin]
    ]()


fn avcodec_license() -> UnsafePointer[c_char, ImmutExternalOrigin]:
    return external_call[
        "avcodec_license", UnsafePointer[c_char, ImmutExternalOrigin]
    ]()


fn avcodec_alloc_context3(
    codec: UnsafePointer[AVCodec, ImmutExternalOrigin]
) -> UnsafePointer[AVCodecContext, MutExternalOrigin]:
    return external_call[
        "avcodec_alloc_context3",
        UnsafePointer[AVCodecContext, MutExternalOrigin],
    ](codec)


fn avcodec_free_context(
    avctx: UnsafePointer[
        UnsafePointer[AVCodecContext, MutExternalOrigin], MutExternalOrigin
    ]
):
    external_call["avcodec_free_context", NoneType](avctx)


fn avcodec_free_context(
    avctx: UnsafePointer[AVCodecContext, MutExternalOrigin]
):
    var avctx_ptr = alloc[type_of(avctx)](1)
    avctx_ptr[] = avctx
    avcodec_free_context(avctx_ptr)
    avctx_ptr.free()


fn avcodec_get_class() -> UnsafePointer[AVClass, ImmutExternalOrigin]:
    return external_call[
        "avcodec_get_class", UnsafePointer[AVClass, ImmutExternalOrigin]
    ]()


fn avcodec_get_subtitle_rect_class() -> (
    UnsafePointer[AVClass, ImmutExternalOrigin]
):
    return external_call[
        "avcodec_get_subtitle_rect_class",
        UnsafePointer[AVClass, ImmutExternalOrigin],
    ]()


fn avcodec_parameters_from_context(
    par: UnsafePointer[AVCodecParameters, MutExternalOrigin],
    codec: UnsafePointer[AVCodecContext, ImmutExternalOrigin],
) -> c_int:
    return external_call["avcodec_parameters_from_context", c_int](par, codec)


fn avcodec_parameters_to_context(
    codec: UnsafePointer[AVCodecContext, MutExternalOrigin],
    par: UnsafePointer[AVCodecParameters, ImmutExternalOrigin],
) -> c_int:
    return external_call["avcodec_parameters_to_context", c_int](codec, par)


fn avcodec_open2(
    context: UnsafePointer[AVCodecContext, MutExternalOrigin],
    codec: UnsafePointer[AVCodec, ImmutExternalOrigin],
    options: UnsafePointer[
        UnsafePointer[AVDictionary, MutExternalOrigin], MutExternalOrigin
    ],
) -> c_int:
    return external_call["avcodec_open2", c_int](context, codec, options)


fn avsubtitle_free(sub: UnsafePointer[AVSubtitle, MutExternalOrigin]):
    external_call["avsubtitle_free", NoneType](sub)


fn avcodec_default_get_buffer2(
    s: UnsafePointer[AVCodecContext, MutExternalOrigin],
    frame: UnsafePointer[AVFrame, MutExternalOrigin],
    flags: c_int,
) -> c_int:
    return external_call["avcodec_default_get_buffer2", c_int](s, frame, flags)


fn avcodec_default_get_encode_buffer(
    s: UnsafePointer[AVCodecContext, MutExternalOrigin],
    pkt: UnsafePointer[AVPacket, MutExternalOrigin],
    flags: c_int,
) -> c_int:
    return external_call["avcodec_default_get_encode_buffer", c_int](
        s, pkt, flags
    )


fn avcodec_align_dimensions(
    s: UnsafePointer[AVCodecContext, MutExternalOrigin],
    width: UnsafePointer[c_int, MutExternalOrigin],
    height: UnsafePointer[c_int, MutExternalOrigin],
):
    external_call["avcodec_align_dimensions", NoneType](s, width, height)


fn avcodec_align_dimensions2(
    s: UnsafePointer[AVCodecContext, MutExternalOrigin],
    width: UnsafePointer[c_int, MutExternalOrigin],
    height: UnsafePointer[c_int, MutExternalOrigin],
    linesize_align: UnsafePointer[c_int, MutExternalOrigin],
):
    external_call["avcodec_align_dimensions2", NoneType](
        s, width, height, linesize_align
    )


fn avcodec_decode_subtitle2(
    avctx: UnsafePointer[AVCodecContext, MutExternalOrigin],
    sub: UnsafePointer[AVSubtitle, MutExternalOrigin],
    got_sub_ptr: UnsafePointer[c_int, MutExternalOrigin],
    avpkt: UnsafePointer[AVPacket, ImmutExternalOrigin],
) -> c_int:
    return external_call["avcodec_decode_subtitle2", c_int](
        avctx, sub, got_sub_ptr, avpkt
    )


fn avcodec_send_packet(
    avctx: UnsafePointer[AVCodecContext, MutExternalOrigin],
    avpkt: UnsafePointer[AVPacket, ImmutExternalOrigin],
) -> c_int:
    return external_call["avcodec_send_packet", c_int](avctx, avpkt)


fn avcodec_receive_frame(
    avctx: UnsafePointer[AVCodecContext, MutExternalOrigin],
    frame: UnsafePointer[AVFrame, MutExternalOrigin],
) -> c_int:
    return external_call["avcodec_receive_frame", c_int](avctx, frame)


fn avcodec_send_frame(
    avctx: UnsafePointer[AVCodecContext, MutExternalOrigin],
    frame: UnsafePointer[AVFrame, ImmutExternalOrigin],
) -> c_int:
    return external_call["avcodec_send_frame", c_int](avctx, frame)


fn avcodec_receive_packet(
    avctx: UnsafePointer[AVCodecContext, MutExternalOrigin],
    pkt: UnsafePointer[AVPacket, MutExternalOrigin],
) -> c_int:
    return external_call["avcodec_receive_packet", c_int](avctx, pkt)


fn avcodec_get_hw_frames_parameters(
    avctx: UnsafePointer[AVCodecContext, MutExternalOrigin],
    device_ref: UnsafePointer[AVBufferRef, ImmutExternalOrigin],
    hw_pix_fmt: AVPixelFormat.ENUM_DTYPE,
    out_frames_ref: UnsafePointer[
        UnsafePointer[AVBufferRef, MutExternalOrigin], MutExternalOrigin
    ],
) -> c_int:
    return external_call["avcodec_get_hw_frames_parameters", c_int](
        avctx, device_ref, hw_pix_fmt, out_frames_ref
    )


@fieldwise_init
struct AVCodecConfig(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var _value: Self.ENUM_DTYPE

    comptime AV_CODEC_CONFIG_PIX_FORMAT = Self(0)
    comptime AV_CODEC_CONFIG_FRAME_RATE = Self(1)
    comptime AV_CODEC_CONFIG_SAMPLE_RATE = Self(2)
    comptime AV_CODEC_CONFIG_SAMPLE_FORMAT = Self(3)
    comptime AV_CODEC_CONFIG_CHANNEL_LAYOUT = Self(4)
    comptime AV_CODEC_CONFIG_COLOR_RANGE = Self(5)
    comptime AV_CODEC_CONFIG_COLOR_SPACE = Self(6)


fn avcodec_get_supported_config(
    avctx: UnsafePointer[AVCodecContext, ImmutExternalOrigin],
    codec: UnsafePointer[AVCodec, ImmutExternalOrigin],
    config: AVCodecConfig.ENUM_DTYPE,
    flags: c_uint,
    out_configs: UnsafePointer[
        OpaquePointer[ImmutExternalOrigin], MutExternalOrigin
    ],
    out_num: UnsafePointer[c_int, MutExternalOrigin],
) -> c_int:
    return external_call["avcodec_get_supported_config", c_int](
        avctx, codec, config, flags, out_configs, out_num
    )


@fieldwise_init
struct AVPictureStructure(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var _value: Self.ENUM_DTYPE

    comptime AV_PICTURE_STRUCTURE_UNKNOWN = Self(0)
    comptime AV_PICTURE_STRUCTURE_TOP_FIELD = Self(1)
    comptime AV_PICTURE_STRUCTURE_BOTTOM_FIELD = Self(2)
    comptime AV_PICTURE_STRUCTURE_FRAME = Self(3)


@fieldwise_init
struct AVCodecParserContext(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVCodecParserContext.html."
    comptime AV_PARSER_PTS_NB = Int(4)
    comptime PARSER_FLAG_COMPLETE_FRAMES = Int(0x0001)
    comptime PARSER_FLAG_ONCE = Int(0x0002)
    comptime PARSER_FLAG_FETCHED_OFFSET = Int(0x0004)
    comptime PARSER_FLAG_USE_CODEC_TS = Int(0x1000)

    var priv_data: OpaquePointer[MutExternalOrigin]
    var parser: UnsafePointer[AVCodecParser, origin=ImmutExternalOrigin]
    var frame_offset: c_long_long
    var cur_offset: c_long_long
    var next_frame_offset: c_long_long
    # Video info

    # NOTE: This is a note in the original codebase taking about moving this
    # field back to AVCodecContext.
    #  XXX: Put it back in AVCodecContext
    var pict_type: c_int
    # XXX: Put it back in AVCodecContext
    var repeat_pict: c_int
    var pts: c_long_long
    var dts: c_long_long
    # Private data
    var last_pts: c_long_long
    var last_dts: c_long_long

    var cur_frame_start_index: c_int
    var cur_frame_offset: StaticTuple[c_long_long, Self.AV_PARSER_PTS_NB]
    var cur_frame_pts: StaticTuple[c_long_long, Self.AV_PARSER_PTS_NB]
    var cur_frame_dts: StaticTuple[c_long_long, Self.AV_PARSER_PTS_NB]
    var flags: c_int
    var offset: c_long_long
    var cur_frame_end: StaticTuple[c_long_long, Self.AV_PARSER_PTS_NB]
    var key_frame: c_int
    # Timestamp generation support:
    var dts_sync_point: c_int
    var dts_ref_dts_delta: c_int
    var pts_dts_delta: c_int
    var cur_frame_pos: StaticTuple[c_long_long, Self.AV_PARSER_PTS_NB]
    var pos: c_long_long
    var last_pos: c_long_long
    var duration: c_int
    var field_order: AVFieldOrder.ENUM_DTYPE

    var picture_structure: AVPictureStructure.ENUM_DTYPE
    var output_picture_number: c_int
    var width: c_int
    var height: c_int

    var coded_width: c_int
    var coded_height: c_int
    var format: c_int

    fn write_to(self, mut writer: Some[Writer]):
        @always_inline
        fn call_write_to[
            FieldType: Writable
        ](field: FieldType, mut writer: type_of(writer)):
            field.write_to(writer)

        reflection_write_to_but_handle_static_tuples[f=call_write_to](
            self, writer
        )


@fieldwise_init
struct AVCodecParser(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVCodecParser.html."
    var codec_ids: StaticTuple[c_int, 7]
    var priv_data_size: c_int
    var parser_init: fn(
        s: UnsafePointer[AVCodecParserContext, MutExternalOrigin]
    ) -> c_int
    var parser_parse: fn(
        s: UnsafePointer[AVCodecParserContext, MutExternalOrigin],
        avctx: UnsafePointer[AVCodecContext, MutExternalOrigin],
        poutbuf: UnsafePointer[
            UnsafePointer[c_char, ImmutExternalOrigin], ImmutExternalOrigin
        ],
        poutbuf_size: UnsafePointer[c_int, ImmutExternalOrigin],
        buf: UnsafePointer[c_char, ImmutExternalOrigin],
        buf_size: c_int,
    ) -> c_int
    var parser_close: fn(
        s: UnsafePointer[AVCodecParserContext, MutExternalOrigin]
    ) -> NoneType
    var split: fn(
        avctx: UnsafePointer[AVCodecContext, MutExternalOrigin],
        buf: UnsafePointer[c_char, ImmutExternalOrigin],
        buf_size: c_int,
    ) -> c_int


fn av_parser_iterate(
    opaque: UnsafePointer[OpaquePointer[MutExternalOrigin], MutExternalOrigin]
) -> UnsafePointer[AVCodecParser, ImmutExternalOrigin]:
    return external_call[
        "av_parser_iterate", UnsafePointer[AVCodecParser, ImmutExternalOrigin]
    ](opaque)


fn av_parser_init(
    codec_id: AVCodecID.ENUM_DTYPE,
) -> UnsafePointer[AVCodecParserContext, MutExternalOrigin]:
    return external_call[
        "av_parser_init", UnsafePointer[AVCodecParserContext, MutExternalOrigin]
    ](codec_id)


fn av_parser_parse2(
    s: UnsafePointer[AVCodecParserContext, MutExternalOrigin],
    avctx: UnsafePointer[AVCodecContext, MutExternalOrigin],
    poutbuf: UnsafePointer[
        UnsafePointer[c_uchar, MutExternalOrigin], MutExternalOrigin
    ],
    poutbuf_size: UnsafePointer[c_int, MutExternalOrigin],
    buf: UnsafePointer[c_uchar, ImmutExternalOrigin],
    buf_size: c_int,
    pts: c_long_long,
    dts: c_long_long,
    pos: c_long_long,
) -> c_int:
    return external_call["av_parser_parse2", c_int](
        s, avctx, poutbuf, poutbuf_size, buf, buf_size, pts, dts, pos
    )


fn av_parser_close(s: UnsafePointer[AVCodecParserContext, MutExternalOrigin]):
    external_call["av_parser_close", NoneType](s)


fn avcodec_encode_subtitle(
    avctx: UnsafePointer[AVCodecContext, MutExternalOrigin],
    buf: UnsafePointer[c_uchar, MutExternalOrigin],
    buf_size: c_int,
    sub: UnsafePointer[AVSubtitle, ImmutExternalOrigin],
) -> c_int:
    return external_call["avcodec_encode_subtitle", c_int](
        avctx, buf, buf_size, sub
    )


fn avcodec_pix_fmt_to_codec_tag(pix_fmt: AVPixelFormat.ENUM_DTYPE) -> c_uint:
    return external_call["avcodec_pix_fmt_to_codec_tag", c_uint](pix_fmt)


fn avcodec_find_best_pix_fmt_of_list(
    pix_fmt_list: UnsafePointer[AVPixelFormat.ENUM_DTYPE, ImmutExternalOrigin],
    src_pix_fmt: AVPixelFormat.ENUM_DTYPE,
    has_alpha: c_int,
    loss_ptr: UnsafePointer[c_int, MutExternalOrigin],
) -> AVPixelFormat.ENUM_DTYPE:
    return external_call[
        "avcodec_find_best_pix_fmt_of_list", AVPixelFormat.ENUM_DTYPE
    ](pix_fmt_list, src_pix_fmt, has_alpha, loss_ptr)


fn avcodec_default_get_format(
    s: UnsafePointer[AVCodecContext, MutExternalOrigin],
    fmt: UnsafePointer[AVPixelFormat.ENUM_DTYPE, ImmutExternalOrigin],
) -> AVPixelFormat.ENUM_DTYPE:
    return external_call[
        "avcodec_default_get_format", AVPixelFormat.ENUM_DTYPE
    ](s, fmt)


fn avcodec_string(
    buf: UnsafePointer[c_char, MutExternalOrigin],
    buf_size: c_int,
    enc: UnsafePointer[AVCodecContext, ImmutExternalOrigin],
    encode: c_int,
):
    external_call["avcodec_string", NoneType](buf, buf_size, enc, encode)


fn avcodec_default_execute(
    c: UnsafePointer[AVCodecContext, MutExternalOrigin],
    func: fn(
        UnsafePointer[AVCodecContext, MutExternalOrigin],
        OpaquePointer[MutExternalOrigin],
    ) -> c_int,
    arg: OpaquePointer[MutExternalOrigin],
    ret: UnsafePointer[c_int, MutExternalOrigin],
    count: c_int,
    size: c_int,
) -> c_int:
    return external_call["avcodec_default_execute", c_int](
        c, func, arg, ret, count, size
    )


fn avcodec_default_execute2(
    c: UnsafePointer[AVCodecContext, MutExternalOrigin],
    func: fn(
        UnsafePointer[AVCodecContext, MutExternalOrigin],
        OpaquePointer[MutExternalOrigin],
        c_int,
        c_int,
    ) -> c_int,
    arg: OpaquePointer[MutExternalOrigin],
    ret: UnsafePointer[c_int, MutExternalOrigin],
    count: c_int,
) -> c_int:
    return external_call["avcodec_default_execute2", c_int](
        c, func, arg, ret, count
    )


fn avcodec_fill_audio_frame(
    frame: UnsafePointer[AVFrame, MutExternalOrigin],
    nb_channels: c_int,
    sample_fmt: AVSampleFormat.ENUM_DTYPE,
    buf: UnsafePointer[c_uchar, ImmutExternalOrigin],
    buf_size: c_int,
    align: c_int,
) -> c_int:
    return external_call["avcodec_fill_audio_frame", c_int](
        frame, nb_channels, sample_fmt, buf, buf_size, align
    )


fn avcodec_flush_buffers(
    avctx: UnsafePointer[AVCodecContext, MutExternalOrigin]
):
    external_call["avcodec_flush_buffers", NoneType](avctx)


fn av_get_audio_frame_duration(
    avctx: UnsafePointer[AVCodecContext, ImmutExternalOrigin],
    frame_bytes: c_int,
) -> c_int:
    return external_call["av_get_audio_frame_duration", c_int](
        avctx, frame_bytes
    )


fn av_fast_padded_malloc(
    ptr: OpaquePointer[MutExternalOrigin],
    size: UnsafePointer[c_uint, MutExternalOrigin],
    min_size: c_size_t,
):
    external_call["av_fast_padded_malloc", NoneType](ptr, size, min_size)


fn av_fast_padded_mallocz(
    ptr: OpaquePointer[MutExternalOrigin],
    size: UnsafePointer[c_uint, MutExternalOrigin],
    min_size: c_size_t,
):
    external_call["av_fast_padded_mallocz", NoneType](ptr, size, min_size)


fn avcodec_is_open(
    avctx: UnsafePointer[AVCodecContext, ImmutExternalOrigin]
) -> c_int:
    return external_call["avcodec_is_open", c_int](avctx)
