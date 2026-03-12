from std.testing import TestSuite, assert_equal, assert_true
from std.memory import alloc, memset
from std.ffi import c_int, c_char, c_uchar, c_long_long, c_size_t

from mav.ffmpeg import avcodec
from mav.ffmpeg import avutil
from mav.ffmpeg.avcodec.codec_id import AVCodecID
from mav.ffmpeg.avcodec.avcodec import AVCodecContext, AVSubtitle
from mav.ffmpeg.avcodec.codec_par import AVCodecParameters
from mav.ffmpeg.avcodec.packet import AVPacket
from mav.ffmpeg.avutil.frame import AVFrame
from mav.ffmpeg.avutil.pixfmt import AVPixelFormat
from mav.ffmpeg.avutil.dict import AVDictionary
from mav.ffmpeg.avutil.avutil import AVMediaType
from mav.ffmpeg.avutil.rational import AVRational
from mav.ffmpeg.avutil.samplefmt import AVSampleFormat
from mav.ffmpeg.avutil.channel_layout import AV_CHANNEL_LAYOUT_STEREO


def test_codec_id() raises:
    var codec = avcodec.avcodec_find_decoder(AVCodecID.AV_CODEC_ID_H264._value)
    var ctx = avcodec.avcodec_alloc_context3(codec)
    var ctx_ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
    ctx_ptr[0] = ctx
    avcodec.avcodec_free_context(ctx_ptr)
    ctx_ptr.free()


def test_avcodec_version() raises:
    var ver = avcodec.avcodec_version()
    assert_true(ver >= 0)


def test_avcodec_configuration() raises:
    var cfg = avcodec.avcodec_configuration()
    assert_true(Bool(cfg))


def test_avcodec_license() raises:
    var lic = avcodec.avcodec_license()
    assert_true(Bool(lic))


def test_avcodec_alloc_context3() raises:
    var codec = avcodec.avcodec_find_decoder(AVCodecID.AV_CODEC_ID_H264._value)
    assert_true(Bool(codec))
    var ctx = avcodec.avcodec_alloc_context3(codec)
    assert_true(Bool(ctx))
    var ctx_ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
    ctx_ptr[0] = ctx
    avcodec.avcodec_free_context(ctx_ptr)


def test_avcodec_free_context() raises:
    var codec = avcodec.avcodec_find_decoder(AVCodecID.AV_CODEC_ID_H264._value)
    var ctx = avcodec.avcodec_alloc_context3(codec)
    var ctx_ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
    ctx_ptr[0] = ctx
    avcodec.avcodec_free_context(ctx_ptr)


def test_avcodec_get_class() raises:
    var cls = avcodec.avcodec_get_class()
    assert_true(Bool(cls))


def test_avcodec_get_subtitle_rect_class() raises:
    var cls = avcodec.avcodec_get_subtitle_rect_class()
    assert_true(Bool(cls))


def test_avcodec_parameters_from_context() raises:
    var codec = avcodec.avcodec_find_decoder(AVCodecID.AV_CODEC_ID_H264._value)
    var ctx = avcodec.avcodec_alloc_context3(codec)
    ctx[].width = 320
    ctx[].height = 240
    ctx[].pix_fmt = AVPixelFormat.AV_PIX_FMT_YUV420P._value
    ctx[].codec_type = AVMediaType.AVMEDIA_TYPE_VIDEO._value

    # var dict = alloc[AVDictionary](0)
    var dict = UnsafePointer[AVDictionary, MutExternalOrigin]()
    var dict_ptr = alloc[UnsafePointer[AVDictionary, MutExternalOrigin]](1)
    dict_ptr[] = dict
    # dict_ptr[] = dict

    _ = avcodec.avcodec_open2(ctx, codec, dict_ptr)
    var par = alloc[AVCodecParameters](1)
    memset(par, 0, 1)
    var ret = avcodec.avcodec_parameters_from_context(
        par,
        ctx.as_immutable(),
    )
    assert_equal(ret, 0)
    assert_equal(par[].width, 320)
    assert_equal(par[].height, 240)
    var ctx_ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
    ctx_ptr[0] = ctx
    avcodec.avcodec_free_context(ctx_ptr)


def test_avcodec_parameters_to_context() raises:
    var codec = avcodec.avcodec_find_decoder(AVCodecID.AV_CODEC_ID_H264._value)
    var ctx = avcodec.avcodec_alloc_context3(codec)
    var par = alloc[AVCodecParameters](1)
    memset(par, 0, 1)
    par[].codec_type = AVMediaType.AVMEDIA_TYPE_VIDEO._value
    par[].codec_id = AVCodecID.AV_CODEC_ID_H264._value
    par[].width = 320
    par[].height = 240
    var ret = avcodec.avcodec_parameters_to_context(
        ctx,
        par.as_immutable(),
    )
    assert_equal(ret, 0)
    assert_equal(ctx[].width, 320)
    assert_equal(ctx[].height, 240)
    var ctx_ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
    ctx_ptr[0] = ctx
    avcodec.avcodec_free_context(ctx_ptr)


def test_avcodec_open2() raises:
    var codec = avcodec.avcodec_find_decoder(AVCodecID.AV_CODEC_ID_H264._value)
    var ctx = avcodec.avcodec_alloc_context3(codec)
    # var dict = alloc[AVDictionary](0)
    var dict = UnsafePointer[AVDictionary, MutExternalOrigin]()
    var dict_ptr = alloc[UnsafePointer[AVDictionary, MutExternalOrigin]](1)
    dict_ptr[] = dict
    # dict_ptr[] = dict
    _ = avcodec.avcodec_open2(ctx, codec, dict_ptr)
    var ctx_ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
    ctx_ptr[0] = ctx
    avcodec.avcodec_free_context(ctx_ptr)


def test_avsubtitle_free() raises:
    var sub = alloc[AVSubtitle](1)
    memset(sub, 0, 1)
    avcodec.avsubtitle_free(sub)


def test_avcodec_send_packet() raises:
    var codec = avcodec.avcodec_find_decoder(AVCodecID.AV_CODEC_ID_H264._value)
    var ctx = avcodec.avcodec_alloc_context3(codec)
    var dict = UnsafePointer[AVDictionary, MutExternalOrigin]()
    var dict_ptr = alloc[UnsafePointer[AVDictionary, MutExternalOrigin]](1)
    dict_ptr[] = dict
    _ = avcodec.avcodec_open2(ctx, codec, dict_ptr)
    var null_pkt = UnsafePointer[AVPacket, MutExternalOrigin]()
    var ret = avcodec.avcodec_send_packet(ctx, null_pkt)
    assert_equal(ret, 0)
    var ctx_ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
    ctx_ptr[0] = ctx
    avcodec.avcodec_free_context(ctx_ptr)


def test_avcodec_receive_frame() raises:
    var codec = avcodec.avcodec_find_decoder(AVCodecID.AV_CODEC_ID_H264._value)
    var ctx = avcodec.avcodec_alloc_context3(codec)
    var dict = UnsafePointer[AVDictionary, MutExternalOrigin]()
    var dict_ptr = alloc[UnsafePointer[AVDictionary, MutExternalOrigin]](1)
    dict_ptr[] = dict
    _ = avcodec.avcodec_open2(ctx, codec, dict_ptr)
    var frame = avutil.av_frame_alloc()
    var ret = avcodec.avcodec_receive_frame(ctx, frame)
    _ = ret
    var frame_ptr = alloc[UnsafePointer[AVFrame, MutExternalOrigin]](1)
    frame_ptr[] = frame
    avutil.av_frame_free(frame_ptr)
    var ctx_ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
    ctx_ptr[0] = ctx
    avcodec.avcodec_free_context(ctx_ptr)


def test_avcodec_send_frame() raises:
    var codec = avcodec.avcodec_find_encoder(AVCodecID.AV_CODEC_ID_H264._value)
    var ctx = avcodec.avcodec_alloc_context3(codec)
    ctx[].width = 320
    ctx[].height = 240
    ctx[].pix_fmt = AVPixelFormat.AV_PIX_FMT_YUV420P._value
    ctx[].time_base = AVRational(num=1, den=25)
    var dict = UnsafePointer[AVDictionary, MutExternalOrigin]()
    var dict_ptr = alloc[UnsafePointer[AVDictionary, MutExternalOrigin]](1)
    dict_ptr[] = dict
    _ = avcodec.avcodec_open2(ctx, codec, dict_ptr)
    var null_frame = UnsafePointer[AVFrame, ImmutExternalOrigin]()
    var ret = avcodec.avcodec_send_frame(ctx, null_frame)
    assert_equal(ret, 0)
    var ctx_ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
    ctx_ptr[0] = ctx
    avcodec.avcodec_free_context(ctx_ptr)


def test_avcodec_receive_packet() raises:
    var codec = avcodec.avcodec_find_encoder(AVCodecID.AV_CODEC_ID_H264._value)
    var ctx = avcodec.avcodec_alloc_context3(codec)
    ctx[].width = 320
    ctx[].height = 240
    ctx[].pix_fmt = AVPixelFormat.AV_PIX_FMT_YUV420P._value
    ctx[].time_base = AVRational(num=1, den=25)
    var dict = UnsafePointer[AVDictionary, MutExternalOrigin]()
    var dict_ptr = alloc[UnsafePointer[AVDictionary, MutExternalOrigin]](1)
    dict_ptr[] = dict
    _ = avcodec.avcodec_open2(ctx, codec, dict_ptr)
    var pkt = avcodec.av_packet_alloc()
    var ret = avcodec.avcodec_receive_packet(ctx, pkt)
    _ = ret
    var pkt_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    pkt_ptr[0] = pkt
    avcodec.av_packet_free(pkt_ptr)
    var ctx_ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
    ctx_ptr[0] = ctx
    avcodec.avcodec_free_context(ctx_ptr)


def test_avcodec_align_dimensions() raises:
    var codec = avcodec.avcodec_find_decoder(AVCodecID.AV_CODEC_ID_H264._value)
    var ctx = avcodec.avcodec_alloc_context3(codec)
    ctx[].width = 321
    ctx[].height = 241
    ctx[].pix_fmt = AVPixelFormat.AV_PIX_FMT_YUV420P._value
    var dict = UnsafePointer[AVDictionary, MutExternalOrigin]()
    var dict_ptr = alloc[UnsafePointer[AVDictionary, MutExternalOrigin]](1)
    dict_ptr[] = dict
    _ = avcodec.avcodec_open2(ctx, codec, dict_ptr)
    var w = alloc[c_int](1)
    var h = alloc[c_int](1)
    w[0] = 321
    h[0] = 241
    _ = avcodec.avcodec_align_dimensions(ctx, w, h)
    var ctx_ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
    ctx_ptr[0] = ctx
    avcodec.avcodec_free_context(ctx_ptr)


def test_avcodec_align_dimensions2() raises:
    var codec = avcodec.avcodec_find_decoder(AVCodecID.AV_CODEC_ID_H264._value)
    var ctx = avcodec.avcodec_alloc_context3(codec)
    ctx[].width = 321
    ctx[].height = 241
    ctx[].pix_fmt = AVPixelFormat.AV_PIX_FMT_YUV420P._value
    var dict = UnsafePointer[AVDictionary, MutExternalOrigin]()
    var dict_ptr = alloc[UnsafePointer[AVDictionary, MutExternalOrigin]](1)
    dict_ptr[] = dict
    _ = avcodec.avcodec_open2(ctx, codec, dict_ptr)
    var w = alloc[c_int](1)
    var h = alloc[c_int](1)
    var linesize = alloc[c_int](16)
    memset(linesize, 0, 16)
    w[0] = 321
    h[0] = 241
    _ = avcodec.avcodec_align_dimensions2(ctx, w, h, linesize)
    var ctx_ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
    ctx_ptr[0] = ctx
    avcodec.avcodec_free_context(ctx_ptr)


def test_avcodec_default_get_buffer2() raises:
    var codec = avcodec.avcodec_find_decoder(AVCodecID.AV_CODEC_ID_H264._value)
    var ctx = avcodec.avcodec_alloc_context3(codec)
    ctx[].width = 320
    ctx[].height = 240
    ctx[].pix_fmt = AVPixelFormat.AV_PIX_FMT_YUV420P._value
    var dict = UnsafePointer[AVDictionary, MutExternalOrigin]()
    var dict_ptr = alloc[UnsafePointer[AVDictionary, MutExternalOrigin]](1)
    dict_ptr[] = dict
    _ = avcodec.avcodec_open2(ctx, codec, dict_ptr)
    var frame = avutil.av_frame_alloc()
    frame[].format = AVPixelFormat.AV_PIX_FMT_YUV420P._value
    frame[].width = 320
    frame[].height = 240
    var ret = avcodec.avcodec_default_get_buffer2(ctx, frame, 0)
    assert_equal(ret, 0)
    var frame_ptr = alloc[UnsafePointer[AVFrame, MutExternalOrigin]](1)
    frame_ptr[] = frame
    avutil.av_frame_free(frame_ptr)
    var ctx_ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
    ctx_ptr[0] = ctx
    avcodec.avcodec_free_context(ctx_ptr)


def test_avcodec_default_get_encode_buffer() raises:
    var codec = avcodec.avcodec_find_encoder(AVCodecID.AV_CODEC_ID_H264._value)
    var ctx = avcodec.avcodec_alloc_context3(codec)
    ctx[].width = 320
    ctx[].height = 240
    ctx[].pix_fmt = AVPixelFormat.AV_PIX_FMT_YUV420P._value
    ctx[].time_base = AVRational(num=1, den=25)
    var dict = UnsafePointer[AVDictionary, MutExternalOrigin]()
    var dict_ptr = alloc[UnsafePointer[AVDictionary, MutExternalOrigin]](1)
    dict_ptr[] = dict
    _ = avcodec.avcodec_open2(ctx, codec, dict_ptr)
    var pkt = avcodec.av_packet_alloc()
    var ret = avcodec.avcodec_default_get_encode_buffer(ctx, pkt, 0)
    assert_equal(ret, 0)
    var pkt_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    pkt_ptr[0] = pkt
    avcodec.av_packet_free(pkt_ptr)
    var ctx_ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
    ctx_ptr[0] = ctx
    avcodec.avcodec_free_context(ctx_ptr)


def test_avcodec_default_get_format() raises:
    var codec = avcodec.avcodec_find_decoder(AVCodecID.AV_CODEC_ID_H264._value)
    var ctx = avcodec.avcodec_alloc_context3(codec)
    var fmt_list = alloc[AVPixelFormat.ENUM_DTYPE](2)
    fmt_list[0] = AVPixelFormat.AV_PIX_FMT_YUV420P._value
    fmt_list[1] = AVPixelFormat.AV_PIX_FMT_NONE._value
    var ret = avcodec.avcodec_default_get_format(
        ctx,
        fmt_list.as_immutable(),
    )
    assert_equal(ret, AVPixelFormat.AV_PIX_FMT_YUV420P._value)
    var ctx_ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
    ctx_ptr[0] = ctx
    avcodec.avcodec_free_context(ctx_ptr)


def test_av_parser_parse2() raises:
    var codec = avcodec.avcodec_find_decoder(AVCodecID.AV_CODEC_ID_H264._value)
    var parser = avcodec.av_parser_init(AVCodecID.AV_CODEC_ID_H264._value)
    var ctx = avcodec.avcodec_alloc_context3(codec)
    var poutbuf = alloc[UnsafePointer[c_uchar, MutExternalOrigin]](1)
    poutbuf[0] = UnsafePointer[c_uchar, MutExternalOrigin]()
    var poutbuf_size = alloc[c_int](1)
    poutbuf_size[0] = 0
    var buf = alloc[c_uchar](64)
    memset(buf, 0, 64)
    var ret = avcodec.av_parser_parse2(
        parser,
        ctx,
        poutbuf,
        poutbuf_size,
        buf,
        64,
        c_long_long(-1),
        c_long_long(-1),
        c_long_long(-1),
    )
    _ = ret
    avcodec.av_parser_close(parser)
    var ctx_ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
    ctx_ptr[0] = ctx
    avcodec.avcodec_free_context(ctx_ptr)


def test_avcodec_fill_audio_frame() raises:
    var frame = avutil.av_frame_alloc()
    frame[].format = AVSampleFormat.AV_SAMPLE_FMT_S16._value
    frame[].nb_samples = 1024
    frame[].ch_layout = AV_CHANNEL_LAYOUT_STEREO
    var buf = alloc[c_uchar](4096)
    memset(buf, 0, 4096)
    var ret = avcodec.avcodec_fill_audio_frame(
        frame,
        2,
        AVSampleFormat.AV_SAMPLE_FMT_S16._value,
        buf,
        4096,
        0,
    )
    # Returns buffer size (bytes filled) on success, negative AVERROR on failure
    assert_equal(ret, 4096)
    # Clear frame data before free - avcodec_fill_audio_frame sets data to our buffer.
    # Must unref first so av_frame_free (which receives frame* but C expects frame**)
    # does not try to free our Mojo-allocated buffer.
    avutil.av_frame_unref(frame)
    var frame_ptr = alloc[UnsafePointer[AVFrame, MutExternalOrigin]](1)
    frame_ptr[] = frame
    avutil.av_frame_free(frame_ptr)


def test_av_parser_iterate() raises:
    var opaque = alloc[OpaquePointer[MutExternalOrigin]](1)
    memset(opaque, 0, 1)
    var count = 0
    while True:
        var parser = avcodec.av_parser_iterate(
            opaque,
        )
        if not Bool(parser):
            break
        count += 1
    assert_true(count > 0)


def test_av_parser_init() raises:
    var parser = avcodec.av_parser_init(AVCodecID.AV_CODEC_ID_H264._value)
    assert_true(Bool(parser))
    avcodec.av_parser_close(parser)


def test_av_parser_close() raises:
    var parser = avcodec.av_parser_init(AVCodecID.AV_CODEC_ID_H264._value)
    avcodec.av_parser_close(parser)


def test_avcodec_pix_fmt_to_codec_tag() raises:
    var tag = avcodec.avcodec_pix_fmt_to_codec_tag(
        AVPixelFormat.AV_PIX_FMT_YUV420P._value,
    )
    _ = tag


def test_avcodec_find_best_pix_fmt_of_list() raises:
    var list = alloc[AVPixelFormat.ENUM_DTYPE](4)
    list[0] = AVPixelFormat.AV_PIX_FMT_YUV420P._value
    list[1] = AVPixelFormat.AV_PIX_FMT_YUV422P._value
    list[2] = AVPixelFormat.AV_PIX_FMT_YUV444P._value
    list[3] = AVPixelFormat.AV_PIX_FMT_NONE._value
    var loss = alloc[c_int](1)
    loss[0] = 0
    var best = avcodec.avcodec_find_best_pix_fmt_of_list(
        list.as_immutable(),
        AVPixelFormat.AV_PIX_FMT_YUV420P._value,
        0,
        loss,
    )
    assert_equal(best, AVPixelFormat.AV_PIX_FMT_YUV420P._value)


def test_avcodec_string() raises:
    var codec = avcodec.avcodec_find_decoder(AVCodecID.AV_CODEC_ID_H264._value)
    var ctx = avcodec.avcodec_alloc_context3(codec)
    var dict = UnsafePointer[AVDictionary, MutExternalOrigin]()
    var dict_ptr = alloc[UnsafePointer[AVDictionary, MutExternalOrigin]](1)
    dict_ptr[] = dict
    _ = avcodec.avcodec_open2(ctx, codec, dict_ptr)
    var buf = alloc[c_char](256)
    memset(buf, 0, 256)
    avcodec.avcodec_string(
        buf,
        256,
        ctx.as_immutable(),
        0,
    )
    var ctx_ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
    ctx_ptr[0] = ctx
    avcodec.avcodec_free_context(ctx_ptr)


def test_avcodec_flush_buffers() raises:
    var codec = avcodec.avcodec_find_decoder(AVCodecID.AV_CODEC_ID_H264._value)
    var ctx = avcodec.avcodec_alloc_context3(codec)
    var dict = UnsafePointer[AVDictionary, MutExternalOrigin]()
    var dict_ptr = alloc[UnsafePointer[AVDictionary, MutExternalOrigin]](1)
    dict_ptr[] = dict
    _ = avcodec.avcodec_open2(ctx, codec, dict_ptr)
    avcodec.avcodec_flush_buffers(ctx)
    var ctx_ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
    ctx_ptr[0] = ctx
    avcodec.avcodec_free_context(ctx_ptr)


def test_av_get_audio_frame_duration() raises:
    var codec = avcodec.avcodec_find_decoder(AVCodecID.AV_CODEC_ID_MP3._value)
    if not Bool(codec):
        return
    var ctx = avcodec.avcodec_alloc_context3(codec)
    var dur = avcodec.av_get_audio_frame_duration(
        ctx.as_immutable(),
        0,
    )
    _ = dur
    var ctx_ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
    ctx_ptr[0] = ctx
    avcodec.avcodec_free_context(ctx_ptr)


def test_avcodec_is_open() raises:
    var codec = avcodec.avcodec_find_decoder(AVCodecID.AV_CODEC_ID_H264._value)
    var ctx = avcodec.avcodec_alloc_context3(codec)
    var open_before = avcodec.avcodec_is_open(
        ctx.as_immutable(),
    )
    assert_equal(open_before, 0)
    var dict = UnsafePointer[AVDictionary, MutExternalOrigin]()
    var dict_ptr = alloc[UnsafePointer[AVDictionary, MutExternalOrigin]](1)
    dict_ptr[] = dict
    _ = avcodec.avcodec_open2(ctx, codec, dict_ptr)
    var open_after = avcodec.avcodec_is_open(
        ctx.as_immutable(),
    )
    assert_equal(open_after, 1)
    var ctx_ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
    ctx_ptr[0] = ctx
    avcodec.avcodec_free_context(ctx_ptr)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
