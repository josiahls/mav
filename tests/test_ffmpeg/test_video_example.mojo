# Demo: remux/decode a video to in-memory RGBA frames, then encode to MP4/WebM.
# Self-contained (not an API). Merged from momanim `video_read` / `video_write` with:
# - `alloc_frame(codec_ctx)` using `color_space` (not `color_range`) for frame colorspace
# - shared `convert_format` + swscale flags from `momanim/io_backends/mav/utils.mojo`

from std.testing import TestSuite
from std.pathlib import Path
from std.os import getenv
from std.os.path import join
import std.os
from std.itertools import count
from std.ffi import c_uchar, c_int, c_long_long, c_double
from std.sys._libc_errno import ErrNo

from mav.ffmpeg.avcodec.packet import AVPacket
from mav.ffmpeg.avutil.avutil import AVMediaType
from mav.ffmpeg.avcodec.codec_id import AVCodecID
from mav.ffmpeg.avutil.rational import AVRational
from mav.ffmpeg.avutil.dict import AVDictionary
from mav.ffmpeg.avcodec.avcodec import (
    AVCodecContext,
    AV_CODEC_FLAG_GLOBAL_HEADER,
)
from mav.ffmpeg.avutil.frame import AVFrame
from mav.ffmpeg import avcodec
from mav.ffmpeg.avutil.error import AVERROR, AVERROR_EOF
from mav.ffmpeg.avformat.avformat import (
    AVFormatContext,
    AVStream,
    AVFMT_GLOBALHEADER,
    AVFMT_NOFILE,
)
from mav.ffmpeg.avformat.avio import AVIOContext
from mav.ffmpeg.avcodec.codec import AVCodec
from mav.ffmpeg.swscale.swscale import (
    SwsContext,
    SwsFilter,
    SwsFlags,
    SwsDither,
)
from mav.ffmpeg.avformat import AVIO_FLAG_WRITE
from mav.ffmpeg import avformat
from mav.ffmpeg import avutil
from mav.ffmpeg.avutil.samplefmt import AVSampleFormat
from mav.ffmpeg.avutil.channel_layout import (
    AVChannelLayout,
    AV_CHANNEL_LAYOUT_STEREO,
)
from mav.ffmpeg.avutil.pixfmt import AVPixelFormat, AVColorSpace
from mav.ffmpeg import swscale
from mav.ffmpeg import swrsample
from mav.ffmpeg.swrsample import SwrContext
from std.logger.logger import Logger, Level, DEFAULT_LEVEL

comptime _logger = Logger[level=Level.DEBUG]()

comptime STREAM_FRAME_RATE = 25
comptime STREAM_DURATION: Float32 = 10.0
comptime SCALE_FLAGS = SwsFlags(
    SwsFlags.SWS_BICUBIC.value
    | SwsFlags.SWS_ACCURATE_RND.value
    | SwsFlags.SWS_BITEXACT.value
)


@always_inline
def _check(ret: c_int, msg: StringLiteral) raises:
    if ret < 0:
        raise Error(msg.format(avutil.av_err2str(ret)))


def convert_format(
    mut src_frame: UnsafePointer[AVFrame, origin=MutExternalOrigin],
    mut dst_frame: UnsafePointer[AVFrame, origin=MutExternalOrigin],
    mut sws_ctx: UnsafePointer[
        UnsafePointer[SwsContext, origin=MutExternalOrigin],
        origin=MutExternalOrigin,
    ],
    mut enc: UnsafePointer[AVCodecContext, origin=MutExternalOrigin],
    src_format: AVPixelFormat.ENUM_DTYPE,
    dst_format: AVPixelFormat.ENUM_DTYPE,
) raises:
    _ = enc
    var src_w = src_frame[].width
    var src_h = src_frame[].height
    var dst_w = dst_frame[].width
    var dst_h = dst_frame[].height

    if not sws_ctx[]:
        sws_ctx[] = swscale.sws_getContext(
            src_w,
            src_h,
            src_format,
            dst_w,
            dst_h,
            dst_format,
            SCALE_FLAGS.value,
            UnsafePointer[SwsFilter, MutExternalOrigin](),
            UnsafePointer[SwsFilter, MutExternalOrigin](),
            UnsafePointer[c_double, ImmutExternalOrigin](),
        )
        if not sws_ctx[]:
            raise Error("Failed to initialize conversion context")
        if dst_format == AVPixelFormat.AV_PIX_FMT_RGB8._value:
            sws_ctx[][].dither = SwsDither.SWS_DITHER_NONE.value

    var src_slice = alloc[UnsafePointer[c_uchar, ImmutExternalOrigin]](8)
    for i in range(8):
        src_slice[i] = src_frame[].data[i].as_immutable()
    var dst_slice = alloc[UnsafePointer[c_uchar, MutExternalOrigin]](8)
    for i in range(8):
        dst_slice[i] = dst_frame[].data[i]

    var res = swscale.sws_scale(
        sws_ctx[],
        src_slice,
        src_frame[].linesize.unsafe_ptr(),
        0,
        src_h,
        dst_slice,
        dst_frame[].linesize.unsafe_ptr(),
    )
    src_slice.free()
    dst_slice.free()
    if res < 0:
        raise Error("Failed to scale image: {}".format(avutil.av_err2str(res)))


def alloc_frame(
    pix_fmt: AVPixelFormat.ENUM_DTYPE,
    width: c_int,
    height: c_int,
    colorspace: c_int,
) raises -> UnsafePointer[AVFrame, MutExternalOrigin]:
    var frame = avutil.av_frame_alloc()
    frame[].format = pix_fmt
    frame[].width = width
    frame[].height = height
    frame[].colorspace = colorspace
    _check(
        avutil.av_frame_get_buffer(frame, 0),
        "Failed to allocate frame buffer: {}",
    )
    return frame


def alloc_frame(
    codec: UnsafePointer[AVCodecContext, MutExternalOrigin]
) raises -> UnsafePointer[AVFrame, MutExternalOrigin]:
    return alloc_frame(
        codec[].pix_fmt,
        codec[].width,
        codec[].height,
        codec[].color_space,
    )


# --- In-memory video for this demo only (RGBA frames, packed). -----------------


struct DemoVideo(Copyable, Movable, Sized, Writable):
    var w: UInt
    var h: UInt
    var ch: UInt
    var linesize: Int
    var frames: List[List[c_uchar]]

    def __init__(out self) raises:
        self.w = 0
        self.h = 0
        self.ch = 4
        self.linesize = 0
        self.frames = List[List[c_uchar]]()

    def __len__(self) -> Int:
        return len(self.frames)

    def unsafe_ptr(
        mut self, frame_idx: Int
    ) -> UnsafePointer[Scalar[DType.uint8], MutExternalOrigin]:
        return (
            self.frames[frame_idx]
            .unsafe_ptr()
            .unsafe_origin_cast[MutExternalOrigin]()
        )

    def steal_frame(
        mut self,
        data0: UnsafePointer[Scalar[DType.uint8], MutExternalOrigin],
        linesize: Int,
        copy: Bool,
    ) raises:
        _ = copy
        self.linesize = linesize
        var buf_size = linesize * Int(self.h)
        var copy_list = List[c_uchar]()
        copy_list.extend(Span(ptr=data0.bitcast[c_uchar](), length=buf_size))
        self.frames.append(copy_list^)


def decode_packet(
    oc: UnsafePointer[AVFormatContext, MutExternalOrigin],
    mut video_codec_ctx: UnsafePointer[AVCodecContext, MutExternalOrigin],
    packet: UnsafePointer[AVPacket, MutExternalOrigin],
    mut frame: UnsafePointer[AVFrame, MutExternalOrigin],
    mut video: DemoVideo,
    mut sws_ctx: UnsafePointer[
        UnsafePointer[SwsContext, MutExternalOrigin], MutExternalOrigin
    ],
) raises -> c_int:
    _ = oc
    var ret = avcodec.avcodec_send_packet(video_codec_ctx, packet)
    if ret < 0:
        raise Error("Failed to send packet: {}".format(avutil.av_err2str(ret)))

    while ret >= 0:
        ret = avcodec.avcodec_receive_frame(video_codec_ctx, frame)
        if ret == AVERROR(ErrNo.EAGAIN.value) or ret == Int32(AVERROR_EOF):
            break
        _check(ret, "Failed to receive frame: {}")

        if frame[].format != AVPixelFormat.AV_PIX_FMT_RGBA._value:
            var tmp_frame = alloc_frame(
                AVPixelFormat.AV_PIX_FMT_RGBA._value,
                frame[].width,
                frame[].height,
                AVColorSpace.AVCOL_SPC_RGB._value,
            )
            ret = avutil.av_frame_make_writable(tmp_frame)
            _check(ret, "Failed to make tmp frame writable: {}")

            convert_format(
                src_frame=frame,
                dst_frame=tmp_frame,
                sws_ctx=sws_ctx,
                enc=video_codec_ctx,
                src_format=frame[].format,
                dst_format=AVPixelFormat.AV_PIX_FMT_RGBA._value,
            )
            video.steal_frame(
                tmp_frame[].data[0],
                Int(tmp_frame[].linesize[0]),
                copy=True,
            )
            var tmp_ptr = alloc[UnsafePointer[AVFrame, MutExternalOrigin]](1)
            tmp_ptr[] = tmp_frame
            avutil.av_frame_free(tmp_ptr)
            tmp_ptr.free()
        else:
            video.steal_frame(
                frame[].data[0], Int(frame[].linesize[0]), copy=True
            )

    return ret


def demo_video_read(path: Path) raises -> List[DemoVideo]:
    if not path.exists():
        raise Error("File does not exist: {}".format(path))

    _logger.info("Reading video from path: ", path)
    var packet = avcodec.av_packet_alloc()
    var oc = alloc[UnsafePointer[AVFormatContext, MutExternalOrigin]](1)
    oc[] = UnsafePointer[AVFormatContext, MutExternalOrigin]()
    var path_copy = String(path).copy()
    _check(
        avformat.avformat_open_input(
            s=oc, url=path_copy, fmt=None, options=None
        ),
        "Failed to open input: {}",
    )
    var videos = List[DemoVideo](capacity=Int(oc[][].nb_streams))
    _check(
        avformat.avformat_find_stream_info(ic=oc[], options=None),
        "Failed to find stream info: {}",
    )

    var video_stream_mapping = List[Int](capacity=Int(oc[][].nb_streams))
    for i in range(oc[][].nb_streams):
        var in_stream = oc[][].streams[i]
        var codecpar = in_stream[].codecpar
        if codecpar[].codec_type == AVMediaType.AVMEDIA_TYPE_VIDEO._value:
            _logger.info("Found video stream: {}".format(i))
            video_stream_mapping.append(Int(i))

    for i in video_stream_mapping:
        var video_stream = oc[][].streams[i]
        var video_codec_id = video_stream[].codecpar[].codec_id
        var video_codec = avcodec.avcodec_find_decoder(video_codec_id)
        var video_codec_ctx = avcodec.avcodec_alloc_context3(video_codec)
        var sws_ctx = alloc[UnsafePointer[SwsContext, MutExternalOrigin]](1)
        sws_ctx[] = UnsafePointer[SwsContext, MutExternalOrigin]()
        var video = DemoVideo()

        _check(
            avcodec.avcodec_parameters_to_context(
                video_codec_ctx, video_stream[].codecpar
            ),
            "Failed to copy codec parameters: {}",
        )

        _check(
            avcodec.avcodec_open2(video_codec_ctx, video_codec),
            "Failed to open video codec: {}",
        )
        video.w = UInt(video_stream[].codecpar[].width)
        video.h = UInt(video_stream[].codecpar[].height)
        video.ch = 4
        var frame = alloc_frame(
            video_codec_ctx[].pix_fmt,
            c_int(video.w),
            c_int(video.h),
            video_codec_ctx[].color_space,
        )
        _check(
            avutil.av_frame_make_writable(frame),
            "Failed to make frame writable: {}",
        )
        while True:
            var r = avformat.av_read_frame(oc[], packet)
            if r == Int32(AVERROR_EOF):
                break
            _check(r, "Failed to read frame: {}")

            if Int(packet[].stream_index) == i:
                _ = decode_packet(
                    oc[], video_codec_ctx, packet, frame, video, sws_ctx
                )

            avcodec.av_packet_unref(packet)

        if sws_ctx[]:
            swscale.sws_freeContext(sws_ctx[])
            sws_ctx[] = UnsafePointer[SwsContext, MutExternalOrigin]()
        sws_ctx.free()
        videos.append(video^)

        var enc_ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
        enc_ptr[] = video_codec_ctx
        avcodec.avcodec_free_context(enc_ptr)
        enc_ptr.free()
        var frame_ptr = alloc[UnsafePointer[AVFrame, MutExternalOrigin]](1)
        frame_ptr[] = frame
        avutil.av_frame_free(frame_ptr)
        frame_ptr.free()

    var pkt_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    pkt_ptr[] = packet
    avcodec.av_packet_free(pkt_ptr)
    pkt_ptr.free()
    avformat.avformat_close_input(oc)
    oc.free()
    return videos^


# --- Mux / encode (from video_write) -------------------------------------------


struct OutputStream(Copyable, Movable):
    var st: UnsafePointer[AVStream, origin=MutExternalOrigin]
    var codec: UnsafePointer[AVCodec, origin=ImmutExternalOrigin]
    var enc: UnsafePointer[AVCodecContext, origin=MutExternalOrigin]
    var next_pts: c_long_long
    var samples_count: c_int
    var frame: UnsafePointer[AVFrame, origin=MutExternalOrigin]
    var conversion_frame: UnsafePointer[AVFrame, origin=MutExternalOrigin]
    var pkt: UnsafePointer[AVPacket, origin=MutExternalOrigin]
    var sws_ctx: UnsafePointer[
        UnsafePointer[SwsContext, origin=MutExternalOrigin],
        origin=MutExternalOrigin,
    ]
    var swr_ctx: UnsafePointer[SwrContext, origin=MutExternalOrigin]

    def __init__(out self) raises:
        self.st = UnsafePointer[AVStream, MutExternalOrigin]()
        self.codec = UnsafePointer[AVCodec, MutExternalOrigin]()
        self.enc = UnsafePointer[AVCodecContext, MutExternalOrigin]()
        self.next_pts = c_long_long(0)
        self.samples_count = c_int(0)
        self.frame = UnsafePointer[AVFrame, MutExternalOrigin]()
        self.conversion_frame = UnsafePointer[AVFrame, MutExternalOrigin]()
        self.pkt = UnsafePointer[AVPacket, MutExternalOrigin]()
        var sws_ctx_ptr = UnsafePointer[SwsContext, MutExternalOrigin]()
        self.sws_ctx = alloc[type_of(sws_ctx_ptr)](1)
        self.sws_ctx[] = sws_ctx_ptr
        self.swr_ctx = UnsafePointer[SwrContext, MutExternalOrigin]()

    def __del__(deinit self):
        if self.frame:
            var ptr = alloc[UnsafePointer[AVFrame, MutExternalOrigin]](1)
            ptr[] = self.frame
            avutil.av_frame_free(ptr)
            ptr.free()
        if self.conversion_frame:
            var ptr = alloc[UnsafePointer[AVFrame, MutExternalOrigin]](1)
            ptr[] = self.conversion_frame
            avutil.av_frame_free(ptr)
            ptr.free()
        if self.pkt:
            var ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
            ptr[] = self.pkt
            avcodec.av_packet_free(ptr)
            ptr.free()
        if self.enc:
            var ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
            ptr[] = self.enc
            avcodec.avcodec_free_context(ptr)
            ptr.free()
        if self.sws_ctx:
            if self.sws_ctx[]:
                swscale.sws_freeContext(self.sws_ctx[])
            self.sws_ctx.free()


def open_video(
    oc: UnsafePointer[AVFormatContext, MutExternalOrigin],
    mut ost: OutputStream,
    opt_arg: UnsafePointer[AVDictionary, ImmutExternalOrigin],
) raises:
    _ = opt_arg
    _check(
        avcodec.avcodec_open2(ost.enc, ost.codec),
        "Failed to open codec: {}",
    )

    ost.frame = alloc_frame(ost.enc)
    if not ost.frame:
        std.os.abort("Failed to allocate video frame")

    ost.conversion_frame = alloc_frame(ost.enc)

    _check(
        avcodec.avcodec_parameters_from_context(ost.st[].codecpar, ost.enc),
        "Failed to copy the stream parameters: {}",
    )


def add_stream(
    oc: UnsafePointer[AVFormatContext, MutExternalOrigin],
    video: DemoVideo,
    fps: UInt,
) raises -> OutputStream:
    var ost = OutputStream()

    ost.codec = avcodec.avcodec_find_encoder(oc[].oformat[].video_codec)
    if not ost.codec:
        raise Error("Failed to find encoder")

    ost.pkt = avcodec.av_packet_alloc()
    if not ost.pkt:
        raise Error("Failed to allocate AVPacket")

    ost.st = avformat.avformat_new_stream(
        oc,
        UnsafePointer[AVCodec, ImmutExternalOrigin](),
    )
    if not ost.st:
        raise Error("Failed to allocate stream")

    ost.st[].id = c_int(oc[].nb_streams - 1)

    ost.enc = avcodec.avcodec_alloc_context3(ost.codec)
    if not ost.enc:
        raise Error("Failed to allocate encoding context")

    ref codec_type = ost.codec[].type
    if codec_type == AVMediaType.AVMEDIA_TYPE_AUDIO._value:
        if not ost.codec[].sample_fmts:
            ost.enc[].sample_fmt = AVSampleFormat.AV_SAMPLE_FMT_FLTP._value
        else:
            ost.enc[].sample_fmt = ost.codec[].sample_fmts[]
        ost.enc[].bit_rate = 64000
        ost.enc[].sample_rate = 44100
        if ost.codec[].supported_samplerates:
            ost.enc[].sample_rate = ost.codec[].supported_samplerates[]
            for j in count():
                if not ost.codec[].supported_samplerates[j]:
                    break
                if ost.codec[].supported_samplerates[j] == 44100:
                    ost.enc[].sample_rate = 44100

        var layout = alloc[AVChannelLayout](1)
        layout[] = AV_CHANNEL_LAYOUT_STEREO
        var dst = UnsafePointer(to=ost.enc[].ch_layout)
        _check(
            avutil.av_channel_layout_copy(dst, layout),
            "Failed to copy channel layout: {}",
        )
        ost.st[].time_base = AVRational(num=1, den=ost.enc[].sample_rate)

    elif codec_type == AVMediaType.AVMEDIA_TYPE_VIDEO._value:
        ost.enc[].codec_id = oc[].oformat[].video_codec
        ost.enc[].bit_rate = 400000
        ost.enc[].width = c_int(video.w)
        ost.enc[].height = c_int(video.h)
        ost.st[].time_base = AVRational(num=1, den=c_int(fps))
        ost.enc[].time_base = ost.st[].time_base

        ost.enc[].gop_size = 12
        ost.enc[].pix_fmt = AVPixelFormat.AV_PIX_FMT_YUV420P._value
        if ost.enc[].codec_id == AVCodecID.AV_CODEC_ID_GIF._value:
            ost.enc[].pix_fmt = AVPixelFormat.AV_PIX_FMT_RGB8._value
        if ost.enc[].codec_id == AVCodecID.AV_CODEC_ID_MPEG2VIDEO._value:
            ost.enc[].max_b_frames = 2

        if ost.enc[].codec_id == AVCodecID.AV_CODEC_ID_MPEG1VIDEO._value:
            ost.enc[].mb_decision = 2

    if oc[].oformat[].flags & AVFMT_GLOBALHEADER:
        ost.enc[].flags |= AV_CODEC_FLAG_GLOBAL_HEADER

    return ost^


def get_video_frame(
    mut ost: OutputStream,
    mut video: DemoVideo,
    max_duration_seconds: Float32,
) raises -> UnsafePointer[AVFrame, MutExternalOrigin]:
    var comparison = avutil.av_compare_ts(
        ost.next_pts,
        ost.enc[].time_base,
        c_long_long(Int(max_duration_seconds)),
        AVRational(num=1, den=1),
    )

    if comparison > 0:
        _logger.info("No more frames to encode")
        return UnsafePointer[AVFrame, MutExternalOrigin]()

    if avutil.av_frame_make_writable(ost.frame) < 0:
        raise Error("Failed to make frame writable")

    var frame_ptr = video.unsafe_ptr(Int(ost.next_pts))

    ost.conversion_frame[].format = AVPixelFormat.AV_PIX_FMT_RGBA._value

    if ost.conversion_frame[].format != ost.enc[].pix_fmt:
        var ret = avutil.av_frame_make_writable(ost.conversion_frame)
        _check(ret, "Failed to make tmp frame writable: {}")
        ost.conversion_frame[].data[0] = frame_ptr
        ost.conversion_frame[].linesize[0] = c_int(video.linesize)

        convert_format(
            src_frame=ost.conversion_frame,
            dst_frame=ost.frame,
            sws_ctx=ost.sws_ctx,
            enc=ost.enc,
            src_format=ost.conversion_frame[].format,
            dst_format=ost.enc[].pix_fmt,
        )
    else:
        ost.frame[].data[0] = frame_ptr

    ost.frame[].pts = ost.next_pts
    ost.next_pts += 1

    return ost.frame


def write_frame(
    mut fmt_ctx: UnsafePointer[AVFormatContext, MutExternalOrigin],
    mut ost: OutputStream,
    mut video: DemoVideo,
    max_duration_seconds: Float32,
) raises -> c_int:
    var frame: UnsafePointer[AVFrame, ImmutExternalOrigin]
    if Int(ost.next_pts) >= len(video):
        frame = UnsafePointer[AVFrame, ImmutExternalOrigin]()
    else:
        frame = get_video_frame(ost, video, max_duration_seconds)

    var ret = c_int(0)

    _check(
        avcodec.avcodec_send_frame(ost.enc, frame), "Failed to send frame: {}"
    )

    while ret >= 0:
        ret = avcodec.avcodec_receive_packet(ost.enc, ost.pkt)
        if ret == AVERROR(ErrNo.EAGAIN.value) or ret == Int32(AVERROR_EOF):
            break
        _check(ret, "Failed to receive packet: {}")

        avcodec.av_packet_rescale_ts(
            ost.pkt, ost.enc[].time_base, ost.st[].time_base
        )
        ost.pkt[].stream_index = ost.st[].index
        _check(
            avformat.av_interleaved_write_frame(fmt_ctx, ost.pkt),
            "Failed to write packet: {}",
        )

        avcodec.av_packet_unref(ost.pkt)
        if ret < 0:
            break

    return c_int(ret == Int32(AVERROR_EOF))


def demo_video_write(
    mut videos: List[DemoVideo],
    path: Path,
    fps: UInt = STREAM_FRAME_RATE,
    max_duration_seconds: Float32 = STREAM_DURATION,
) raises:
    _logger.info("Saving video to path: ", path)

    var oc = alloc[UnsafePointer[AVFormatContext, MutExternalOrigin]](1)
    var path_s = String(path)
    var ret = avformat.avformat_alloc_output_context(
        ctx=oc,
        filename=path_s,
    )
    if ret < 0:
        raise Error("Failed to allocate output context: {}".format(ret))
    if not oc[]:
        raise Error("Failed to allocate output context")
    var opt = alloc[UnsafePointer[AVDictionary, MutExternalOrigin]](1)
    opt[] = UnsafePointer[AVDictionary, MutExternalOrigin]()

    var fmt = UnsafePointer(to=oc[][].oformat)
    if not fmt:
        raise Error("Failed to find output format")
    if fmt[][].video_codec == AVCodecID.AV_CODEC_ID_NONE._value:
        raise Error("Failed to find video codec")

    if oc[][].oformat[].video_codec == AVCodecID.AV_CODEC_ID_NONE._value:
        raise Error("Failed to find video codec")

    var output_streams = List[OutputStream](capacity=Int(len(videos)))
    for ref video in videos:
        output_streams.append(add_stream(oc[], video, fps))
        open_video(oc[], output_streams[-1], opt[])

    avformat.av_dump_format(oc[], 0, path_s, 1)
    if not (oc[][].oformat[].flags & AVFMT_NOFILE):
        _check(
            avformat.avio_open(
                UnsafePointer(to=oc[][].pb),
                path_s,
                AVIO_FLAG_WRITE,
            ),
            "Failed to open output file: {}",
        )

    _check(
        avformat.avformat_write_header(oc[], opt), "Failed to write header: {}"
    )

    var i = 0
    for ref stream in output_streams:
        ref video = videos[i]
        var do_encode_video = True
        while do_encode_video:
            do_encode_video = (
                write_frame(oc[], stream, video, max_duration_seconds) == 0
            )
        i += 1

    _check(avformat.av_write_trailer(oc[]), "Failed to write trailer: {}")

    if not (oc[][].oformat[].flags & AVFMT_NOFILE) and oc[][].pb:
        var pb_ptr = alloc[UnsafePointer[AVIOContext, MutExternalOrigin]](1)
        pb_ptr[] = oc[][].pb
        _ = avformat.avio_closep(pb_ptr)
        oc[][].pb = pb_ptr[]
        pb_ptr.free()

    avformat.avformat_free_context(oc[])
    oc.free()
    opt.free()


def test_video_write() raises:
    var test_data_root = getenv("PIXI_PROJECT_ROOT")
    var root_path = join(
        test_data_root,
        "test_data/generate_test_videos_testsrc_320x180_30fps_2s.mp4",
    )
    std.os.makedirs(
        Path(join(test_data_root, "test_data/test_video_example")),
        exist_ok=True,
    )
    var save_path = join(
        test_data_root, "test_data/test_video_example/test_video_save.mp4"
    )
    var parent_path_parts = Path(save_path).parts()[:-1]
    var parent_path = Path(String(std.os.sep).join(parent_path_parts))
    std.os.makedirs(parent_path, exist_ok=True)

    var videos = demo_video_read(Path(root_path))
    demo_video_write(videos, Path(save_path))
    var save_path_2 = join(
        test_data_root, "test_data/test_video_example/test_video_save.webm"
    )
    demo_video_write(videos, Path(save_path_2))

    demo_video_write(
        videos,
        Path(
            join(
                test_data_root,
                "test_video_save.gif",
            )
        ),
    )


def main() raises:
    # NOTE: valgrind should produce max 242 blocks.
    TestSuite.discover_tests[__functions_in_module()]().run()
