"See https://www.ffmpeg.org/doxygen/8.0/libavcodec_2version__major_8h.html."
# NOTE: For binding to FFmpeg, this is critical to match.
# TODO: Look for a mechanism that validates this
# matches the FFmpeg version we are dynamically linking to.
comptime LIBAVCODEC_VERSION_MAJOR = 62


comptime FF_API_INIT_PACKET = (LIBAVCODEC_VERSION_MAJOR < 63)

comptime FF_API_V408_CODECID = (LIBAVCODEC_VERSION_MAJOR < 63)
comptime FF_API_CODEC_PROPS = (LIBAVCODEC_VERSION_MAJOR < 63)
comptime FF_API_EXR_GAMMA = (LIBAVCODEC_VERSION_MAJOR < 63)

comptime FF_API_NVDEC_OLD_PIX_FMTS = (LIBAVCODEC_VERSION_MAJOR < 63)

# reminder to remove the OMX encoder on next major bump
comptime FF_CODEC_OMX = (LIBAVCODEC_VERSION_MAJOR < 63)
# reminder to remove Sonic Lossy/Lossless encoders on next major bump
comptime FF_CODEC_SONIC_ENC = (LIBAVCODEC_VERSION_MAJOR < 63)
# reminder to remove Sonic decoder on next-next major bump
comptime FF_CODEC_SONIC_DEC = (LIBAVCODEC_VERSION_MAJOR < 63)
