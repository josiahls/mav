"See https://www.ffmpeg.org/doxygen/8.0/avio_8h.html."
from std.ffi import (
    c_int,
    c_char,
    c_long_long,
    c_uchar,
    c_ulong,
    c_ulong_long,
    c_uint,
    c_size_t,
    external_call,
)
from std.utils import StaticTuple
from mav.ffmpeg.avutil.log import AVClass
from mav.ffmpeg.avutil.dict import AVDictionary
from mav._clib import C_Union


comptime AVIO_SEEKABLE_NORMAL = 1 << 0
"Seeking works like for a local file."
comptime AVIO_SEEKABLE_TIME = 1 << 1
"Seeking by timestamp with avio_seek_time() is possible."


@fieldwise_init
struct AVIOInterruptCB(Movable, Writable):
    """This structure contains a callback for checking whether to abort blocking functions.
    """

    var callback: fn(opaque: OpaquePointer[MutExternalOrigin]) -> c_int
    var opaque: OpaquePointer[MutExternalOrigin]


@fieldwise_init
struct AVIODirEntryType(Movable, Writable):
    """This structure contains a directory entry type."""

    comptime ENUM_DTYPE = c_int
    var value: Self.ENUM_DTYPE

    comptime AVIO_ENTRY_UNKNOWN = Self(0)
    comptime AVIO_ENTRY_BLOCK_DEVICE = Self(1)
    comptime AVIO_ENTRY_CHARACTER_DEVICE = Self(2)
    comptime AVIO_ENTRY_DIRECTORY = Self(3)
    comptime AVIO_ENTRY_NAMED_PIPE = Self(4)
    comptime AVIO_ENTRY_SYMBOLIC_LINK = Self(5)
    comptime AVIO_ENTRY_SOCKET = Self(6)


@fieldwise_init
struct AVIODirEntry(Movable, Writable):
    """See https://www.ffmpeg.org/doxygen/8.0/structAVIODirEntry.html."""

    var name: UnsafePointer[c_char, MutExternalOrigin]
    var type: AVIODirEntryType.ENUM_DTYPE
    var utf8: c_int
    var size: c_long_long
    var modification_timestamp: c_long_long
    var access_timestamp: c_long_long
    var status_change_timestamp: c_long_long
    var user_id: c_long_long
    var group_id: c_long_long
    var filemode: c_long_long


# TODO: Is this a forward declaration?
struct AVIODirContext(Movable, Writable):
    pass


@fieldwise_init
struct AVIODataMarkerType(Movable, Writable):
    """This structure contains a data marker type."""

    comptime ENUM_DTYPE = c_int
    var value: Self.ENUM_DTYPE

    comptime AVIO_DATA_MARKER_HEADER = Self(0)
    comptime AVIO_DATA_MARKER_SYNC_POINT = Self(1)
    comptime AVIO_DATA_MARKER_BOUNDARY_POINT = Self(2)
    comptime AVIO_DATA_MARKER_UNKNOWN = Self(3)
    comptime AVIO_DATA_MARKER_TRAILER = Self(4)
    comptime AVIO_DATA_MARKER_FLUSH_POINT = Self(5)


@fieldwise_init
struct AVIOContext(Movable, Writable):
    """See https://www.ffmpeg.org/doxygen/8.0/structAVIOContext.html."""

    var av_class: UnsafePointer[AVClass, MutExternalOrigin]
    var buffer: UnsafePointer[c_uchar, MutExternalOrigin]
    var buffer_size: c_int
    var buf_ptr: UnsafePointer[c_uchar, MutExternalOrigin]
    var buf_end: UnsafePointer[c_uchar, MutExternalOrigin]
    var opaque: OpaquePointer[MutExternalOrigin]
    var read_packet: fn(
        opaque: OpaquePointer[MutExternalOrigin],
        buf: UnsafePointer[c_uchar, MutExternalOrigin],
        buf_size: c_int,
    ) -> c_int
    var write_packet: fn(
        opaque: OpaquePointer[MutExternalOrigin],
        buf: UnsafePointer[c_uchar, MutExternalOrigin],
        buf_size: c_int,
    ) -> c_int
    var seek: fn(
        opaque: OpaquePointer[MutExternalOrigin],
        offset: c_long_long,
        whence: c_int,
    ) -> c_long_long
    var pos: c_long_long
    var eof_reached: c_int
    var error: c_int
    var write_flag: c_int
    var max_packet_size: c_int
    var min_packet_size: c_int
    var checksum: c_ulong
    var checksum_ptr: UnsafePointer[c_uchar, MutExternalOrigin]
    var update_checksum: fn(
        checksum: c_ulong,
        buf: UnsafePointer[c_uchar, ImmutExternalOrigin],
        size: c_uint,
    ) -> c_ulong
    var read_pause: fn(
        opaque: OpaquePointer[MutExternalOrigin],
        pause: c_int,
    ) -> c_int
    var read_seek: fn(
        opaque: OpaquePointer[MutExternalOrigin],
        stream_index: c_int,
        timestamp: c_long_long,
        flags: c_int,
    ) -> c_long_long
    var seekable: c_int
    var direct: c_int
    var protocol_whitelist: UnsafePointer[c_char, ImmutExternalOrigin]
    var protocol_blacklist: UnsafePointer[c_char, ImmutExternalOrigin]
    var write_data_type: fn(
        opaque: OpaquePointer[MutExternalOrigin],
        buf: UnsafePointer[c_uchar, ImmutExternalOrigin],
        buf_size: c_int,
        type: AVIODataMarkerType.ENUM_DTYPE,
        time: c_long_long,
    ) -> c_int

    var ignore_boundary_point: c_int
    var buf_ptr_max: UnsafePointer[c_uchar, MutExternalOrigin]
    var bytes_read: c_long_long
    var bytes_written: c_long_long


comptime avio_find_protocol_name = fn(
    url: UnsafePointer[c_char, ImmutExternalOrigin],
) -> UnsafePointer[c_char, ImmutExternalOrigin]

comptime avio_check = fn(
    url: UnsafePointer[c_char, ImmutExternalOrigin],
    flags: c_int,
) -> c_int

comptime avio_open_dir = fn(
    s: UnsafePointer[
        UnsafePointer[AVIODirContext, MutExternalOrigin], MutExternalOrigin
    ],
    url: UnsafePointer[c_char, ImmutExternalOrigin],
    options: UnsafePointer[
        UnsafePointer[AVDictionary, MutExternalOrigin], MutExternalOrigin
    ],
) -> c_int

comptime avio_read_dir = fn(
    s: UnsafePointer[AVIODirContext, MutExternalOrigin],
    next: UnsafePointer[
        UnsafePointer[AVIODirEntry, MutExternalOrigin], MutExternalOrigin
    ],
) -> c_int

comptime avio_close_dir = fn(
    s: UnsafePointer[
        UnsafePointer[AVIODirContext, MutExternalOrigin], MutExternalOrigin
    ],
) -> c_int

comptime avio_free_directory_entry = fn(
    entry: UnsafePointer[
        UnsafePointer[AVIODirEntry, MutExternalOrigin], MutExternalOrigin
    ],
) -> NoneType

comptime avio_alloc_context = fn(
    buffer: UnsafePointer[c_uchar, MutExternalOrigin],
    buffer_size: c_int,
    write_flag: c_int,
    opaque: OpaquePointer[MutExternalOrigin],
    read_packet: fn(
        opaque: OpaquePointer[MutExternalOrigin],
        buf: UnsafePointer[c_uchar, MutExternalOrigin],
        buf_size: c_int,
    ) -> c_int,
    write_packet: fn(
        opaque: OpaquePointer[MutExternalOrigin],
        buf: UnsafePointer[c_uchar, MutExternalOrigin],
        buf_size: c_int,
    ) -> c_int,
    seek: fn(
        opaque: OpaquePointer[MutExternalOrigin],
        offset: c_long_long,
        whence: c_int,
    ) -> c_long_long,
) -> UnsafePointer[AVIOContext, MutExternalOrigin]

comptime avio_context_free = fn(
    s: UnsafePointer[
        UnsafePointer[AVIOContext, MutExternalOrigin], MutExternalOrigin
    ],
) -> NoneType

comptime avio_w8 = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    b: c_int,
) -> NoneType
comptime avio_write = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    buf: UnsafePointer[c_uchar, ImmutExternalOrigin],
    size: c_int,
) -> NoneType
comptime avio_wl64 = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    val: c_ulong_long,
) -> NoneType
comptime avio_wb64 = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    val: c_ulong_long,
) -> NoneType
comptime avio_wl32 = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    val: c_uint,
) -> NoneType
comptime avio_wb32 = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    val: c_uint,
) -> NoneType
comptime avio_wl24 = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    val: c_uint,
) -> NoneType
comptime avio_wb24 = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    val: c_uint,
) -> NoneType
comptime avio_wl16 = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    val: c_uint,
) -> NoneType
comptime avio_wb16 = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    val: c_uint,
) -> NoneType

comptime avio_put_str = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    str: UnsafePointer[c_char, ImmutExternalOrigin],
) -> c_int

comptime avio_put_str16le = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    str: UnsafePointer[c_char, ImmutExternalOrigin],
) -> c_int

comptime avio_put_str16be = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    str: UnsafePointer[c_char, ImmutExternalOrigin],
) -> c_int

comptime avio_write_marker = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    time: c_long_long,
    type: AVIODataMarkerType.ENUM_DTYPE,
) -> NoneType

comptime AVSEEK_SIZE = 0x10000
comptime AVSEEK_FORCE = 0x20000

comptime avio_seek = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    offset: c_long_long,
    whence: c_int,
) -> c_long_long
comptime avio_skip = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    offset: c_long_long,
) -> c_long_long

# TODO: Reimplement in the DLHandle
# @always_inline
# fn avio_tell(s: UnsafePointer[AVIOContext, MutExternalOrigin]) -> c_long_long:
#     """ftell() equivalent for AVIOContext.

#     Returns:
#     - the current position or AVERROR.
#     """
#     return avio_seek(s, 0, std.os.SEEK_CUR)


comptime avio_size = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
) -> c_long_long

comptime avio_feof = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
) -> c_int

# Note: without a helper.c if some kind, we cannot support functions like this,
# since we will not have access to the `va_list` type.
# int avio_vprintf(AVIOContext *s, const char *fmt, va_list ap);

comptime avio_printf = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    fmt: UnsafePointer[c_char, ImmutExternalOrigin]
    # ...: Any, TODO: Not sure if we can support this.
) -> c_int

comptime avio_print_string_array = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    strings: UnsafePointer[
        UnsafePointer[c_char, ImmutExternalOrigin], ImmutExternalOrigin
    ],
) -> NoneType
# NOTE: The docs have it as `int void` which doesn't make sense.

# TODO: Not sure if we can support this.
# Mojo has no way of accessing the __VA_ARGS__ or va_lists.
# #define avio_print(s, ...) \
#     avio_print_string_array(s, (const char*[]){__VA_ARGS__, NULL})

comptime avio_flush = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
) -> NoneType

comptime avio_read = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    buf: UnsafePointer[c_uchar, MutExternalOrigin],
    size: c_int,
) -> c_int

comptime avio_read_partial = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    buf: UnsafePointer[c_uchar, MutExternalOrigin],
    size: c_int,
) -> c_int

# Functions for reading from AVIOContext
comptime AVIOContextMutPtr = UnsafePointer[AVIOContext, MutExternalOrigin]
comptime avio_r8 = fn(s: AVIOContextMutPtr) -> c_int
comptime avio_rl16 = fn(s: AVIOContextMutPtr) -> c_uint
comptime avio_rl24 = fn(s: AVIOContextMutPtr) -> c_uint
comptime avio_rl32 = fn(s: AVIOContextMutPtr) -> c_uint
comptime avio_rl64 = fn(s: AVIOContextMutPtr) -> c_ulong_long
comptime avio_rb16 = fn(s: AVIOContextMutPtr) -> c_uint
comptime avio_rb24 = fn(s: AVIOContextMutPtr) -> c_uint
comptime avio_rb32 = fn(s: AVIOContextMutPtr) -> c_uint
comptime avio_rb64 = fn(s: AVIOContextMutPtr) -> c_ulong_long


comptime avio_get_str = fn(
    s: AVIOContextMutPtr,
    maxlen: c_int,
    buf: UnsafePointer[c_char, MutExternalOrigin],
    buflen: c_int,
) -> c_int

comptime avio_get_str16le = fn(
    s: AVIOContextMutPtr,
    maxlen: c_int,
    buf: UnsafePointer[c_char, MutExternalOrigin],
    buflen: c_int,
) -> c_int

comptime avio_get_str16be = fn(
    s: AVIOContextMutPtr,
    maxlen: c_int,
    buf: UnsafePointer[c_char, MutExternalOrigin],
    buflen: c_int,
) -> c_int

comptime AVIO_FLAG_READ = 1
comptime AVIO_FLAG_WRITE = 2
comptime AVIO_FLAG_READ_WRITE = AVIO_FLAG_READ | AVIO_FLAG_WRITE
comptime AVIO_FLAG_NONBLOCK = 8
comptime AVIO_FLAG_DIRECT = 0x8000


fn avio_open(
    s: UnsafePointer[
        UnsafePointer[AVIOContext, MutExternalOrigin], MutExternalOrigin
    ],
    mut url: String,
    flags: c_int,
) -> c_int:
    var url_ptr = url.as_c_string_slice().unsafe_ptr().as_immutable()
    return external_call["avio_open", c_int](s, url_ptr, flags)


fn avio_open(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    mut url: String,
    flags: c_int,
) -> c_int:
    var s_ptr = alloc[type_of(s)](1)
    s_ptr[] = s
    var res = external_call["avio_open", c_int](s_ptr, url, flags)
    s_ptr.free()
    return res


comptime avio_open2 = fn(
    s: UnsafePointer[
        UnsafePointer[AVIOContext, MutExternalOrigin], MutExternalOrigin
    ],
    url: UnsafePointer[c_char, ImmutAnyOrigin],
    flags: c_int,
    int_cb: UnsafePointer[AVIOInterruptCB, ImmutExternalOrigin],
    options: UnsafePointer[
        UnsafePointer[AVDictionary, MutExternalOrigin], MutExternalOrigin
    ],
) -> c_int


fn avio_close(s: UnsafePointer[AVIOContext, MutExternalOrigin]) -> c_int:
    return external_call["avio_close", c_int](s)


fn avio_closep(
    s: UnsafePointer[
        UnsafePointer[AVIOContext, MutExternalOrigin], MutExternalOrigin
    ]
) -> c_int:
    return external_call["avio_closep", c_int](s)


comptime avio_open_dyn_buf = fn(
    s: UnsafePointer[
        UnsafePointer[AVIOContext, MutExternalOrigin], MutExternalOrigin
    ],
) -> c_int

comptime avio_get_dyn_buf = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    pbuffer: UnsafePointer[
        UnsafePointer[c_uchar, MutExternalOrigin], MutExternalOrigin
    ],
) -> c_int

comptime avio_close_dyn_buf = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    pbuffer: UnsafePointer[
        UnsafePointer[c_uchar, MutExternalOrigin], MutExternalOrigin
    ],
) -> c_int

comptime avio_enum_protocols = fn(
    opaque: UnsafePointer[OpaquePointer[MutExternalOrigin], MutExternalOrigin],
    output: c_int,
) -> UnsafePointer[c_char, ImmutExternalOrigin]

comptime avio_protocol_get_class = fn(
    name: UnsafePointer[c_char, ImmutExternalOrigin],
) -> UnsafePointer[AVClass, ImmutExternalOrigin]

comptime avio_pause = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    pause: c_int,
) -> c_int

comptime avio_seek_time = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    stream_index: c_int,
    timestamp: c_long_long,
    flags: c_int,
) -> c_long_long


@fieldwise_init
struct AVBPrint(Movable, Writable):
    "Avoid a warning. The header can not be included because it breaks c++."
    pass


comptime avio_read_to_bprint = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    pb: UnsafePointer[AVBPrint, MutExternalOrigin],
    max_size: c_size_t,
) -> c_int

comptime avio_accept = fn(
    s: UnsafePointer[AVIOContext, MutExternalOrigin],
    c: UnsafePointer[
        UnsafePointer[AVIOContext, MutExternalOrigin], MutExternalOrigin
    ],
) -> c_int

comptime avio_handshake = fn(
    c: UnsafePointer[AVIOContext, MutExternalOrigin],
) -> c_int
