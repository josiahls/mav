"See https://www.ffmpeg.org/doxygen/8.0/rational_8h.html."
from std.ffi import c_int, c_long_long


@fieldwise_init
struct AVRational(TrivialRegisterPassable, Writable):
    """Represents a rational number.

    FFI Binding warning: AVRational must be passed via `as_long_long()` to
    c ABI function calls if it is to be passed by value.

    References:
    - https://www.ffmpeg.org/doxygen/8.0/structAVRational.html
    """

    var num: c_int
    "Numerator."
    var den: c_int
    "Denominator."

    fn as_long_long(self) -> c_long_long:
        return c_long_long(self.den) << 32 | c_long_long(self.num)
