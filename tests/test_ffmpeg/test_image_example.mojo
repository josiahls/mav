# Demo: read/write still images with libavcodec + libswscale. Self-contained (not an API).
# Mirrors fixes from momanim `image_write` / `image_read`: suffix vs codec name, pix_fmt
# from extension, swscale into encoder-native buffers, color_range vs color_space.

from std.testing import TestSuite
from std.pathlib import Path
from std.os import getenv
from std.os.path import join
from std.testing import assert_equal
from std.utils import StaticTuple

from std.ffi import c_uchar, c_int, c_long_long, c_double
from std.sys._libc_errno import ErrNo
from mav.ffmpeg.avcodec.packet import AVPacket
from mav.ffmpeg import avcodec
from mav.ffmpeg import avutil
from mav.ffmpeg import swscale
from mav.ffmpeg.avutil.dict import AVDictionary
from mav.ffmpeg.avcodec.defs import AV_INPUT_BUFFER_PADDING_SIZE
from mav.ffmpeg.avutil.avutil import AV_NOPTS_VALUE
from std.memory import memset, memcpy
from mav.ffmpeg.avcodec.avcodec import AVCodecContext
from mav.ffmpeg.avutil.frame import AVFrame
from mav.ffmpeg.avutil.error import AVERROR, AVERROR_EOF
from mav.ffmpeg.avutil.pixfmt import AVPixelFormat, AVColorRange, AVColorSpace
from mav.ffmpeg.avutil.rational import AVRational
from std.logger.logger import Logger, Level, DEFAULT_LEVEL
from mav.ffmpeg.swscale.swscale import SwsContext, SwsFilter, SwsFlags

comptime _logger = Logger[level=DEFAULT_LEVEL]()


@always_inline
def _check(ret: c_int, msg: StringLiteral) raises:
    if ret < 0:
        raise Error(msg.format(avutil.av_err2str(ret)))


@fieldwise_init
struct ImageInfo(Movable, Writable):
    """Decoded frame metadata + owning plane buffers (pointers stay valid for encode).
    """

    var width: c_int
    var height: c_int
    """Pixel format of `plane_buffers` (matches decoder output)."""
    var format: AVPixelFormat.ENUM_DTYPE
    var color_range: c_int
    var color_space: c_int
    var linesize: StaticTuple[c_int, AVFrame.AV_NUM_DATA_POINTERS]
    var plane_buffers: List[List[c_uchar]]

    def __init__(out self):
        self.width = 0
        self.height = 0
        self.format = AVPixelFormat.AV_PIX_FMT_NONE._value
        self.color_range = AVColorRange.AVCOL_RANGE_UNSPECIFIED._value
        self.color_space = AVColorSpace.AVCOL_SPC_UNSPECIFIED._value
        self.linesize = StaticTuple[c_int, AVFrame.AV_NUM_DATA_POINTERS]()
        self.plane_buffers = List[List[c_uchar]]()
        for _ in range(AVFrame.AV_NUM_DATA_POINTERS):
            self.plane_buffers.append(List[c_uchar]())


# BITEXACT + ACCURATE_RND: YUV→RGB rounding can otherwise differ by ±1 between
# SIMD implementations (e.g. AArch64 NEON vs x86), breaking pixel-exact tests.
comptime SCALE_FLAGS = SwsFlags(
    SwsFlags.SWS_BICUBIC.value
    | SwsFlags.SWS_ACCURATE_RND.value
    | SwsFlags.SWS_BITEXACT.value
)


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
    codec_ctx: UnsafePointer[AVCodecContext, MutExternalOrigin]
) raises -> UnsafePointer[AVFrame, MutExternalOrigin]:
    return alloc_frame(
        codec_ctx[].pix_fmt,
        codec_ctx[].width,
        codec_ctx[].height,
        codec_ctx[].color_space,
    )


def get_pix_fmt_from_extension(
    suffix: String,
) raises -> AVPixelFormat.ENUM_DTYPE:
    if suffix == ".png":
        return AVPixelFormat.AV_PIX_FMT_RGB24._value
    elif suffix == ".jpg" or suffix == ".jpeg":
        return AVPixelFormat.AV_PIX_FMT_YUV420P._value
    else:
        raise Error("Unsupported extension: ", suffix)


def decode(
    dec_ctx: UnsafePointer[AVCodecContext, origin=MutExternalOrigin],
    frame: UnsafePointer[AVFrame, origin=MutExternalOrigin],
    pkt: UnsafePointer[AVPacket, origin=MutExternalOrigin],
    mut image_info: ImageInfo,
) raises:
    var ret: c_int = avcodec.avcodec_send_packet(dec_ctx, pkt)
    _logger.debug("Packet sent successfully.")

    while ret >= 0:
        ret = avcodec.avcodec_receive_frame(dec_ctx, frame)
        if ret == AVERROR(ErrNo.EAGAIN.value) or ret == Int32(AVERROR_EOF):
            break
        _logger.debug("Frame received successfully.")

        image_info.width = frame[].width
        image_info.height = frame[].height
        image_info.format = dec_ctx[].pix_fmt
        image_info.color_range = dec_ctx[].color_range
        image_info.color_space = dec_ctx[].color_space
        for i in range(AVFrame.AV_NUM_DATA_POINTERS):
            image_info.linesize[i] = frame[].linesize[i]

        # TODO: plane byte lengths should follow av_image_fill_* per format; this matches
        # the prior demo for full-height planes (ok for packed RGB; YUV chroma may differ).
        for i in range(AVFrame.AV_NUM_DATA_POINTERS):
            if not frame[].data[i]:
                continue
            var plane_h = frame[].height
            if (
                i > 0
                and dec_ctx[].pix_fmt == AVPixelFormat.AV_PIX_FMT_YUV420P._value
            ):
                plane_h = frame[].height >> 1
            image_info.plane_buffers[i].extend(
                Span(
                    ptr=frame[].data[i],
                    length=Int(frame[].linesize[i] * plane_h),
                )
            )


def image_read[in_buffer_size: c_int = 4096](path: Path) raises -> ImageInfo:
    _logger.info("Reading image from path: ", path)

    var dict = UnsafePointer[AVDictionary, MutExternalOrigin]()
    var dict_ptr = alloc[UnsafePointer[AVDictionary, MutExternalOrigin]](1)
    dict_ptr[] = dict
    var extension = path.suffix()

    var input_buffer = InlineArray[
        c_uchar, Int(in_buffer_size + AV_INPUT_BUFFER_PADDING_SIZE)
    ](uninitialized=True)

    memset(
        input_buffer.unsafe_ptr() + in_buffer_size,
        0,
        Int(AV_INPUT_BUFFER_PADDING_SIZE),
    )

    var packet = avcodec.av_packet_alloc()
    var codec = avcodec.avcodec_find_decoder_by_name(extension)
    var parser = avcodec.av_parser_init(codec[].id)
    var context = avcodec.avcodec_alloc_context3(codec)
    var ret = avcodec.avcodec_open2(context, codec, dict_ptr)
    assert_equal(ret, 0)
    var frame = avutil.av_frame_alloc()
    var image_info = ImageInfo()

    with open(path, "r") as f:
        while True:
            var data = (
                input_buffer.unsafe_ptr()
                .as_immutable()
                .unsafe_origin_cast[ImmutExternalOrigin]()
            )
            var data_size = c_int(f.read(buffer=input_buffer))
            if data_size == 0:
                break

            while data_size > 0:
                _logger.debug("Data size: ", data_size)
                var size = avcodec.av_parser_parse2(
                    parser,
                    context,
                    UnsafePointer(to=packet[].data),
                    UnsafePointer(to=packet[].size),
                    data,
                    data_size,
                    AV_NOPTS_VALUE,
                    AV_NOPTS_VALUE,
                    0,
                )

                _logger.debug("Parsed size: ", size)
                data += size
                data_size -= size

                if packet[].size > 0:
                    _logger.debug("Packet size is: ", packet[].size)
                    decode(
                        context,
                        frame,
                        packet,
                        image_info,
                    )

    _logger.debug(
        "Image info dimensions: ", image_info.width, "x", image_info.height
    )

    var frame_ptr = alloc[UnsafePointer[AVFrame, MutExternalOrigin]](1)
    frame_ptr[] = frame
    avutil.av_frame_free(frame_ptr)
    frame_ptr.free()
    var pkt_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
    pkt_ptr[] = packet
    avcodec.av_packet_free(pkt_ptr)
    pkt_ptr.free()
    avcodec.av_parser_close(parser)
    var ctx_ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
    ctx_ptr[] = context
    avcodec.avcodec_free_context(ctx_ptr)
    ctx_ptr.free()

    return image_info^


def encode(
    enc_ctx: UnsafePointer[AVCodecContext, origin=MutExternalOrigin],
    frame: UnsafePointer[AVFrame, origin=MutExternalOrigin],
    pkt: UnsafePointer[AVPacket, origin=MutExternalOrigin],
    mut outfile: FileHandle,
) raises:
    var ret = avcodec.avcodec_send_frame(enc_ctx, frame)
    if ret < 0:
        raise Error("Failed to send frame for encoding: ", ret)

    while ret >= 0:
        ret = avcodec.avcodec_receive_packet(enc_ctx, pkt)
        if ret == AVERROR(ErrNo.EAGAIN.value) or ret == Int32(AVERROR_EOF):
            break

        outfile.write_bytes(
            Span(
                ptr=pkt[].data,
                length=Int(pkt[].size),
            )
        )
        avcodec.av_packet_unref(pkt)


def image_write(image_info: ImageInfo, path: Path) raises:
    _logger.info("Saving image to path: ", path)

    var dict = UnsafePointer[AVDictionary, MutExternalOrigin]()
    var dict_ptr = alloc[UnsafePointer[AVDictionary, MutExternalOrigin]](1)
    dict_ptr[] = dict
    var suffix = path.suffix()
    var codec_name = suffix
    if suffix == ".jpeg" or suffix == ".jpg":
        codec_name = "mjpeg"

    var sws_ctx_ptr = UnsafePointer[SwsContext, MutExternalOrigin]()
    var sws_ctx = alloc[type_of(sws_ctx_ptr)](1)
    sws_ctx[] = sws_ctx_ptr

    var from_fmt = image_info.format
    var codec = avcodec.avcodec_find_encoder_by_name(codec_name)
    var context = avcodec.avcodec_alloc_context3(codec)
    context[].time_base = AVRational(num=1, den=25)
    context[].width = image_info.width
    context[].height = image_info.height
    context[].color_range = image_info.color_range
    context[].color_space = image_info.color_space
    context[].pix_fmt = get_pix_fmt_from_extension(suffix)
    var packet = avcodec.av_packet_alloc()

    _check(
        avcodec.avcodec_open2(context, codec, dict_ptr),
        "Failed to open codec: {}",
    )

    var src_frame = alloc_frame(
        from_fmt,
        image_info.width,
        image_info.height,
        image_info.color_space,
    )
    src_frame[].color_range = image_info.color_range
    _check(
        avutil.av_frame_make_writable(src_frame),
        "Failed to make source frame writable: {}",
    )
    for j in range(AVFrame.AV_NUM_DATA_POINTERS):
        if len(image_info.plane_buffers[j]) == 0:
            continue
        memcpy(
            dest=src_frame[].data[j],
            src=image_info.plane_buffers[j].unsafe_ptr(),
            count=len(image_info.plane_buffers[j]),
        )
    src_frame[].pts = 0

    var dst_frame = alloc_frame(context)
    _check(
        avutil.av_frame_make_writable(dst_frame),
        "Failed to make frame writable: {}",
    )
    convert_format(
        src_frame=src_frame,
        dst_frame=dst_frame,
        sws_ctx=sws_ctx,
        enc=context,
        src_format=from_fmt,
        dst_format=context[].pix_fmt,
    )

    with open(path, "w") as f:
        encode(
            context,
            dst_frame,
            packet,
            f,
        )

        encode(
            context,
            UnsafePointer[AVFrame, origin=MutExternalOrigin](),
            packet,
            f,
        )

        swscale.sws_freeContext(sws_ctx[])

        var src_ptr = alloc[UnsafePointer[AVFrame, MutExternalOrigin]](1)
        src_ptr[] = src_frame
        avutil.av_frame_free(src_ptr)
        src_ptr.free()
        var dst_ptr = alloc[UnsafePointer[AVFrame, MutExternalOrigin]](1)
        dst_ptr[] = dst_frame
        avutil.av_frame_free(dst_ptr)
        dst_ptr.free()
        var pkt_ptr = alloc[UnsafePointer[AVPacket, MutExternalOrigin]](1)
        pkt_ptr[] = packet
        avcodec.av_packet_free(pkt_ptr)
        pkt_ptr.free()
        var ctx_ptr = alloc[UnsafePointer[AVCodecContext, MutExternalOrigin]](1)
        ctx_ptr[] = context
        avcodec.avcodec_free_context(ctx_ptr)
        ctx_ptr.free()


def test_image_write() raises:
    var test_data_root = getenv("PIXI_PROJECT_ROOT")
    var root_path = join(
        test_data_root, "test_data/generate_test_videos_testsrc_128x128.png"
    )
    var image = image_read(Path(root_path))
    var out1 = join(
        test_data_root, "test_data/test_image_example/test_image_write.png"
    )
    image_write(image, Path(out1))
    var out2 = join(
        test_data_root, "test_data/test_image_example/test_image_write.jpg"
    )
    image_write(image, Path(out2))


def main() raises:
    # NOTE: valgrind should produce max 242 blocks.
    # TestSuite.discover_tests[__functions_in_module()]().run()
    test_image_write()
