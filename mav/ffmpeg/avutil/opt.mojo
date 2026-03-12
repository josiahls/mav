"See https://www.ffmpeg.org/doxygen/8.0/opt_8h.html."
from std.ffi import c_char, c_int, c_uint, c_double, c_long_long
from mav._clib import C_Union
from mav.ffmpeg.avutil.rational import AVRational


# @fieldwise_init
struct AVOption(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVOption.html."
    var name: UnsafePointer[c_char, ImmutExternalOrigin]
    var help: UnsafePointer[c_char, ImmutExternalOrigin]
    var offset: c_int
    var type: AVOptionType
    var default_val: C_Union[
        c_long_long,
        c_double,
        UnsafePointer[c_char, ImmutExternalOrigin],
        AVRational,
        UnsafePointer[AVOptionArrayDef, ImmutExternalOrigin],
    ]
    var min: c_double
    var max: c_double
    var flags: c_int
    var unit: UnsafePointer[c_char, ImmutExternalOrigin]


@fieldwise_init("implicit")
struct AVOptionType(Movable, Writable):
    comptime ENUM_DTYPE = c_int

    var _value: Self.ENUM_DTYPE

    fn inc(self) -> Self:
        return Self(self._value + 1)

    comptime AV_OPT_TYPE_FLAGS = Self(1)
    comptime AV_OPT_TYPE_INT = Self(Self.AV_OPT_TYPE_FLAGS._value).inc()
    comptime AV_OPT_TYPE_INT64 = Self(Self.AV_OPT_TYPE_INT._value).inc()
    comptime AV_OPT_TYPE_DOUBLE = Self(Self.AV_OPT_TYPE_INT64._value).inc()
    comptime AV_OPT_TYPE_FLOAT = Self(Self.AV_OPT_TYPE_DOUBLE._value).inc()
    comptime AV_OPT_TYPE_STRING = Self(Self.AV_OPT_TYPE_FLOAT._value).inc()
    comptime AV_OPT_TYPE_RATIONAL = Self(Self.AV_OPT_TYPE_STRING._value).inc()
    comptime AV_OPT_TYPE_BINARY = Self(Self.AV_OPT_TYPE_RATIONAL._value).inc()
    comptime AV_OPT_TYPE_DICT = Self(Self.AV_OPT_TYPE_BINARY._value).inc()
    comptime AV_OPT_TYPE_UINT64 = Self(Self.AV_OPT_TYPE_DICT._value).inc()
    comptime AV_OPT_TYPE_CONST = Self(Self.AV_OPT_TYPE_UINT64._value).inc()
    comptime AV_OPT_TYPE_IMAGE_SIZE = Self(Self.AV_OPT_TYPE_CONST._value).inc()
    comptime AV_OPT_TYPE_PIXEL_FMT = Self(
        Self.AV_OPT_TYPE_IMAGE_SIZE._value
    ).inc()
    comptime AV_OPT_TYPE_SAMPLE_FMT = Self(
        Self.AV_OPT_TYPE_PIXEL_FMT._value
    ).inc()
    comptime AV_OPT_TYPE_VIDEO_RATE = Self(
        Self.AV_OPT_TYPE_SAMPLE_FMT._value
    ).inc()
    comptime AV_OPT_TYPE_DURATION = Self(
        Self.AV_OPT_TYPE_VIDEO_RATE._value
    ).inc()
    comptime AV_OPT_TYPE_COLOR = Self(Self.AV_OPT_TYPE_DURATION._value).inc()
    comptime AV_OPT_TYPE_BOOL = Self(Self.AV_OPT_TYPE_COLOR._value).inc()
    comptime AV_OPT_TYPE_CHLAYOUT = Self(Self.AV_OPT_TYPE_BOOL._value).inc()
    comptime AV_OPT_TYPE_UINT = Self(Self.AV_OPT_TYPE_CHLAYOUT._value).inc()
    comptime AV_OPT_TYPE_FLAG_ARRAY = Self(1 << 16)


@fieldwise_init
struct AVOptionArrayDef(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVOptionArrayDef.html."
    var def_: UnsafePointer[c_char, ImmutExternalOrigin]
    var size_min: c_uint
    var size_max: c_uint
    var sep: c_char


@fieldwise_init
struct AVOptionRange(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVOptionRange.html."
    var str: UnsafePointer[c_char, ImmutExternalOrigin]
    var value_min: c_double
    var value_max: c_double
    var component_min: c_double
    var component_max: c_double
    var is_range: c_int


struct AVOptionRanges(Movable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVOptionRanges.html."
    var range: UnsafePointer[
        UnsafePointer[AVOptionRange, MutExternalOrigin], MutExternalOrigin
    ]
    var nb_ranges: c_int
    var nb_components: c_int
