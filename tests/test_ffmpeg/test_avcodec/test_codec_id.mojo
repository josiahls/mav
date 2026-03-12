from std.testing import TestSuite, assert_equal
from std.memory import memset
from std.ffi import c_uchar, c_int, c_char
from std.sys._libc_errno import ErrNo

from mav.ffmpeg.avcodec.packet import AVPacket
from mav.ffmpeg.avutil.avutil import AV_NOPTS_VALUE
from mav.ffmpeg.avutil.rational import AVRational
from mav.ffmpeg.avutil.buffer import AVBufferRef
from mav.ffmpeg.avutil.buffer_internal import AVBuffer
from mav.ffmpeg.avutil.dict import AVDictionary
from mav.ffmpeg.avcodec.avcodec import AVCodecContext
from mav.ffmpeg.avutil.frame import AVFrame
from mav.ffmpeg.avcodec.packet import (
    AVPacketSideData,
    AVPacketSideDataType,
)
from mav.ffmpeg.avcodec.defs import AV_INPUT_BUFFER_PADDING_SIZE
from mav.ffmpeg.avcodec.codec_id import AVCodecID
from mav.ffmpeg.avutil.error import AVERROR, AVERROR_EOF


def test_codec_id() raises:
    # NOTE: May need to have this test adjust depending on FFmpeg versions.
    # Note: This test assumes all of the flags in the xors are true
    assert_equal(AVCodecID.AV_CODEC_ID_MPEG1VIDEO._value, 1)
    assert_equal(AVCodecID.AV_CODEC_ID_MPEG2VIDEO._value, 2)
    assert_equal(AVCodecID.AV_CODEC_ID_H264._value, 27)
    # 1st macro alias another enum field
    assert_equal(AVCodecID.AV_CODEC_ID_IFF_BYTERUN1._value, 136)
    # 2nd macro that optionally inserts AV_CODEC_ID_V410 as a field.
    assert_equal(AVCodecID.AV_CODEC_ID_V410._value, 156)
    assert_equal(AVCodecID.AV_CODEC_ID_XWD._value, 157)
    # 3rd macro alias another enum field
    assert_equal(AVCodecID.AV_CODEC_ID_H265._value, 173)
    # 4th macro alias another enum field
    assert_equal(AVCodecID.AV_CODEC_ID_H266._value, 196)
    assert_equal(AVCodecID.AV_CODEC_ID_TARGA_Y216._value, 201)
    assert_equal(AVCodecID.AV_CODEC_ID_V308._value, 202)
    assert_equal(AVCodecID.AV_CODEC_ID_V408._value, 203)
    assert_equal(AVCodecID.AV_CODEC_ID_YUV4._value, 204)
    assert_equal(AVCodecID.AV_CODEC_ID_AVRN._value, 205)
    assert_equal(AVCodecID.AV_CODEC_ID_PRORES_RAW._value, 274)

    # Audio enum fields.
    assert_equal(AVCodecID.AV_CODEC_ID_FIRST_AUDIO._value, 65536)
    assert_equal(AVCodecID.AV_CODEC_ID_PCM_S16LE._value, 65536)
    assert_equal(AVCodecID.AV_CODEC_ID_PCM_SGA._value, 65536 + 36)
    # various ADPCM codecs
    assert_equal(AVCodecID.AV_CODEC_ID_ADPCM_IMA_QT._value, 69632)
    assert_equal(AVCodecID.AV_CODEC_ID_ADPCM_SANYO._value, 69632 + 53)

    # AMR
    assert_equal(AVCodecID.AV_CODEC_ID_AMR_NB._value, 0x12000)
    assert_equal(AVCodecID.AV_CODEC_ID_AMR_WB._value, 0x12000 + 1)
    # RealAudio codecs
    assert_equal(AVCodecID.AV_CODEC_ID_RA_144._value, 0x13000)
    assert_equal(AVCodecID.AV_CODEC_ID_RA_288._value, 0x13000 + 1)
    # various DPCM codecs
    assert_equal(AVCodecID.AV_CODEC_ID_ROQ_DPCM._value, 0x14000)
    assert_equal(AVCodecID.AV_CODEC_ID_CBD2_DPCM._value, 0x14000 + 8)
    # audio codecs
    assert_equal(AVCodecID.AV_CODEC_ID_MP2._value, 0x15000)
    assert_equal(AVCodecID.AV_CODEC_ID_G728._value, 0x15000 + 107)
    # subtitle / other sections
    assert_equal(AVCodecID.AV_CODEC_ID_FIRST_SUBTITLE._value, 0x17000)
    # Note there are 2 fields with the same id, so the fields are -1 lower.
    assert_equal(AVCodecID.AV_CODEC_ID_IVTV_VBI._value, 0x17000 + 26)
    # other specific kind of codecs
    assert_equal(AVCodecID.AV_CODEC_ID_FIRST_UNKNOWN._value, 0x18000)
    assert_equal(AVCodecID.AV_CODEC_ID_TTF._value, 0x18000)
    assert_equal(AVCodecID.AV_CODEC_ID_SMPTE_436M_ANC._value, 0x18000 + 13)

    # Misc other codec ids
    assert_equal(AVCodecID.AV_CODEC_ID_PROBE._value, 0x19000)
    assert_equal(AVCodecID.AV_CODEC_ID_MPEG2TS._value, 0x20000)
    assert_equal(AVCodecID.AV_CODEC_ID_MPEG4SYSTEMS._value, 0x20001)
    assert_equal(AVCodecID.AV_CODEC_ID_FFMETADATA._value, 0x21000)
    assert_equal(AVCodecID.AV_CODEC_ID_WRAPPED_AVFRAME._value, 0x21001)
    assert_equal(AVCodecID.AV_CODEC_ID_VNULL._value, 0x21001 + 1)
    assert_equal(AVCodecID.AV_CODEC_ID_ANULL._value, 0x21001 + 2)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()
