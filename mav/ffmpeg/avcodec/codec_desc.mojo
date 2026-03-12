"See https://www.ffmpeg.org/doxygen/8.0/codec__desc_8h.html."
from std.ffi import c_char, c_int

from mav.ffmpeg.avcodec.codec_id import AVCodecID
from mav.ffmpeg.avutil.avutil import AVMediaType
from mav.ffmpeg.avcodec.codec import AVProfile


@fieldwise_init
struct AVCodecDescriptor(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVCodecDescriptor.html."

    var id: AVCodecID.ENUM_DTYPE
    var type: AVMediaType.ENUM_DTYPE

    var name: UnsafePointer[c_char, ImmutExternalOrigin]
    var long_name: UnsafePointer[c_char, ImmutExternalOrigin]
    var props: c_int
    var mime_types: UnsafePointer[
        UnsafePointer[c_char, ImmutExternalOrigin], ImmutExternalOrigin
    ]
    var profiles: UnsafePointer[AVProfile, ImmutExternalOrigin]
