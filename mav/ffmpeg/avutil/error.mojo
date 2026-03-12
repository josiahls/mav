"See https://www.ffmpeg.org/doxygen/8.0/error_8h.html."
from std.ffi import c_int, c_size_t, external_call
from mav.ffmpeg.avutil.macros import MKTAG
from std.utils import Variant
from std.os import abort


# NOTE: There is a macro conditional: EDOM > 0. Not sure if we need to do this.
fn AVERROR(err: c_int) -> c_int:
    return -err


comptime IntOrStr = Variant[Int, c_int, String, StaticString]


@always_inline
fn get_int(a: IntOrStr) -> Int:
    if a.isa[Int]():
        return a[Int]
    elif a.isa[c_int]():
        return Int(a[c_int])
    elif a.isa[String]():
        return ord(a[String])
    else:
        return ord(a[StaticString])


@always_inline
fn FFERRTAG(a: IntOrStr, b: IntOrStr, c: IntOrStr, d: IntOrStr) -> Int:
    return -MKTAG(get_int(a), get_int(b), get_int(c), get_int(d))


comptime AVERROR_BSF_NOT_FOUND = FFERRTAG(0xF8, "B", "S", "F")

comptime AVERROR_BUG = FFERRTAG("B", "U", "G", "!")

comptime AVERROR_BUFFER_TOO_SMALL = FFERRTAG("B", "U", "F", "S")

comptime AVERROR_DECODER_NOT_FOUND = FFERRTAG(0xF8, "D", "E", "C")

comptime AVERROR_DEMUXER_NOT_FOUND = FFERRTAG(0xF8, "D", "E", "M")

comptime AVERROR_ENCODER_NOT_FOUND = FFERRTAG(0xF8, "E", "N", "C")

comptime AVERROR_EOF = FFERRTAG("E", "O", "F", " ")

comptime AVERROR_EXIT = FFERRTAG("E", "X", "I", "T")

comptime AVERROR_EXTERNAL = FFERRTAG("E", "X", "T", " ")

comptime AVERROR_FILTER_NOT_FOUND = FFERRTAG(0xF8, "F", "I", "L")

comptime AVERROR_INVALIDDATA = FFERRTAG("I", "N", "D", "A")

comptime AVERROR_MUXER_NOT_FOUND = FFERRTAG(0xF8, "M", "U", "X")

comptime AVERROR_OPTION_NOT_FOUND = FFERRTAG(0xF8, "O", "P", "T")

comptime AVERROR_PATCHWELCOME = FFERRTAG("P", "A", "W", "E")

comptime AVERROR_PROTOCOL_NOT_FOUND = FFERRTAG(0xF8, "P", "R", "O")

comptime AVERROR_STREAM_NOT_FOUND = FFERRTAG(0xF8, "S", "T", "R")

comptime AVERROR_BUG2 = FFERRTAG("B", "U", "G", " ")

comptime AVERROR_UNKNOWN = FFERRTAG("U", "N", "K", "N")

comptime AVERROR_EXPERIMENTAL = -0x2BB2AFA8

comptime AVERROR_INPUT_CHANGED = -0x636E6701

comptime AVERROR_OUTPUT_CHANGED = -0x636E6702

# HTTP and RTSP error
comptime AVERROR_HTTP_BAD_REQUEST = FFERRTAG(0xF8, "4", "0", "0")

comptime AVERROR_HTTP_UNAUTHORIZED = FFERRTAG(0xF8, "4", "0", "1")

comptime AVERROR_HTTP_FORBIDDEN = FFERRTAG(0xF8, "4", "0", "3")

comptime AVERROR_HTTP_NOT_FOUND = FFERRTAG(0xF8, "4", "0", "4")

comptime AVERROR_HTTP_TOO_MANY_REQUESTS = FFERRTAG(0xF8, "4", "2", "9")

comptime AVERROR_HTTP_OTHER_4XX = FFERRTAG(0xF8, "4", "X", "X")

comptime AVERROR_HTTP_SERVER_ERROR = FFERRTAG(0xF8, "5", "X", "X")

comptime AV_ERROR_MAX_STRING_SIZE = 64


fn av_strerror(
    err: c_int,
    errbuf: UnsafePointer[c_char, MutAnyOrigin],
    errbuf_size: c_size_t,
) -> c_int:
    return external_call["av_strerror", c_int](err, errbuf, errbuf_size)


fn av_err2str(err: c_int) -> String:
    var s = alloc[c_char](AV_ERROR_MAX_STRING_SIZE)
    var ret = av_strerror(
        err,
        s,
        AV_ERROR_MAX_STRING_SIZE,
    )
    if ret < 0:
        abort("Failed to get error string for error code: {}".format(err))
    return String(unsafe_from_utf8_ptr=s)
