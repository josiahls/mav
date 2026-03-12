from std.testing import TestSuite, assert_true, assert_equal
from std.memory import alloc, memset
from std.ffi import c_size_t, c_uint, c_int, c_uchar, external_call
from mav.ffmpeg.avutil.buffer import (
    AVBuffer,
    AVBufferRef,
    AVBufferPool,
)
from mav.ffmpeg import avutil


fn my_free(
    opaque: OpaquePointer[MutExternalOrigin],
    data: UnsafePointer[c_uchar, MutExternalOrigin],
):
    # free() from libc is always globally visible, unlike FFmpeg symbols.
    external_call["free", NoneType](data)


# Mirrors AVBuffer's actual C layout (libavutil/buffer_internal.h):
#   uint8_t    *data;                  // offset  0, 8 bytes
#   size_t      size;                  // offset  8, 8 bytes
#   atomic_uint refcount;              // offset 16, 4 bytes (unsigned int in memory)
#   <padding>                          // offset 20, 4 bytes
#   void (*free)(void*, uint8_t*);     // offset 24, 8 bytes
#   void       *opaque;                // offset 32, 8 bytes
#   int         flags;                 // offset 40, 4 bytes
#   int         flags_internal;        // offset 44, 4 bytes
struct AVBufferLayout:
    var data: UnsafePointer[c_uchar, MutExternalOrigin]
    var size: c_size_t
    var refcount: c_uint
    var _pad: c_uint
    var free: fn(
        OpaquePointer[MutExternalOrigin],
        UnsafePointer[c_uchar, MutExternalOrigin],
    ) -> NoneType
    var opaque: OpaquePointer[MutExternalOrigin]
    var flags: c_int
    var flags_internal: c_int


fn my_alloc(size: c_size_t) -> UnsafePointer[AVBufferRef, MutExternalOrigin]:
    # Custom logic: allocate double the requested size.
    # data is malloc'd so my_free (which calls glibc free) can release it.
    # AVBuffer/AVBufferRef are managed by av_buffer_create using FFmpeg's own
    # allocator, so av_free can safely release them.
    var n = size + size
    var data = external_call[
        "malloc", UnsafePointer[c_uchar, MutExternalOrigin]
    ](n)
    return avutil.av_buffer_create(
        data,
        n,
        my_free,
        OpaquePointer[MutExternalOrigin](unsafe_from_address=0),
        0,
    )


fn my_alloc2(
    opaque: OpaquePointer[MutExternalOrigin], size: c_size_t
) -> UnsafePointer[AVBufferRef, MutExternalOrigin]:
    return my_alloc(size)


fn my_pool_free(opaque: OpaquePointer[MutExternalOrigin]) -> NoneType:
    return


def test_av_buffer_alloc() raises:
    var buf_ptr = alloc[UnsafePointer[AVBufferRef, MutExternalOrigin]](1)
    buf_ptr[] = avutil.av_buffer_alloc(128)
    assert_true(Bool(buf_ptr[]))
    assert_equal(Int(buf_ptr[][].size), 128)
    avutil.av_buffer_unref(buf_ptr)
    buf_ptr.free()


def test_av_buffer_allocz() raises:
    var buf_ptr = alloc[UnsafePointer[AVBufferRef, MutExternalOrigin]](1)
    buf_ptr[] = avutil.av_buffer_allocz(128)
    assert_true(Bool(buf_ptr[]))
    assert_equal(Int(buf_ptr[][].size), 128)
    # allocz zeroes the data
    assert_equal(Int(buf_ptr[][].data[0]), 0)
    avutil.av_buffer_unref(buf_ptr)
    buf_ptr.free()


def test_av_buffer_create() raises:
    var data = external_call[
        "malloc", UnsafePointer[c_uchar, MutExternalOrigin]
    ](128)
    var buf_ptr = alloc[UnsafePointer[AVBufferRef, MutExternalOrigin]](1)
    buf_ptr[] = avutil.av_buffer_create(
        data,
        128,
        my_free,
        OpaquePointer[MutExternalOrigin](unsafe_from_address=0),
        0,
    )
    assert_true(Bool(buf_ptr[]))
    assert_equal(Int(buf_ptr[][].size), 128)
    avutil.av_buffer_unref(buf_ptr)
    buf_ptr.free()


def test_av_buffer_ref() raises:
    var buf_ptr = alloc[UnsafePointer[AVBufferRef, MutExternalOrigin]](1)
    buf_ptr[] = avutil.av_buffer_alloc(128)
    assert_true(Bool(buf_ptr[]))
    var ref_ptr = alloc[UnsafePointer[AVBufferRef, MutExternalOrigin]](1)
    ref_ptr[] = avutil.av_buffer_ref(buf_ptr[].as_immutable())
    assert_true(Bool(ref_ptr[]))
    assert_equal(avutil.av_buffer_get_ref_count(buf_ptr[].as_immutable()), 2)
    avutil.av_buffer_unref(ref_ptr)
    ref_ptr.free()
    avutil.av_buffer_unref(buf_ptr)
    buf_ptr.free()


def test_av_buffer_unref() raises:
    var buf = avutil.av_buffer_alloc(128)
    assert_true(Bool(buf))
    var buf_ptr = alloc[UnsafePointer[AVBufferRef, MutExternalOrigin]](1)
    buf_ptr[] = buf
    avutil.av_buffer_unref(buf_ptr)


def test_av_buffer_is_writable() raises:
    var buf_ptr = alloc[UnsafePointer[AVBufferRef, MutExternalOrigin]](1)
    buf_ptr[] = avutil.av_buffer_alloc(128)
    assert_equal(avutil.av_buffer_is_writable(buf_ptr[].as_immutable()), 1)
    avutil.av_buffer_unref(buf_ptr)
    buf_ptr.free()


def test_av_buffer_get_opaque() raises:
    var buf_ptr = alloc[UnsafePointer[AVBufferRef, MutExternalOrigin]](1)
    buf_ptr[] = avutil.av_buffer_alloc(128)
    # Default alloc sets opaque to NULL -- just check it doesn't crash.
    _ = avutil.av_buffer_get_opaque(buf_ptr[].as_immutable())
    avutil.av_buffer_unref(buf_ptr)
    buf_ptr.free()


def test_av_buffer_get_ref_count() raises:
    var buf_ptr = alloc[UnsafePointer[AVBufferRef, MutExternalOrigin]](1)
    buf_ptr[] = avutil.av_buffer_alloc(128)
    assert_equal(avutil.av_buffer_get_ref_count(buf_ptr[].as_immutable()), 1)
    avutil.av_buffer_unref(buf_ptr)
    buf_ptr.free()


def test_av_buffer_make_writable() raises:
    var buf_ptr = alloc[UnsafePointer[AVBufferRef, MutExternalOrigin]](1)
    buf_ptr[] = avutil.av_buffer_alloc(128)
    # Single ref -- already writable, so this is a no-op returning 0.
    assert_equal(
        avutil.av_buffer_make_writable(buf_ptr),
        0,
    )
    avutil.av_buffer_unref(buf_ptr)
    buf_ptr.free()


def test_av_buffer_realloc() raises:
    var buf = avutil.av_buffer_alloc(128)
    var buf_ptr = alloc[UnsafePointer[AVBufferRef, MutExternalOrigin]](1)
    buf_ptr[] = buf
    assert_equal(
        avutil.av_buffer_realloc(buf_ptr, 256),
        0,
    )
    assert_equal(Int(buf_ptr[][].size), 256)
    avutil.av_buffer_unref(buf_ptr)
    buf_ptr.free()


def test_av_buffer_replace() raises:
    var src_ptr = alloc[UnsafePointer[AVBufferRef, MutExternalOrigin]](1)
    src_ptr[] = avutil.av_buffer_alloc(128)
    var dst = alloc[UnsafePointer[AVBufferRef, MutExternalOrigin]](1)
    memset(dst, 0, 1)
    assert_equal(
        avutil.av_buffer_replace(
            dst,
            src_ptr[].as_immutable(),
        ),
        0,
    )
    assert_equal(Int(dst[][].size), 128)
    avutil.av_buffer_unref(src_ptr)
    src_ptr.free()
    avutil.av_buffer_unref(dst)
    dst.free()


def test_av_buffer_pool_init() raises:
    var pool_ptr = alloc[UnsafePointer[AVBufferPool, MutExternalOrigin]](1)
    pool_ptr[] = avutil.av_buffer_pool_init(128, my_alloc)
    assert_true(Bool(pool_ptr[]))
    var buf_ptr = alloc[UnsafePointer[AVBufferRef, MutExternalOrigin]](1)
    buf_ptr[] = avutil.av_buffer_pool_get(pool_ptr[])
    assert_true(Bool(buf_ptr[]))
    # my_alloc doubled the size -- proves our fn was called, not FFmpeg's default.
    assert_equal(Int(buf_ptr[][].size), 256)
    avutil.av_buffer_unref(buf_ptr)
    buf_ptr.free()
    avutil.av_buffer_pool_uninit(pool_ptr)
    pool_ptr.free()


def test_av_buffer_pool_init2() raises:
    var pool_ptr = alloc[UnsafePointer[AVBufferPool, MutExternalOrigin]](1)
    pool_ptr[] = avutil.av_buffer_pool_init2(
        128,
        OpaquePointer[MutExternalOrigin](unsafe_from_address=0),
        my_alloc2,
        my_pool_free,
    )
    assert_true(Bool(pool_ptr[]))
    var buf_ptr = alloc[UnsafePointer[AVBufferRef, MutExternalOrigin]](1)
    buf_ptr[] = avutil.av_buffer_pool_get(pool_ptr[])
    assert_true(Bool(buf_ptr[]))
    assert_equal(Int(buf_ptr[][].size), 256)
    avutil.av_buffer_unref(buf_ptr)
    buf_ptr.free()
    avutil.av_buffer_pool_uninit(pool_ptr)
    pool_ptr.free()


def test_av_buffer_pool_uninit() raises:
    var pool = avutil.av_buffer_pool_init(128, my_alloc)
    assert_true(Bool(pool))
    var pool_ptr = alloc[UnsafePointer[AVBufferPool, MutExternalOrigin]](1)
    pool_ptr[] = pool
    avutil.av_buffer_pool_uninit(pool_ptr)


def test_av_buffer_pool_get() raises:
    var pool_ptr = alloc[UnsafePointer[AVBufferPool, MutExternalOrigin]](1)
    pool_ptr[] = avutil.av_buffer_pool_init(128, my_alloc)
    var buf1_ptr = alloc[UnsafePointer[AVBufferRef, MutExternalOrigin]](1)
    buf1_ptr[] = avutil.av_buffer_pool_get(pool_ptr[])
    var buf2_ptr = alloc[UnsafePointer[AVBufferRef, MutExternalOrigin]](1)
    buf2_ptr[] = avutil.av_buffer_pool_get(pool_ptr[])
    assert_true(Bool(buf1_ptr[]))
    assert_true(Bool(buf2_ptr[]))
    avutil.av_buffer_unref(buf1_ptr)
    buf1_ptr.free()
    avutil.av_buffer_unref(buf2_ptr)
    buf2_ptr.free()
    avutil.av_buffer_pool_uninit(pool_ptr)
    pool_ptr.free()


def test_av_buffer_pool_buffer_get_opaque() raises:
    var pool_ptr = alloc[UnsafePointer[AVBufferPool, MutExternalOrigin]](1)
    pool_ptr[] = avutil.av_buffer_pool_init(128, my_alloc)
    var buf_ptr = alloc[UnsafePointer[AVBufferRef, MutExternalOrigin]](1)
    buf_ptr[] = avutil.av_buffer_pool_get(pool_ptr[])
    assert_true(Bool(buf_ptr[]))
    # Just check it doesn't crash -- opaque is NULL for pools with no pool_free.
    _ = avutil.av_buffer_pool_buffer_get_opaque(buf_ptr[].as_immutable())
    avutil.av_buffer_unref(buf_ptr)
    buf_ptr.free()
    avutil.av_buffer_pool_uninit(pool_ptr)
    pool_ptr.free()


def main() raises:
    pass
    TestSuite.discover_tests[__functions_in_module()]().run()
    # test_av_buffer_alloc()
    # test_av_buffer_allocz()
    # test_av_buffer_create()
    # test_av_buffer_ref()
    # test_av_buffer_unref()
    # test_av_buffer_is_writable()
    # test_av_buffer_get_opaque()
    # test_av_buffer_get_ref_count()
    # test_av_buffer_make_writable()
    # test_av_buffer_realloc()
    # test_av_buffer_replace()
    # test_av_buffer_pool_init()
    # test_av_buffer_pool_init2()
    # test_av_buffer_pool_uninit()
    # test_av_buffer_pool_get()
    # test_av_buffer_pool_buffer_get_opaque()
