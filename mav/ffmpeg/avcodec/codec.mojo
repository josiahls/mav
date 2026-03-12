"See https://www.ffmpeg.org/doxygen/8.0/codec_8h.html."
from std.ffi import c_char, c_int, c_uchar, external_call

from std.reflection import get_type_name
from mav.ffmpeg.avcodec.codec_id import AVCodecID
from mav.ffmpeg.avutil.avutil import AVMediaType
from mav.ffmpeg.avutil.rational import AVRational
from mav.ffmpeg.avutil.pixfmt import AVPixelFormat
from mav.ffmpeg.avutil.samplefmt import AVSampleFormat
from mav.ffmpeg.avutil.log import AVClass
from mav.ffmpeg.avutil.hwcontext import AVHWDeviceType
from mav.ffmpeg.avutil.channel_layout import AVChannelLayout


comptime AV_CODEC_CAP_DRAW_HORIZ_BAND = c_int(1 << 0)

comptime AV_CODEC_CAP_DR1 = c_int(1 << 1)

comptime AV_CODEC_CAP_DELAY = c_int(1 << 5)

comptime AV_CODEC_CAP_SMALL_LAST_FRAME = c_int(1 << 6)

comptime AV_CODEC_CAP_EXPERIMENTAL = c_int(1 << 9)

comptime AV_CODEC_CAP_CHANNEL_CONF = c_int(1 << 10)

comptime AV_CODEC_CAP_FRAME_THREADS = c_int(1 << 12)

comptime AV_CODEC_CAP_SLICE_THREADS = c_int(1 << 13)

comptime AV_CODEC_CAP_PARAM_CHANGE = c_int(1 << 14)

comptime AV_CODEC_CAP_OTHER_THREADS = c_int(1 << 15)

comptime AV_CODEC_CAP_VARIABLE_FRAME_SIZE = c_int(1 << 16)

comptime AV_CODEC_CAP_AVOID_PROBING = c_int(1 << 17)

comptime AV_CODEC_CAP_HARDWARE = c_int(1 << 18)

comptime AV_CODEC_CAP_HYBRID = c_int(1 << 19)

comptime AV_CODEC_CAP_ENCODER_REORDERED_OPAQUE = c_int(1 << 20)

comptime AV_CODEC_CAP_ENCODER_FLUSH = c_int(1 << 21)

comptime AV_CODEC_CAP_ENCODER_RECON_FRAME = c_int(1 << 22)


struct AVProfile(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVProfile.html."

    var profile: c_int
    var name: UnsafePointer[c_char, ImmutExternalOrigin]


@fieldwise_init
struct AVCodec(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVCodec.html."

    var name: UnsafePointer[c_char, ImmutExternalOrigin]
    var long_name: UnsafePointer[c_char, ImmutExternalOrigin]

    var type: AVMediaType.ENUM_DTYPE
    var id: AVCodecID.ENUM_DTYPE

    var capabilities: c_int
    var max_lowres: c_uchar

    var supported_framerates: UnsafePointer[AVRational, ImmutExternalOrigin]

    var pix_fmts: UnsafePointer[AVPixelFormat.ENUM_DTYPE, ImmutExternalOrigin]

    var supported_samplerates: UnsafePointer[c_int, ImmutExternalOrigin]

    var sample_fmts: UnsafePointer[
        AVSampleFormat.ENUM_DTYPE, ImmutExternalOrigin
    ]

    var priv_class: UnsafePointer[AVClass, ImmutExternalOrigin]

    var profiles: UnsafePointer[AVProfile, ImmutExternalOrigin]

    var wrapper_name: UnsafePointer[c_char, ImmutExternalOrigin]

    var ch_layouts: UnsafePointer[AVChannelLayout, ImmutExternalOrigin]


fn av_codec_iterate(
    opaque: UnsafePointer[OpaquePointer[MutExternalOrigin], MutExternalOrigin]
) -> UnsafePointer[AVCodec, ImmutExternalOrigin]:
    return external_call[
        "av_codec_iterate", UnsafePointer[AVCodec, ImmutExternalOrigin]
    ](opaque)


fn avcodec_find_decoder(
    id: AVCodecID.ENUM_DTYPE,
) -> UnsafePointer[AVCodec, ImmutExternalOrigin]:
    return external_call[
        "avcodec_find_decoder", UnsafePointer[AVCodec, ImmutExternalOrigin]
    ](id)


fn avcodec_find_decoder_by_name(
    name: UnsafePointer[c_char, ImmutExternalOrigin]
) -> UnsafePointer[AVCodec, ImmutExternalOrigin]:
    return external_call[
        "avcodec_find_decoder_by_name",
        UnsafePointer[AVCodec, ImmutExternalOrigin],
    ](name)


fn avcodec_find_decoder_by_name(
    mut extension: String,
) raises Error -> UnsafePointer[AVCodec, ImmutExternalOrigin]:
    var stripped_extension: String = String(StringSlice(extension).lstrip("."))
    var ptr = avcodec_find_decoder_by_name(
        stripped_extension.as_c_string_slice()
        .unsafe_ptr()
        .unsafe_origin_cast[ImmutExternalOrigin]()
    )
    if not ptr:
        raise Error("Failed to find decoder by name: ", extension)
    return ptr


fn avcodec_find_encoder_by_name(
    mut extension: String,
) raises Error -> UnsafePointer[AVCodec, ImmutExternalOrigin]:
    var stripped_extension: String = String(StringSlice(extension).lstrip("."))
    var ptr = avcodec_find_encoder_by_name(
        stripped_extension.as_c_string_slice()
        .unsafe_ptr()
        .unsafe_origin_cast[ImmutExternalOrigin]()
    )
    if not ptr:
        raise Error("Failed to find encoder by name: ", extension)
    return ptr


fn avcodec_find_encoder(
    id: AVCodecID.ENUM_DTYPE,
) -> UnsafePointer[AVCodec, ImmutExternalOrigin]:
    return external_call[
        "avcodec_find_encoder", UnsafePointer[AVCodec, ImmutExternalOrigin]
    ](id)


fn avcodec_find_encoder_by_name(
    name: UnsafePointer[c_char, ImmutExternalOrigin]
) -> UnsafePointer[AVCodec, ImmutExternalOrigin]:
    return external_call[
        "avcodec_find_encoder_by_name",
        UnsafePointer[AVCodec, ImmutExternalOrigin],
    ](name)


fn av_codec_is_encoder(
    codec: UnsafePointer[AVCodec, ImmutExternalOrigin]
) -> c_int:
    return external_call["av_codec_is_encoder", c_int](codec)


fn av_codec_is_decoder(
    codec: UnsafePointer[AVCodec, ImmutExternalOrigin]
) -> c_int:
    return external_call["av_codec_is_decoder", c_int](codec)


fn av_get_profile_name(
    codec: UnsafePointer[AVCodec, ImmutExternalOrigin], profile: c_int
) -> UnsafePointer[c_char, ImmutExternalOrigin]:
    return external_call[
        "av_get_profile_name", UnsafePointer[c_char, ImmutExternalOrigin]
    ](codec, profile)


comptime AV_CODEC_HW_CONFIG_METHOD_HW_DEVICE_CTX = c_int(0x01)

comptime AV_CODEC_HW_CONFIG_METHOD_HW_FRAMES_CTX = c_int(0x02)

comptime AV_CODEC_HW_CONFIG_METHOD_INTERNAL = c_int(0x04)

comptime AV_CODEC_HW_CONFIG_METHOD_AD_HOC = c_int(0x08)


@fieldwise_init
struct AVCodecHWConfig(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVCodecHWConfig.html."

    var pix_fmt: AVPixelFormat.ENUM_DTYPE
    var methods: c_int

    var device_type: AVHWDeviceType.ENUM_DTYPE


fn avcodec_get_hw_config(
    codec: UnsafePointer[AVCodec, ImmutExternalOrigin], index: c_int
) -> UnsafePointer[AVCodecHWConfig, ImmutExternalOrigin]:
    return external_call[
        "avcodec_get_hw_config",
        UnsafePointer[AVCodecHWConfig, ImmutExternalOrigin],
    ](codec, index)
