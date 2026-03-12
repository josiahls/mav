"See https://www.ffmpeg.org/doxygen/8.0/defs_8h.html."
from std.ffi import c_int


comptime AV_INPUT_BUFFER_PADDING_SIZE = c_int(64)


@fieldwise_init("implicit")
struct AVFieldOrder(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var _value: Self.ENUM_DTYPE

    comptime AV_FIELD_UNKNOWN = Self(0)
    comptime AV_FIELD_PROGRESSIVE = Self(1)
    comptime AV_FIELD_TT = Self(2)
    comptime AV_FIELD_BB = Self(3)
    comptime AV_FIELD_TB = Self(4)
    comptime AV_FIELD_BT = Self(5)


@fieldwise_init("implicit")
struct AVAudioServiceType(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var _value: Self.ENUM_DTYPE

    comptime AV_AUDIO_SERVICE_TYPE_MAIN = Self(0)
    comptime AV_AUDIO_SERVICE_TYPE_EFFECTS = Self(1)
    comptime AV_AUDIO_SERVICE_TYPE_VISUALLY_IMPAIRED = Self(2)
    comptime AV_AUDIO_SERVICE_TYPE_HEARING_IMPAIRED = Self(3)
    comptime AV_AUDIO_SERVICE_TYPE_DIALOGUE = Self(4)
    comptime AV_AUDIO_SERVICE_TYPE_COMMENTARY = Self(5)
    comptime AV_AUDIO_SERVICE_TYPE_EMERGENCY = Self(6)
    comptime AV_AUDIO_SERVICE_TYPE_VOICE_OVER = Self(7)
    comptime AV_AUDIO_SERVICE_TYPE_KARAOKE = Self(8)
    comptime AV_AUDIO_SERVICE_TYPE_NB = Self(9)


@fieldwise_init("implicit")
struct AVDiscard(Movable, Writable):
    comptime ENUM_DTYPE = c_int
    var _value: Self.ENUM_DTYPE

    comptime AVDISCARD_NONE = Self(-16)
    comptime AVDISCARD_DEFAULT = Self(0)
    comptime AVDISCARD_NONREF = Self(8)
    comptime AVDISCARD_BIDIR = Self(16)
    comptime AVDISCARD_NONINTRA = Self(24)
    comptime AVDISCARD_NONKEY = Self(32)
    comptime AVDISCARD_ALL = Self(48)
