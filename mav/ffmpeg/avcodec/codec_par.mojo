"See https://www.ffmpeg.org/doxygen/8.0/codec__par_8h.html."

from mav.ffmpeg.avcodec.defs import AVFieldOrder
from mav.ffmpeg.avutil.pixfmt import (
    AVColorRange,
    AVColorPrimaries,
    AVColorTransferCharacteristic,
    AVColorSpace,
    AVChromaLocation,
)
from mav.ffmpeg.avcodec.codec_id import AVCodecID
from mav.ffmpeg.avutil.avutil import AVMediaType

from std.ffi import c_uint, c_uchar, c_long_long, c_int
from mav.ffmpeg.avutil.rational import AVRational
from mav.ffmpeg.avutil.channel_layout import AVChannelLayout
from mav.ffmpeg.avcodec.packet import AVPacketSideData


@fieldwise_init
struct AVCodecParameters(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVCodecParameters.html."

    var codec_type: AVMediaType.ENUM_DTYPE
    var codec_id: AVCodecID.ENUM_DTYPE
    var codec_tag: c_uint
    var extradata: UnsafePointer[c_uchar, MutExternalOrigin]
    var extradata_size: c_int
    var coded_side_data: UnsafePointer[AVPacketSideData, MutExternalOrigin]
    var nb_coded_side_data: c_int
    var format: c_int
    var bit_rate: c_long_long
    var bits_per_coded_sample: c_int
    var bits_per_raw_sample: c_int

    var profile: c_int
    var level: c_int

    var width: c_int
    var height: c_int
    var sample_aspect_ratio: AVRational
    var framerate: AVRational
    var field_order: AVFieldOrder.ENUM_DTYPE
    var color_range: AVColorRange.ENUM_DTYPE
    var color_primaries: AVColorPrimaries.ENUM_DTYPE
    var color_trc: AVColorTransferCharacteristic.ENUM_DTYPE
    var colorspace: AVColorSpace.ENUM_DTYPE
    var chroma_location: AVChromaLocation.ENUM_DTYPE

    var video_delay: c_int
    var ch_layout: AVChannelLayout
    var sample_rate: c_int
    var block_align: c_int
    var frame_size: c_int
    var initial_padding: c_int
    var trailing_padding: c_int
    var seek_preroll: c_int
