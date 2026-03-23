"See https://www.ffmpeg.org/doxygen/8.0/frame_8h.html."

from mav.ffmpeg.avutil.rational import AVRational
from mav.ffmpeg.avutil.buffer import AVBufferRef
from mav.ffmpeg.avutil.avutil import AVPictureType
from mav.ffmpeg.avutil.channel_layout import AVChannelLayout
from mav.ffmpeg.avutil.dict import AVDictionary
from mav.ffmpeg.avutil.pixfmt import (
    AVPixelFormat,
    AVColorRange,
    AVColorPrimaries,
    AVColorTransferCharacteristic,
    AVColorSpace,
    AVChromaLocation,
)
from std.ffi import (
    c_uchar,
    c_int,
    c_long_long,
    c_ulong_long,
    c_size_t,
    c_uint,
    c_char,
    external_call,
)
from std.utils import StaticTuple
from std.memory import memset_zero


# Until https://github.com/modular/modular/pull/5715 is merged, we need to
# extend the unsafe_ptr function to StaticTuple.
__extension StaticTuple:
    @always_inline("nodebug")
    fn unsafe_ptr(
        ref self,
    ) -> UnsafePointer[Self.element_type, origin_of(self)]:
        return (
            UnsafePointer(to=self._mlir_value)
            .bitcast[Self.element_type]()
            .unsafe_origin_cast[origin_of(self)]()
        )


@fieldwise_init("implicit")
struct AVFrameSideDataType(Movable, Writable):
    comptime ENUM_DTYPE = c_int

    var _value: Self.ENUM_DTYPE

    comptime AV_FRAME_DATA_PANSCAN = Self(0)

    comptime AV_FRAME_DATA_A53_CC = Self(1)
    comptime AV_FRAME_DATA_STEREO3D = Self(2)
    comptime AV_FRAME_DATA_MATRIXENCODING = Self(3)
    comptime AV_FRAME_DATA_DOWNMIX_INFO = Self(4)
    comptime AV_FRAME_DATA_REPLAYGAIN = Self(5)
    comptime AV_FRAME_DATA_DISPLAYMATRIX = Self(6)
    comptime AV_FRAME_DATA_AFD = Self(7)
    comptime AV_FRAME_DATA_MOTION_VECTORS = Self(8)
    comptime AV_FRAME_DATA_SKIP_SAMPLES = Self(9)
    comptime AV_FRAME_DATA_AUDIO_SERVICE_TYPE = Self(10)
    comptime AV_FRAME_DATA_MASTERING_DISPLAY_METADATA = Self(11)
    comptime AV_FRAME_DATA_GOP_TIMECODE = Self(12)

    comptime AV_FRAME_DATA_SPHERICAL = Self(13)

    comptime AV_FRAME_DATA_CONTENT_LIGHT_LEVEL = Self(14)

    comptime AV_FRAME_DATA_ICC_PROFILE = Self(15)

    comptime AV_FRAME_DATA_S12M_TIMECODE = Self(16)

    comptime AV_FRAME_DATA_DYNAMIC_HDR_PLUS = Self(17)

    comptime AV_FRAME_DATA_REGIONS_OF_INTEREST = Self(18)

    comptime AV_FRAME_DATA_VIDEO_ENC_PARAMS = Self(19)

    comptime AV_FRAME_DATA_SEI_UNREGISTERED = Self(20)

    comptime AV_FRAME_DATA_FILM_GRAIN_PARAMS = Self(21)

    comptime AV_FRAME_DATA_DETECTION_BBOXES = Self(22)

    comptime AV_FRAME_DATA_DOVI_RPU_BUFFER = Self(23)

    comptime AV_FRAME_DATA_DOVI_METADATA = Self(24)

    comptime AV_FRAME_DATA_DYNAMIC_HDR_VIVID = Self(25)

    comptime AV_FRAME_DATA_AMBIENT_VIEWING_ENVIRONMENT = Self(26)

    comptime AV_FRAME_DATA_VIDEO_HINT = Self(27)

    comptime AV_FRAME_DATA_LCEVC = Self(28)

    comptime AV_FRAME_DATA_VIEW_ID = Self(29)

    comptime AV_FRAME_DATA_3D_REFERENCE_DISPLAYS = Self(30)


@fieldwise_init
struct AVActiveFormatDescription(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var _value: Self.ENUM_DTYPE

    comptime AV_AFD_SAME = Self(8)
    comptime AV_AFD_4_3 = Self(9)
    comptime AV_AFD_16_9 = Self(10)
    comptime AV_AFD_14_9 = Self(11)
    comptime AV_AFD_4_3_SP_14_9 = Self(13)
    comptime AV_AFD_16_9_SP_14_9 = Self(14)
    comptime AV_AFD_SP_4_3 = Self(15)


struct AVFrameSideData(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVFrameSideData.html."
    var type: AVFrameSideDataType.ENUM_DTYPE
    var data: UnsafePointer[c_uchar, MutExternalOrigin]
    var size: c_size_t
    var metadata: UnsafePointer[AVDictionary, MutExternalOrigin]
    var buf: UnsafePointer[AVBufferRef, MutExternalOrigin]

    @staticmethod
    fn alloc_triple_ptr() -> (
        UnsafePointer[
            UnsafePointer[
                UnsafePointer[AVFrameSideData, MutExternalOrigin],
                MutExternalOrigin,
            ],
            MutExternalOrigin,
        ]
    ):
        var sd_ptr_ptr = alloc[
            UnsafePointer[
                UnsafePointer[AVFrameSideData, MutExternalOrigin],
                MutExternalOrigin,
            ]
        ](1)
        memset_zero(sd_ptr_ptr, 1)
        return sd_ptr_ptr


@fieldwise_init
struct AVSideDataProps(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var _value: Self.ENUM_DTYPE

    comptime AV_SIDE_DATA_PROP_GLOBAL = Self(1 << 0)
    comptime AV_SIDE_DATA_PROP_MULTI = Self(1 << 1)
    comptime AV_SIDE_DATA_PROP_SIZE_DEPENDENT = Self(1 << 2)
    comptime AV_SIDE_DATA_PROP_COLOR_DEPENDENT = Self(1 << 3)
    comptime AV_SIDE_DATA_PROP_CHANNEL_DEPENDENT = Self(1 << 4)


@fieldwise_init
struct AVSideDataDescriptor(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVSideDataDescriptor.html."
    var name: UnsafePointer[c_char, MutExternalOrigin]
    var props: AVSideDataProps.ENUM_DTYPE


@fieldwise_init
struct AVRegionOfInterest(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVRegionOfInterest.html."
    var self_size: c_uint
    var top: c_int
    var bottom: c_int
    var left: c_int
    var right: c_int

    var qoffset: AVRational


@fieldwise_init
struct AVFrame(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVFrame.html."
    comptime AV_NUM_DATA_POINTERS = Int(8)

    var data: StaticTuple[
        UnsafePointer[c_uchar, MutExternalOrigin], Self.AV_NUM_DATA_POINTERS
    ]
    var linesize: StaticTuple[c_int, Self.AV_NUM_DATA_POINTERS]

    var extended_data: UnsafePointer[
        UnsafePointer[c_uchar, origin=MutExternalOrigin],
        origin=MutExternalOrigin,
    ]

    var width: c_int
    var height: c_int

    var nb_samples: c_int

    var format: c_int

    var pict_type: AVPictureType.ENUM_DTYPE

    var sample_aspect_ratio: AVRational

    var pts: c_long_long

    var pkt_dts: c_long_long

    var time_base: AVRational

    var quality: c_int

    var opaque: OpaquePointer[MutExternalOrigin]

    var repeat_pict: c_int

    var sample_rate: c_int

    var buf: StaticTuple[
        UnsafePointer[AVBufferRef, origin=MutExternalOrigin],
        Self.AV_NUM_DATA_POINTERS,
    ]

    var extended_buf: UnsafePointer[
        UnsafePointer[AVBufferRef, origin=MutExternalOrigin],
        origin=MutExternalOrigin,
    ]

    var nb_extended_buf: c_int

    var side_data: UnsafePointer[
        UnsafePointer[AVFrameSideData, origin=MutExternalOrigin],
        origin=MutExternalOrigin,
    ]
    var nb_side_data: c_int

    comptime AV_FRAME_FLAG_CORRUPT = Int(1 << 0)
    comptime AV_FRAME_FLAG_KEY = Int(1 << 1)
    comptime AV_FRAME_FLAG_DISCARD = Int(1 << 2)
    comptime AV_FRAME_FLAG_INTERLACED = Int(1 << 3)
    comptime AV_FRAME_FLAG_TOP_FIELD_FIRST = Int(1 << 4)
    comptime AV_FRAME_FLAG_LOSSLESS = Int(1 << 5)

    var flags: c_int

    var color_range: AVColorRange.ENUM_DTYPE

    var color_primaries: AVColorPrimaries.ENUM_DTYPE

    var color_transfer_characteristic: AVColorTransferCharacteristic.ENUM_DTYPE

    var colorspace: AVColorSpace.ENUM_DTYPE

    var chroma_location: AVChromaLocation.ENUM_DTYPE

    var best_effort_timestamp: c_long_long

    var metadata: AVDictionary

    var decode_error_flags: c_int

    comptime FF_DECODE_ERROR_INVALID_BITSTREAM = Int(1)
    comptime FF_DECODE_ERROR_MISSING_REFERENCE = Int(2)
    comptime FF_DECODE_ERROR_CONCEALMENT_ACTIVE = Int(4)
    comptime FF_DECODE_ERROR_DECODE_SLICES = Int(8)

    var hw_frames_ctx: UnsafePointer[AVBufferRef, origin=MutExternalOrigin]

    var opaque_ref: UnsafePointer[AVBufferRef, origin=MutExternalOrigin]

    var crop_top: c_size_t

    var crop_bottom: c_size_t

    var crop_left: c_size_t

    var crop_right: c_size_t

    var private_ref: OpaquePointer[MutExternalOrigin]

    var ch_layout: AVChannelLayout

    var duration: c_long_long


fn av_frame_alloc() -> UnsafePointer[AVFrame, MutExternalOrigin]:
    return external_call[
        "av_frame_alloc", UnsafePointer[AVFrame, MutExternalOrigin]
    ]()


fn av_frame_free(
    var frame: UnsafePointer[
        UnsafePointer[AVFrame, MutExternalOrigin], MutExternalOrigin
    ]
):
    external_call["av_frame_free", NoneType](frame)


fn av_frame_ref(
    dst: UnsafePointer[AVFrame, MutExternalOrigin],
    src: UnsafePointer[AVFrame, ImmutExternalOrigin],
) -> c_int:
    return external_call["av_frame_ref", c_int](dst, src)


fn av_frame_replace(
    dst: UnsafePointer[AVFrame, MutExternalOrigin],
    src: UnsafePointer[AVFrame, ImmutExternalOrigin],
) -> c_int:
    return external_call["av_frame_replace", c_int](dst, src)


fn av_frame_clone(
    src: UnsafePointer[AVFrame, ImmutExternalOrigin]
) -> UnsafePointer[AVFrame, MutExternalOrigin]:
    return external_call[
        "av_frame_clone", UnsafePointer[AVFrame, MutExternalOrigin]
    ](src)


fn av_frame_unref(frame: UnsafePointer[AVFrame, MutExternalOrigin]):
    external_call["av_frame_unref", NoneType](frame)


fn av_frame_move_ref(
    dst: UnsafePointer[AVFrame, MutExternalOrigin],
    src: UnsafePointer[AVFrame, MutExternalOrigin],
):
    external_call["av_frame_move_ref", NoneType](dst, src)


fn av_frame_get_buffer(
    frame: UnsafePointer[AVFrame, MutExternalOrigin], align: c_int
) -> c_int:
    return external_call["av_frame_get_buffer", c_int](frame, align)


fn av_frame_is_writable(
    frame: UnsafePointer[AVFrame, MutExternalOrigin]
) -> c_int:
    return external_call["av_frame_is_writable", c_int](frame)


fn av_frame_make_writable(
    frame: UnsafePointer[AVFrame, MutExternalOrigin]
) -> c_int:
    return external_call["av_frame_make_writable", c_int](frame)


fn av_frame_copy(
    dst: UnsafePointer[AVFrame, MutExternalOrigin],
    src: UnsafePointer[AVFrame, ImmutExternalOrigin],
) -> c_int:
    return external_call["av_frame_copy", c_int](dst, src)


fn av_frame_copy_props(
    dst: UnsafePointer[AVFrame, MutExternalOrigin],
    src: UnsafePointer[AVFrame, ImmutExternalOrigin],
) -> c_int:
    return external_call["av_frame_copy_props", c_int](dst, src)


fn av_frame_get_plane_buffer(
    frame: UnsafePointer[AVFrame, ImmutExternalOrigin], plane: c_int
) -> UnsafePointer[AVBufferRef, MutExternalOrigin]:
    return external_call[
        "av_frame_get_plane_buffer",
        UnsafePointer[AVBufferRef, MutExternalOrigin],
    ](frame, plane)


fn av_frame_new_side_data(
    frame: UnsafePointer[AVFrame, MutExternalOrigin],
    type: AVFrameSideDataType.ENUM_DTYPE,
    size: c_size_t,
) -> UnsafePointer[AVFrameSideData, MutExternalOrigin]:
    return external_call[
        "av_frame_new_side_data",
        UnsafePointer[AVFrameSideData, MutExternalOrigin],
    ](frame, type, size)


fn av_frame_new_side_data_from_buf(
    frame: UnsafePointer[AVFrame, MutExternalOrigin],
    type: AVFrameSideDataType.ENUM_DTYPE,
    buf: UnsafePointer[AVBufferRef, MutExternalOrigin],
) -> UnsafePointer[AVFrameSideData, MutExternalOrigin]:
    return external_call[
        "av_frame_new_side_data_from_buf",
        UnsafePointer[AVFrameSideData, MutExternalOrigin],
    ](frame, type, buf)


fn av_frame_get_side_data(
    frame: UnsafePointer[AVFrame, ImmutExternalOrigin],
    type: AVFrameSideDataType.ENUM_DTYPE,
) -> UnsafePointer[AVFrameSideData, MutExternalOrigin]:
    return external_call[
        "av_frame_get_side_data",
        UnsafePointer[AVFrameSideData, MutExternalOrigin],
    ](frame, type)


fn av_frame_remove_side_data(
    frame: UnsafePointer[AVFrame, MutExternalOrigin],
    type: AVFrameSideDataType.ENUM_DTYPE,
):
    external_call["av_frame_remove_side_data", NoneType](frame, type)


########################################################
# ===             Flags for frame cropping           ===
########################################################

comptime AV_FRAME_CROP_UNALIGNED = Int(1 << 0)


fn av_frame_apply_cropping(
    frame: UnsafePointer[AVFrame, MutExternalOrigin], flags: c_int
) -> c_int:
    return external_call["av_frame_apply_cropping", c_int](frame, flags)


fn av_frame_side_data_name(
    type: AVFrameSideDataType.ENUM_DTYPE,
) -> UnsafePointer[c_char, ImmutExternalOrigin]:
    return external_call[
        "av_frame_side_data_name", UnsafePointer[c_char, ImmutExternalOrigin]
    ](type)


fn av_frame_side_data_desc(
    type: AVFrameSideDataType.ENUM_DTYPE,
) -> UnsafePointer[AVSideDataDescriptor, ImmutExternalOrigin]:
    return external_call[
        "av_frame_side_data_desc",
        UnsafePointer[AVSideDataDescriptor, ImmutExternalOrigin],
    ](type)


fn av_frame_side_data_free(
    sd: UnsafePointer[
        UnsafePointer[
            UnsafePointer[AVFrameSideData, MutExternalOrigin], MutExternalOrigin
        ],
        MutExternalOrigin,
    ],
    nb_sd: UnsafePointer[c_int, MutExternalOrigin],
):
    external_call["av_frame_side_data_free", NoneType](sd, nb_sd)


comptime AV_FRAME_SIDE_DATA_FLAG_UNIQUE = Int(1 << 0)


comptime AV_FRAME_SIDE_DATA_FLAG_REPLACE = Int(1 << 1)


comptime AV_FRAME_SIDE_DATA_FLAG_NEW_REF = Int(1 << 2)


fn av_frame_side_data_new(
    sd: UnsafePointer[
        UnsafePointer[
            UnsafePointer[AVFrameSideData, MutExternalOrigin], MutExternalOrigin
        ],
        MutExternalOrigin,
    ],
    nb_sd: UnsafePointer[c_int, MutExternalOrigin],
    type: AVFrameSideDataType.ENUM_DTYPE,
    size: c_size_t,
    flags: c_uint,
) -> UnsafePointer[AVFrameSideData, MutExternalOrigin]:
    return external_call[
        "av_frame_side_data_new",
        UnsafePointer[AVFrameSideData, MutExternalOrigin],
    ](sd, nb_sd, type, size, flags)


fn av_frame_side_data_add(
    sd: UnsafePointer[
        UnsafePointer[
            UnsafePointer[AVFrameSideData, MutExternalOrigin], MutExternalOrigin
        ],
        MutExternalOrigin,
    ],
    nb_sd: UnsafePointer[c_int, MutExternalOrigin],
    type: AVFrameSideDataType.ENUM_DTYPE,
    buf: UnsafePointer[
        UnsafePointer[AVBufferRef, MutExternalOrigin], MutExternalOrigin
    ],
    flags: c_uint,
) -> UnsafePointer[AVFrameSideData, MutExternalOrigin]:
    return external_call[
        "av_frame_side_data_add",
        UnsafePointer[AVFrameSideData, MutExternalOrigin],
    ](sd, nb_sd, type, buf, flags)


fn av_frame_side_data_clone(
    sd: UnsafePointer[
        UnsafePointer[
            UnsafePointer[AVFrameSideData, MutExternalOrigin], MutExternalOrigin
        ],
        MutExternalOrigin,
    ],
    nb_sd: UnsafePointer[c_int, MutExternalOrigin],
    src: UnsafePointer[AVFrameSideData, ImmutExternalOrigin],
    flags: c_uint,
) -> c_int:
    return external_call["av_frame_side_data_clone", c_int](
        sd, nb_sd, src, flags
    )


# TODO: This is an inline function and probably shouldn't be a
# "external function". This needs to be handled in the dlhandle.
fn av_frame_side_data_get_c(
    sd: UnsafePointer[
        UnsafePointer[AVFrameSideData, ImmutExternalOrigin], ImmutExternalOrigin
    ],
    nb_sd: c_int,
    type: AVFrameSideDataType.ENUM_DTYPE,
) -> UnsafePointer[AVFrameSideData, ImmutExternalOrigin]:
    return external_call[
        "av_frame_side_data_get_c",
        UnsafePointer[AVFrameSideData, ImmutExternalOrigin],
    ](sd, nb_sd, type)


# TODO: This is an inline function and probably shouldn't be a
# "external function". This needs to be handled in the dlhandle.
# comptime av_frame_side_data_get = ExternalFunction[
#     "av_frame_side_data_get",
#     fn (
#         sd: UnsafePointer[AVFrameSideData, ImmutExternalOrigin],
#         nb_sd: c_int,
#         type: AVFrameSideDataType.ENUM_DTYPE,
#     ) -> UnsafePointer[AVFrameSideData, ImmutExternalOrigin],
# ]


fn av_frame_side_data_remove(
    var sd: UnsafePointer[
        UnsafePointer[
            UnsafePointer[AVFrameSideData, MutExternalOrigin], MutExternalOrigin
        ],
        MutExternalOrigin,
    ],
    nb_sd: UnsafePointer[c_int, MutExternalOrigin],
    type: AVFrameSideDataType.ENUM_DTYPE,
):
    external_call["av_frame_side_data_remove", NoneType](sd, nb_sd, type)


fn av_frame_side_data_remove_by_props(
    sd: UnsafePointer[
        UnsafePointer[
            UnsafePointer[AVFrameSideData, MutExternalOrigin], MutExternalOrigin
        ],
        MutExternalOrigin,
    ],
    nb_sd: UnsafePointer[c_int, MutExternalOrigin],
    props: c_int,
):
    external_call["av_frame_side_data_remove_by_props", NoneType](
        sd, nb_sd, props
    )
