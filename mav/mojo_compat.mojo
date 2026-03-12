from std.reflection import (
    struct_field_names,
    struct_field_types,
    struct_field_count,
    get_type_name,
)
from std.reflection.type_info import _unqualified_type_name
from std.builtin.constrained import _constrained_field_conforms_to


@always_inline
fn reflection_write_to_but_handle_static_tuples[
    T: Writable,
    W: Writer,
    //,
    f: fn[FieldType: Writable](field: FieldType, mut writer: W),
](this: T, mut writer: W,):
    comptime names = struct_field_names[T]()
    comptime types = struct_field_types[T]()
    comptime type_name = _unqualified_type_name[T]()
    writer.write_string(type_name)
    writer.write_string("(")

    comptime for i in range(names.size):
        comptime FieldType = types[i]

        comptime if not conforms_to(FieldType, Writable):
            comptime if i > 0:
                writer.write_string(", ")
                writer.write_string(materialize[names[i]]())
                writer.write_string("= (Not Writable)")
        else:
            _constrained_field_conforms_to[
                conforms_to(FieldType, Writable),
                Parent=T,
                FieldIndex=i,
                ParentConformsTo="Writable",
            ]()

            comptime if i > 0:
                writer.write_string(", ")
            writer.write_string(materialize[names[i]]())
            writer.write_string("=")

            ref field = trait_downcast[Writable](__struct_field_ref(i, this))
            f(field, writer)

    writer.write_string(")")
