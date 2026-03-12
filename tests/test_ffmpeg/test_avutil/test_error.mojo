from std.testing import TestSuite, assert_equal
from std.memory import memset
from std.ffi import c_uchar, c_int, c_char
from std.sys._libc_errno import ErrNo

from mav.ffmpeg.avutil.error import AVERROR, AVERROR_EOF
from mav.ffmpeg.avutil.error import FFERRTAG
from std.reflection import get_type_name


def test_FFERRTAG() raises:
    """Check:
    Basic 0,1,2,3 values make sense.
    That 'B' and named StaticStrings compile into the variant.
    """
    assert_equal(FFERRTAG(0, 1, 2, 3), -50462976)
    comptime s: StaticString = "S"
    comptime f: StaticString = "F"
    assert_equal(FFERRTAG(0, "B", s, f), -1179861504)


def test_AVERROR() raises:
    assert_equal(AVERROR(ErrNo.ENOENT.value), -2)
    assert_equal(AVERROR(ErrNo.EIO.value), -5)
    assert_equal(AVERROR(ErrNo.ENOMEM.value), -12)
    assert_equal(AVERROR(ErrNo.EINVAL.value), -22)
    assert_equal(AVERROR(ErrNo.EAGAIN.value), -11)
    assert_equal(AVERROR(ErrNo.EBUSY.value), -16)
    assert_equal(AVERROR(ErrNo.EPERM.value), -1)


def test_AVERROR_EOF() raises:
    # 00100000010001100100111101000101, 20464F45
    # print(hex(ord('E')))
    # print(hex(ord('O')))
    # print(hex(ord('F')))
    # print(hex(ord(' ')))
    # print("actual hex: ", hex(AVERROR_EOF))
    assert_equal(AVERROR_EOF, -541478725)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
