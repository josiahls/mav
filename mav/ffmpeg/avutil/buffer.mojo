"See https://www.ffmpeg.org/doxygen/8.0/buffer_8h.html."
from std.ffi import c_uchar, c_uint, c_int, c_size_t, external_call
from std.os.atomic import Atomic


struct AVBuffer(Movable):
    pass


@fieldwise_init
struct AVBufferRef(TrivialRegisterPassable, Writable):
    "See https://www.ffmpeg.org/doxygen/8.0/structAVBufferRef.html."
    var buffer: UnsafePointer[AVBuffer, origin=MutExternalOrigin]
    var data: UnsafePointer[c_uchar, origin=MutExternalOrigin]
    var size: c_size_t


fn av_buffer_alloc(
    size: c_size_t,
) -> UnsafePointer[AVBufferRef, MutExternalOrigin]:
    return external_call[
        "av_buffer_alloc", UnsafePointer[AVBufferRef, MutExternalOrigin]
    ](size)


fn av_buffer_allocz(
    size: c_size_t,
) -> UnsafePointer[AVBufferRef, MutExternalOrigin]:
    return external_call[
        "av_buffer_allocz", UnsafePointer[AVBufferRef, MutExternalOrigin]
    ](size)


comptime AV_BUFFER_FLAG_READONLY = c_int(1 << 0)


fn av_buffer_create(
    data: UnsafePointer[c_uchar, MutExternalOrigin],
    size: c_size_t,
    free: fn(
        OpaquePointer[MutExternalOrigin],
        UnsafePointer[c_uchar, MutExternalOrigin],
    ) -> NoneType,
    opaque: OpaquePointer[MutExternalOrigin],
    flags: c_int,
) -> UnsafePointer[AVBufferRef, MutExternalOrigin]:
    return external_call[
        "av_buffer_create", UnsafePointer[AVBufferRef, MutExternalOrigin]
    ](data, size, free, opaque, flags)


fn av_buffer_default_free(
    opaque: OpaquePointer[MutExternalOrigin],
    data: UnsafePointer[c_uchar, MutExternalOrigin],
):
    external_call["av_buffer_default_free", NoneType](opaque, data)


fn av_buffer_ref(
    buf: UnsafePointer[AVBufferRef, ImmutExternalOrigin]
) -> UnsafePointer[AVBufferRef, MutExternalOrigin]:
    return external_call[
        "av_buffer_ref", UnsafePointer[AVBufferRef, MutExternalOrigin]
    ](buf)


fn av_buffer_unref(
    buf: UnsafePointer[
        UnsafePointer[AVBufferRef, MutExternalOrigin], MutExternalOrigin
    ]
):
    external_call["av_buffer_unref", NoneType](buf)


fn av_buffer_is_writable(
    buf: UnsafePointer[AVBufferRef, ImmutExternalOrigin]
) -> c_int:
    return external_call["av_buffer_is_writable", c_int](buf)


fn av_buffer_get_opaque(
    buf: UnsafePointer[AVBufferRef, ImmutExternalOrigin]
) -> OpaquePointer[MutExternalOrigin]:
    return external_call[
        "av_buffer_get_opaque", OpaquePointer[MutExternalOrigin]
    ](buf)


fn av_buffer_get_ref_count(
    buf: UnsafePointer[AVBufferRef, ImmutExternalOrigin]
) -> c_int:
    return external_call["av_buffer_get_ref_count", c_int](buf)


fn av_buffer_make_writable(
    buf: UnsafePointer[
        UnsafePointer[AVBufferRef, MutExternalOrigin], MutExternalOrigin
    ]
) -> c_int:
    return external_call["av_buffer_make_writable", c_int](buf)


fn av_buffer_realloc(
    buf: UnsafePointer[
        UnsafePointer[AVBufferRef, MutExternalOrigin], MutExternalOrigin
    ],
    size: c_size_t,
) -> c_int:
    return external_call["av_buffer_realloc", c_int](buf, size)


fn av_buffer_replace(
    dst: UnsafePointer[
        UnsafePointer[AVBufferRef, MutExternalOrigin], MutExternalOrigin
    ],
    src: UnsafePointer[AVBufferRef, ImmutExternalOrigin],
) -> c_int:
    return external_call["av_buffer_replace", c_int](dst, src)


@fieldwise_init
struct AVBufferPool(Movable):
    pass


fn av_buffer_pool_init(
    size: c_size_t,
    alloc: fn(c_size_t) -> UnsafePointer[AVBufferRef, MutExternalOrigin],
) -> UnsafePointer[AVBufferPool, MutExternalOrigin]:
    return external_call[
        "av_buffer_pool_init", UnsafePointer[AVBufferPool, MutExternalOrigin]
    ](size, alloc)


fn av_buffer_pool_init2(
    size: c_size_t,
    opaque: OpaquePointer[MutExternalOrigin],
    alloc: fn(OpaquePointer[MutExternalOrigin], c_size_t) -> UnsafePointer[
        AVBufferRef, MutExternalOrigin
    ],
    pool_free: fn(OpaquePointer[MutExternalOrigin]) -> NoneType,
) -> UnsafePointer[AVBufferPool, MutExternalOrigin]:
    return external_call[
        "av_buffer_pool_init2", UnsafePointer[AVBufferPool, MutExternalOrigin]
    ](size, opaque, alloc, pool_free)


fn av_buffer_pool_uninit(
    pool: UnsafePointer[
        UnsafePointer[AVBufferPool, MutExternalOrigin], MutExternalOrigin
    ]
):
    external_call["av_buffer_pool_uninit", NoneType](pool)


fn av_buffer_pool_get(
    pool: UnsafePointer[AVBufferPool, MutExternalOrigin]
) -> UnsafePointer[AVBufferRef, MutExternalOrigin]:
    return external_call[
        "av_buffer_pool_get", UnsafePointer[AVBufferRef, MutExternalOrigin]
    ](pool)


fn av_buffer_pool_buffer_get_opaque(
    ref_: UnsafePointer[AVBufferRef, ImmutExternalOrigin]
) -> OpaquePointer[MutExternalOrigin]:
    return external_call[
        "av_buffer_pool_buffer_get_opaque", OpaquePointer[MutExternalOrigin]
    ](ref_)
