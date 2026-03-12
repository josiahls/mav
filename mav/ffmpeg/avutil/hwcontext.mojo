"See https://www.ffmpeg.org/doxygen/8.0/hwcontext_8h.html."
from std.ffi import c_char, c_int, c_uchar
from mav._clib import ExternalFunction

from std.reflection import get_type_name
from mav.ffmpeg.avcodec.codec_id import AVCodecID
from mav.ffmpeg.avutil.avutil import AVMediaType
from mav.ffmpeg.avutil.rational import AVRational
from mav.ffmpeg.avutil.pixfmt import AVPixelFormat
from mav.ffmpeg.avutil.samplefmt import AVSampleFormat
from mav.ffmpeg.avutil.buffer import AVBufferRef, AVBufferPool
from mav.ffmpeg.avutil.log import AVClass
from mav.ffmpeg.avutil.channel_layout import AVChannelLayout


@fieldwise_init
struct AVHWDeviceType(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var value: Self.ENUM_DTYPE

    comptime AV_HWDEVICE_TYPE_NONE = c_int(0)
    comptime AV_HWDEVICE_TYPE_VDPAU = c_int(1)
    comptime AV_HWDEVICE_TYPE_CUDA = c_int(2)
    comptime AV_HWDEVICE_TYPE_VAAPI = c_int(3)
    comptime AV_HWDEVICE_TYPE_DXVA2 = c_int(4)
    comptime AV_HWDEVICE_TYPE_QSV = c_int(5)
    comptime AV_HWDEVICE_TYPE_VIDEOTOOLBOX = c_int(6)
    comptime AV_HWDEVICE_TYPE_D3D11VA = c_int(7)
    comptime AV_HWDEVICE_TYPE_DRM = c_int(8)
    comptime AV_HWDEVICE_TYPE_OPENCL = c_int(9)
    comptime AV_HWDEVICE_TYPE_MEDIACODEC = c_int(10)
    comptime AV_HWDEVICE_TYPE_VULKAN = c_int(11)
    comptime AV_HWDEVICE_TYPE_D3D12VA = c_int(12)
    comptime AV_HWDEVICE_TYPE_AMF = c_int(13)
    comptime AV_HWDEVICE_TYPE_OHCODEC = c_int(14)


@fieldwise_init
struct AVHWDeviceContext(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVHWDeviceContext.html."
    var av_class: UnsafePointer[AVClass, ImmutExternalOrigin]
    var type: AVHWDeviceType.ENUM_DTYPE
    var hwctx: OpaquePointer[MutExternalOrigin]
    var free: UnsafePointer[
        ExternalFunction[
            "free",
            fn(ctx: UnsafePointer[AVHWDeviceContext, MutExternalOrigin]),
        ],
        ImmutExternalOrigin,
    ]
    var user_opaque: OpaquePointer[MutExternalOrigin]


@fieldwise_init
struct AVHWFramesContext(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVHWFramesContext.html."
    var av_class: UnsafePointer[AVClass, ImmutExternalOrigin]
    var device_ref: UnsafePointer[AVBufferRef, MutExternalOrigin]
    var device_ctx: UnsafePointer[AVHWDeviceContext, MutExternalOrigin]
    var hwctx: OpaquePointer[MutExternalOrigin]
    var free: UnsafePointer[
        ExternalFunction[
            "free",
            fn(ctx: UnsafePointer[AVHWFramesContext, MutExternalOrigin]),
        ],
        ImmutExternalOrigin,
    ]
    var user_opaque: OpaquePointer[MutExternalOrigin]
    var pool: UnsafePointer[AVBufferPool, MutExternalOrigin]
    var initial_pool_size: c_int
