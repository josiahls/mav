"See https://www.ffmpeg.org/doxygen/8.0/avutil_8h.html."
from std.ffi import c_int

# TODO: Swap the asisgnments for parameterized functions once the need arises.
comptime AV_HAVE_BIGENDIAN: c_int = 0
comptime AV_HAVE_FAST_UNALIGNED: c_int = 1
