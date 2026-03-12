"See https://www.ffmpeg.org/doxygen/8.0/bsf_8h.html."

from mav.ffmpeg.avutil.log import AVClass
from mav.ffmpeg.avcodec.codec_par import AVCodecParameters
from mav.ffmpeg.avutil.rational import AVRational
from std.ffi import c_int, c_char
from std.utils import StaticTuple


@fieldwise_init
struct AVBSFContext(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVBSFContext.html."

    var av_class: UnsafePointer[AVClass, origin=ImmutExternalOrigin]
    var filter: UnsafePointer[AVBitStreamFilter, origin=ImmutExternalOrigin]
    var priv_data: OpaquePointer[MutExternalOrigin]
    var par_in: UnsafePointer[AVCodecParameters, origin=MutExternalOrigin]
    var par_out: UnsafePointer[AVCodecParameters, origin=MutExternalOrigin]
    var time_base_in: AVRational
    var time_base_out: AVRational


@fieldwise_init
struct AVBitStreamFilter(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVBitStreamFilter.html."
    var name: UnsafePointer[c_char, origin=ImmutExternalOrigin]

    var codec_ids: UnsafePointer[
        AVCodecID.ENUM_DTYPE, origin=ImmutExternalOrigin
    ]
    var priv_class: UnsafePointer[AVClass, origin=ImmutExternalOrigin]
