"See https://www.ffmpeg.org/doxygen/8.0/avutil_8h.html."
from std.ffi import c_int, c_uint, c_long_long, c_ulong_long


comptime AV_NOPTS_VALUE = c_long_long(c_ulong_long(0x8000000000000000))


@fieldwise_init("implicit")
struct AVPictureType(Movable, Writable):
    comptime ENUM_DTYPE = c_int

    var _value: Self.ENUM_DTYPE

    comptime AV_PICTURE_TYPE_NONE = Self(0)
    comptime AV_PICTURE_TYPE_I = Self(1)
    comptime AV_PICTURE_TYPE_P = Self(2)
    comptime AV_PICTURE_TYPE_B = Self(3)
    comptime AV_PICTURE_TYPE_S = Self(4)
    comptime AV_PICTURE_TYPE_SI = Self(5)
    comptime AV_PICTURE_TYPE_SP = Self(6)
    comptime AV_PICTURE_TYPE_BI = Self(7)


@fieldwise_init("implicit")
struct AVMediaType(Movable, Writable):
    comptime ENUM_DTYPE = c_int

    var _value: Self.ENUM_DTYPE

    fn inc(self) -> Self:
        return Self(self._value + 1)

    # < Usually treated as AVMEDIA_TYPE_DATA
    comptime AVMEDIA_TYPE_UNKNOWN = Self(-1)
    comptime AVMEDIA_TYPE_VIDEO = Self(Self.AVMEDIA_TYPE_UNKNOWN._value).inc()
    comptime AVMEDIA_TYPE_AUDIO = Self(Self.AVMEDIA_TYPE_VIDEO._value).inc()

    # < Opaque data information usually continuous
    comptime AVMEDIA_TYPE_DATA = Self(Self.AVMEDIA_TYPE_AUDIO._value).inc()
    comptime AVMEDIA_TYPE_SUBTITLE = Self(Self.AVMEDIA_TYPE_DATA._value).inc()

    # < Opaque data information usually sparse
    comptime AVMEDIA_TYPE_ATTACHMENT = Self(
        Self.AVMEDIA_TYPE_SUBTITLE._value
    ).inc()
    comptime AVMEDIA_TYPE_NB = Self(Self.AVMEDIA_TYPE_ATTACHMENT._value).inc()
