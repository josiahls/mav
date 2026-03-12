from std.ffi import external_call


fn av_freep[T: AnyType](var ptr: UnsafePointer[T, MutExternalOrigin]):
    external_call["av_freep", NoneType](ptr)
