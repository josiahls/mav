"See https://www.ffmpeg.org/doxygen/8.0/mathematics_8h.html."
from mav.ffmpeg.avutil.rational import AVRational
from std.ffi import c_long_long, external_call


@fieldwise_init
struct AVRounding(Movable, Writable):
    comptime ENUM_DTYPE = c_int

    var value: Self.ENUM_DTYPE
    comptime AV_ROUND_ZERO = Self(0)
    comptime AV_ROUND_INF = Self(1)
    comptime AV_ROUND_DOWN = Self(2)
    comptime AV_ROUND_UP = Self(3)
    comptime AV_ROUND_NEAR_INF = Self(5)

    comptime AV_ROUND_PASS_MINMAX = Self(8192)


fn av_compare_ts(
    ts_a: c_long_long, tb_a: c_long_long, ts_b: c_long_long, tb_b: c_long_long
) -> c_int:
    return external_call["av_compare_ts", c_int](ts_a, tb_a, ts_b, tb_b)


fn av_compare_ts(
    ts_a: c_long_long, tb_a: AVRational, ts_b: c_long_long, tb_b: AVRational
) -> c_int:
    return external_call["av_compare_ts", c_int](
        ts_a, tb_a.as_long_long(), ts_b, tb_b.as_long_long()
    )


fn av_rescale_rnd(
    a: c_long_long, b: c_long_long, c: c_long_long, rnd: AVRounding.ENUM_DTYPE
) -> c_long_long:
    return external_call["av_rescale_rnd", c_long_long](a, b, c, rnd)


fn av_rescale_q_rnd(
    a: c_long_long, bq: c_long_long, cq: c_long_long, rnd: AVRounding.ENUM_DTYPE
) -> c_long_long:
    return external_call["av_rescale_q_rnd", c_long_long](a, bq, cq, rnd)


fn av_rescale_q_rnd(
    a: c_long_long, bq: AVRational, cq: AVRational, rnd: AVRounding.ENUM_DTYPE
) -> c_long_long:
    return external_call["av_rescale_q_rnd", c_long_long](
        a, bq.as_long_long(), cq.as_long_long(), rnd
    )
