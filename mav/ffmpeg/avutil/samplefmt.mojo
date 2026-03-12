"See https://www.ffmpeg.org/doxygen/8.0/samplefmt_8h.html."
from std.ffi import c_int


@fieldwise_init("implicit")
struct AVSampleFormat(Movable, Writable):
    comptime ENUM_DTYPE = c_int

    var _value: Self.ENUM_DTYPE

    fn inc(self) -> Self:
        return Self(self._value + 1)

    comptime AV_SAMPLE_FMT_NONE = Self(-1)
    comptime AV_SAMPLE_FMT_U8 = Self(
        Self.AV_SAMPLE_FMT_NONE._value
    ).inc()  # unsigned 8 bits
    comptime AV_SAMPLE_FMT_S16 = Self(
        Self.AV_SAMPLE_FMT_U8._value
    ).inc()  # signed 16 bits
    comptime AV_SAMPLE_FMT_S32 = Self(
        Self.AV_SAMPLE_FMT_S16._value
    ).inc()  # signed 32 bits
    comptime AV_SAMPLE_FMT_FLT = Self(
        Self.AV_SAMPLE_FMT_S32._value
    ).inc()  # float
    comptime AV_SAMPLE_FMT_DBL = Self(
        Self.AV_SAMPLE_FMT_FLT._value
    ).inc()  # double
    comptime AV_SAMPLE_FMT_U8P = Self(
        Self.AV_SAMPLE_FMT_DBL._value
    ).inc()  # unsigned 8 bits, planar
    comptime AV_SAMPLE_FMT_S16P = Self(
        Self.AV_SAMPLE_FMT_U8P._value
    ).inc()  # signed 16 bits, planar
    comptime AV_SAMPLE_FMT_S32P = Self(
        Self.AV_SAMPLE_FMT_S16P._value
    ).inc()  # signed 32 bits, planar
    comptime AV_SAMPLE_FMT_FLTP = Self(
        Self.AV_SAMPLE_FMT_S32P._value
    ).inc()  # float, planar
    comptime AV_SAMPLE_FMT_DBLP = Self(
        Self.AV_SAMPLE_FMT_FLTP._value
    ).inc()  # double, planar
    comptime AV_SAMPLE_FMT_S64 = Self(
        Self.AV_SAMPLE_FMT_DBLP._value
    ).inc()  # signed 64 bits
    comptime AV_SAMPLE_FMT_S64P = Self(
        Self.AV_SAMPLE_FMT_S64._value
    ).inc()  # signed 64 bits, planar
    comptime AV_SAMPLE_FMT_NB = Self(
        Self.AV_SAMPLE_FMT_S64P._value
    ).inc()  # Number of sample formats. DO NOT USE if linking dynamically
