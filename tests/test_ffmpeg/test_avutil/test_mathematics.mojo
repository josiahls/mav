from std.testing import TestSuite, assert_equal
from mav.ffmpeg import avutil
from mav.ffmpeg.avutil.rational import AVRational
from mav.ffmpeg.avutil.mathematics import AVRounding


def test_AVRounding() raises:
    assert_equal(AVRounding.AV_ROUND_ZERO.value, 0)
    assert_equal(AVRounding.AV_ROUND_INF.value, 1)
    assert_equal(AVRounding.AV_ROUND_DOWN.value, 2)
    assert_equal(AVRounding.AV_ROUND_UP.value, 3)
    assert_equal(AVRounding.AV_ROUND_NEAR_INF.value, 5)
    assert_equal(AVRounding.AV_ROUND_PASS_MINMAX.value, 8192)


def test_av_compare_ts() raises:
    var tb = AVRational(num=1, den=1)
    # ts_a < ts_b -> -1
    assert_equal(avutil.av_compare_ts(0, tb, 1, tb), -1)
    # ts_a == ts_b -> 0
    assert_equal(avutil.av_compare_ts(1, tb, 1, tb), 0)
    # ts_a > ts_b -> 1
    assert_equal(avutil.av_compare_ts(2, tb, 1, tb), 1)


def test_av_rescale_rnd() raises:
    var rnd = AVRounding.AV_ROUND_NEAR_INF.value
    # a * b / c: 100 * 2 / 2 = 100
    assert_equal(avutil.av_rescale_rnd(100, 2, 2, rnd), 100)
    # 50 * 4 / 2 = 100
    assert_equal(avutil.av_rescale_rnd(50, 4, 2, rnd), 100)
    # 0 * anything = 0
    assert_equal(avutil.av_rescale_rnd(0, 1000, 1, rnd), 0)


def test_av_rescale_q_rnd() raises:
    var rnd = AVRounding.AV_ROUND_NEAR_INF.value
    # a=0 -> 0
    var bq = AVRational(num=1, den=25)
    var cq = AVRational(num=2, den=12800)
    assert_equal(avutil.av_rescale_q_rnd(0, bq, cq, rnd), 0)
    # a * (1/1) / (1/1) = a
    var one = AVRational(num=1, den=1)
    assert_equal(avutil.av_rescale_q_rnd(100, one, one, rnd), 100)
    # a * (1/1) / (2/1) = a/2
    var two = AVRational(num=2, den=1)
    assert_equal(avutil.av_rescale_q_rnd(100, one, two, rnd), 50)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
