from std.ffi import (
    OwnedDLHandle,
    c_char,
    c_int,
    c_long_long,
    c_uchar,
    c_uint,
    c_ushort,
)
from std.sys.info import size_of
from std.utils import StaticTuple
from std.sys.intrinsics import _type_is_eq
from std.builtin.rebind import downcast
from std.reflection import (
    struct_field_count,
    struct_field_names,
    struct_field_types,
    get_type_name,
)


comptime c_ptrdiff_t = c_long_long


struct ExternalFunction[
    name: StaticString,
    type: __TypeOfAllTypes,
]:
    """Loads external functions from a dynamic library.

    References:
    - https://github.com/modular/modular/blob/d2dadf1a723d7e341f84d34e93223517b23bfca3/mojo/stdlib/stdlib/python/_cpython.mojo#L756
    """

    @staticmethod
    @always_inline
    fn load(lib: OwnedDLHandle) -> Self.type:
        """Loads this external function from an opened dynamic library."""
        return lib._get_function[Self.name, Self.type]()


@always_inline("nodebug")
fn build_union_mlir_type[*Ts: Copyable & Movable]() -> Int:
    var max_size: Int = 0

    comptime for i in range(Variadic.size(Ts)):
        comptime current_size = size_of[Ts[i]]()
        if current_size > max_size:
            max_size = current_size
    return max_size


# TODO(josiahls): We absolutely can't do it this way as a long term thing.
@fieldwise_init("implicit")
struct C_Union[*Ts: Copyable & Movable](
    Copyable, Movable, TrivialRegisterPassable
):
    """
    A union that can hold a runtime-variant value from a set of predefined
    types.

    Reference: https://en.cppreference.com/w/c/language/union.html

    `C_Union` expects the types to overlap in storage. It is only as big as its
    largest member. It provides no additional tracking or memory management unlike
    `Variant` which is a discriminated union type that maintains a tracking discriminant.
    """

    comptime max_size = build_union_mlir_type[*Self.Ts]()
    var _impl: StaticTuple[UInt8, Self.max_size]

    @implicit
    fn __init__[T: Movable](out self, var value: T):
        """Create a c union with one of the types.

        Parameters:
            T: The type to initialize the variant to. Generally this should
                be able to be inferred from the call type, eg. `C_Union[Int, String](4)`.

        Args:
            value: The value to initialize the variant with.
        """
        __mlir_op.`lit.ownership.mark_initialized`(__get_mvalue_as_litref(self))
        self._get_ptr[T]().init_pointee_move(value^)

    @staticmethod
    fn _check[T: AnyType]() -> Bool:
        comptime for i in range(Variadic.size(Self.Ts)):
            if _type_is_eq[Self.Ts[i], T]():
                return True
        return False

    @always_inline("nodebug")
    fn _get_ptr[
        T: AnyType
    ](mut self) -> UnsafePointer[T, origin_of(self._impl)]:
        comptime is_supported = Self._check[T]()
        comptime assert is_supported, "not a union element type"
        var ptr = UnsafePointer(to=self._impl).bitcast[T]()
        return ptr


struct TrivialOptionalField[active: Bool, ElementType: __TypeOfAllTypes](
    Copyable, Movable, Writable
):
    comptime OptionalElementType = StaticTuple[
        Self.ElementType, 1 if Self.active else 0
    ]
    var field: Self.OptionalElementType

    fn __init__(out self):
        comptime assert (
            not Self.active
        ), "Constructor only available with no active field"
        self.field = Self.OptionalElementType()

    fn __init__(out self, var value: Self.ElementType):
        comptime assert (
            Self.active
        ), "Constructor only available with active field"
        self.field = Self.OptionalElementType(value)

    fn __init__(out self, var value: Optional[Self.ElementType]):
        comptime if Self.active:
            self.field = Self.OptionalElementType(value.take())
        else:
            self.field = Self.OptionalElementType()

    fn write_to(self, mut writer: Some[Writer]):
        comptime if Self.active and conforms_to(Self.ElementType, Writable):
            writer.write(trait_downcast[Writable](self[]))

    @always_inline
    fn __getitem__(ref self) -> Self.ElementType:
        comptime assert (
            Self.active
        ), "Field is not active, you should not access it."
        return self.field[0]
