"See https://www.ffmpeg.org/doxygen/8.0/allcodecs_8c.html."
from mav.ffmpeg.avcodec.codec_id import AVCodecID
from mav.ffmpeg.avcodec.codec import AVCodec

from std.ffi import external_call


fn avcodec_find_decoder(
    id: AVCodecID.ENUM_DTYPE,
) -> UnsafePointer[AVCodec, ImmutExternalOrigin]:
    return external_call[
        "avcodec_find_decoder", UnsafePointer[AVCodec, ImmutExternalOrigin]
    ](id)
