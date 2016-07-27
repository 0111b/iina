import Foundation

struct MPVProperty {
  /** osd-level */
  static let osdLevel = "osd-level"
  /** osd-scale */
  static let osdScale = "osd-scale"
  /** loop */
  static let loop = "loop"
  /** loop-file */
  static let loopFile = "loop-file"
  /** speed */
  static let speed = "speed"
  /** audio-speed-correction */
  static let audioSpeedCorrection = "audio-speed-correction"
  /** video-speed-correction */
  static let videoSpeedCorrection = "video-speed-correction"
  /** display-sync-active */
  static let displaySyncActive = "display-sync-active"
  /** filename */
  static let filename = "filename"
  /** file-size */
  static let fileSize = "file-size"
  /** estimated-frame-count */
  static let estimatedFrameCount = "estimated-frame-count"
  /** estimated-frame-number */
  static let estimatedFrameNumber = "estimated-frame-number"
  /** path */
  static let path = "path"
  /** media-title */
  static let mediaTitle = "media-title"
  /** file-format */
  static let fileFormat = "file-format"
  /** demuxer */
  static let demuxer = "demuxer"
  /** stream-path */
  static let streamPath = "stream-path"
  /** stream-pos */
  static let streamPos = "stream-pos"
  /** stream-end */
  static let streamEnd = "stream-end"
  /** duration */
  static let duration = "duration"
  /** avsync */
  static let avsync = "avsync"
  /** total-avsync-change */
  static let totalAvsyncChange = "total-avsync-change"
  /** drop-frame-count */
  static let dropFrameCount = "drop-frame-count"
  /** vo-drop-frame-count */
  static let voDropFrameCount = "vo-drop-frame-count"
  /** mistimed-frame-count */
  static let mistimedFrameCount = "mistimed-frame-count"
  /** vsync-ratio */
  static let vsyncRatio = "vsync-ratio"
  /** vo-delayed-frame-count */
  static let voDelayedFrameCount = "vo-delayed-frame-count"
  /** percent-pos */
  static let percentPos = "percent-pos"
  /** time-pos */
  static let timePos = "time-pos"
  /** time-start */
  static let timeStart = "time-start"
  /** time-remaining */
  static let timeRemaining = "time-remaining"
  /** playtime-remaining */
  static let playtimeRemaining = "playtime-remaining"
  /** playback-time */
  static let playbackTime = "playback-time"
  /** chapter */
  static let chapter = "chapter"
  /** edition */
  static let edition = "edition"
  /** disc-titles */
  static let discTitles = "disc-titles"
  /** disc-title-list */
  static let discTitleList = "disc-title-list"
  /** disc-title */
  static let discTitle = "disc-title"
  /** chapters */
  static let chapters = "chapters"
  /** editions */
  static let editions = "editions"
  /** edition-list */
  static let editionList = "edition-list"
  /** edition-list/N/id */
  static func editionListNId(_ n: Int) -> String {
    return "edition-list/\(n)/id"
  }
  /** edition-list/N/default */
  static func editionListNDefault(_ n: Int) -> String {
    return "edition-list/\(n)/default"
  }
  /** edition-list/N/title */
  static func editionListNTitle(_ n: Int) -> String {
    return "edition-list/\(n)/title"
  }
  /** ab-loop-a */
  static let abLoopA = "ab-loop-a"
  /** ab-loop-b */
  static let abLoopB = "ab-loop-b"
  /** angle */
  static let angle = "angle"
  /** metadata */
  static let metadata = "metadata"
  /** metadata/list/N/key */
  static func metadataListNKey(_ n: Int) -> String {
    return "metadata/list/\(n)/key"
  }
  /** metadata/list/N/value */
  static func metadataListNValue(_ n: Int) -> String {
    return "metadata/list/\(n)/value"
  }
  /** filtered-metadata */
  static let filteredMetadata = "filtered-metadata"
  /** chapter-metadata */
  static let chapterMetadata = "chapter-metadata"
  /** pause */
  static let pause = "pause"
  /** idle */
  static let idle = "idle"
  /** core-idle */
  static let coreIdle = "core-idle"
  /** cache */
  static let cache = "cache"
  /** cache-size */
  static let cacheSize = "cache-size"
  /** cache-free */
  static let cacheFree = "cache-free"
  /** cache-used */
  static let cacheUsed = "cache-used"
  /** cache-speed */
  static let cacheSpeed = "cache-speed"
  /** cache-idle */
  static let cacheIdle = "cache-idle"
  /** demuxer-cache-duration */
  static let demuxerCacheDuration = "demuxer-cache-duration"
  /** demuxer-cache-time */
  static let demuxerCacheTime = "demuxer-cache-time"
  /** demuxer-cache-idle */
  static let demuxerCacheIdle = "demuxer-cache-idle"
  /** paused-for-cache */
  static let pausedForCache = "paused-for-cache"
  /** cache-buffering-state */
  static let cacheBufferingState = "cache-buffering-state"
  /** eof-reached */
  static let eofReached = "eof-reached"
  /** seeking */
  static let seeking = "seeking"
  /** hr-seek */
  static let hrSeek = "hr-seek"
  /** mixer-active */
  static let mixerActive = "mixer-active"
  /** volume */
  static let volume = "volume"
  /** volume-max */
  static let volumeMax = "volume-max"
  /** mute */
  static let mute = "mute"
  /** ao-volume */
  static let aoVolume = "ao-volume"
  /** ao-mute */
  static let aoMute = "ao-mute"
  /** audio-delay */
  static let audioDelay = "audio-delay"
  /** audio-codec */
  static let audioCodec = "audio-codec"
  /** audio-codec-name */
  static let audioCodecName = "audio-codec-name"
  /** audio-params */
  static let audioParams = "audio-params"
  /** audio-out-params */
  static let audioOutParams = "audio-out-params"
  /** aid */
  static let aid = "aid"
  /** audio */
  static let audio = "audio"
  /** balance */
  static let balance = "balance"
  /** fullscreen */
  static let fullscreen = "fullscreen"
  /** deinterlace */
  static let deinterlace = "deinterlace"
  /** field-dominance */
  static let fieldDominance = "field-dominance"
  /** colormatrix */
  static let colormatrix = "colormatrix"
  /** colormatrix-input-range */
  static let colormatrixInputRange = "colormatrix-input-range"
  /** video-output-levels */
  static let videoOutputLevels = "video-output-levels"
  /** colormatrix-primaries */
  static let colormatrixPrimaries = "colormatrix-primaries"
  /** taskbar-progress */
  static let taskbarProgress = "taskbar-progress"
  /** ontop */
  static let ontop = "ontop"
  /** border */
  static let border = "border"
  /** on-all-workspaces */
  static let onAllWorkspaces = "on-all-workspaces"
  /** framedrop */
  static let framedrop = "framedrop"
  /** gamma */
  static let gamma = "gamma"
  /** brightness */
  static let brightness = "brightness"
  /** contrast */
  static let contrast = "contrast"
  /** saturation */
  static let saturation = "saturation"
  /** hue */
  static let hue = "hue"
  /** hwdec */
  static let hwdec = "hwdec"
  /** hwdec-current */
  static let hwdecCurrent = "hwdec-current"
  /** hwdec-interop */
  static let hwdecInterop = "hwdec-interop"
  /** hwdec-active */
  static let hwdecActive = "hwdec-active"
  /** hwdec-detected */
  static let hwdecDetected = "hwdec-detected"
  /** panscan */
  static let panscan = "panscan"
  /** video-format */
  static let videoFormat = "video-format"
  /** video-codec */
  static let videoCodec = "video-codec"
  /** width */
  static let width = "width"
  /** height */
  static let height = "height"
  /** video-params */
  static let videoParams = "video-params"
  /** dwidth */
  static let dwidth = "dwidth"
  /** dheight */
  static let dheight = "dheight"
  /** video-out-params */
  static let videoOutParams = "video-out-params"
  /** video-frame-info */
  static let videoFrameInfo = "video-frame-info"
  /** fps */
  static let fps = "fps"
  /** estimated-vf-fps */
  static let estimatedVfFps = "estimated-vf-fps"
  /** window-scale */
  static let windowScale = "window-scale"
  /** window-minimized */
  static let windowMinimized = "window-minimized"
  /** display-names */
  static let displayNames = "display-names"
  /** display-fps */
  static let displayFps = "display-fps"
  /** estimated-display-fps */
  static let estimatedDisplayFps = "estimated-display-fps"
  /** vsync-jitter */
  static let vsyncJitter = "vsync-jitter"
  /** video-aspect */
  static let videoAspect = "video-aspect"
  /** osd-width */
  static let osdWidth = "osd-width"
  /** osd-height */
  static let osdHeight = "osd-height"
  /** osd-par */
  static let osdPar = "osd-par"
  /** vid */
  static let vid = "vid"
  /** video */
  static let video = "video"
  /** video-align-x */
  static let videoAlignX = "video-align-x"
  /** video-align-y */
  static let videoAlignY = "video-align-y"
  /** video-pan-x */
  static let videoPanX = "video-pan-x"
  /** video-pan-y */
  static let videoPanY = "video-pan-y"
  /** video-zoom */
  static let videoZoom = "video-zoom"
  /** video-unscaled */
  static let videoUnscaled = "video-unscaled"
  /** program */
  static let program = "program"
  /** dvb-channel */
  static let dvbChannel = "dvb-channel"
  /** dvb-channel-name */
  static let dvbChannelName = "dvb-channel-name"
  /** sid */
  static let sid = "sid"
  /** secondary-sid */
  static let secondarySid = "secondary-sid"
  /** sub */
  static let sub = "sub"
  /** sub-delay */
  static let subDelay = "sub-delay"
  /** sub-pos */
  static let subPos = "sub-pos"
  /** sub-visibility */
  static let subVisibility = "sub-visibility"
  /** sub-forced-only */
  static let subForcedOnly = "sub-forced-only"
  /** sub-scale */
  static let subScale = "sub-scale"
  /** ass-force-margins */
  static let assForceMargins = "ass-force-margins"
  /** sub-use-margins */
  static let subUseMargins = "sub-use-margins"
  /** ass-vsfilter-aspect-compat */
  static let assVsfilterAspectCompat = "ass-vsfilter-aspect-compat"
  /** ass-style-override */
  static let assStyleOverride = "ass-style-override"
  /** stream-capture */
  static let streamCapture = "stream-capture"
  /** tv-brightness */
  static let tvBrightness = "tv-brightness"
  /** tv-contrast */
  static let tvContrast = "tv-contrast"
  /** tv-saturation */
  static let tvSaturation = "tv-saturation"
  /** tv-hue */
  static let tvHue = "tv-hue"
  /** playlist-pos */
  static let playlistPos = "playlist-pos"
  /** playlist-pos-1 */
  static let playlistPos1 = "playlist-pos-1"
  /** playlist-count */
  static let playlistCount = "playlist-count"
  /** playlist */
  static let playlist = "playlist"
  /** playlist/N/filename */
  static func playlistNFilename(_ n: Int) -> String {
    return "playlist/\(n)/filename"
  }
  /** playlist/N/current */
  static func playlistNCurrent(_ n: Int) -> String {
    return "playlist/\(n)/current"
  }
  /** playlist/N/playing */
  static func playlistNPlaying(_ n: Int) -> String {
    return "playlist/\(n)/playing"
  }
  /** playlist/N/title */
  static func playlistNTitle(_ n: Int) -> String {
    return "playlist/\(n)/title"
  }
  /** track-list */
  static let trackList = "track-list"
  /** track-list/N/id */
  static func trackListNId(_ n: Int) -> String {
    return "track-list/\(n)/id"
  }
  /** track-list/N/type */
  static func trackListNType(_ n: Int) -> String {
    return "track-list/\(n)/type"
  }
  /** track-list/N/src-id */
  static func trackListNSrcId(_ n: Int) -> String {
    return "track-list/\(n)/src-id"
  }
  /** track-list/N/title */
  static func trackListNTitle(_ n: Int) -> String {
    return "track-list/\(n)/title"
  }
  /** track-list/N/lang */
  static func trackListNLang(_ n: Int) -> String {
    return "track-list/\(n)/lang"
  }
  /** track-list/N/albumart */
  static func trackListNAlbumart(_ n: Int) -> String {
    return "track-list/\(n)/albumart"
  }
  /** track-list/N/default */
  static func trackListNDefault(_ n: Int) -> String {
    return "track-list/\(n)/default"
  }
  /** track-list/N/forced */
  static func trackListNForced(_ n: Int) -> String {
    return "track-list/\(n)/forced"
  }
  /** track-list/N/codec */
  static func trackListNCodec(_ n: Int) -> String {
    return "track-list/\(n)/codec"
  }
  /** track-list/N/external */
  static func trackListNExternal(_ n: Int) -> String {
    return "track-list/\(n)/external"
  }
  /** track-list/N/external-filename */
  static func trackListNExternalFilename(_ n: Int) -> String {
    return "track-list/\(n)/external-filename"
  }
  /** track-list/N/selected */
  static func trackListNSelected(_ n: Int) -> String {
    return "track-list/\(n)/selected"
  }
  /** track-list/N/ff-index */
  static func trackListNFfIndex(_ n: Int) -> String {
    return "track-list/\(n)/ff-index"
  }
  /** track-list/N/decoder-desc */
  static func trackListNDecoderDesc(_ n: Int) -> String {
    return "track-list/\(n)/decoder-desc"
  }
  /** track-list/N/demux-w */
  static func trackListNDemuxW(_ n: Int) -> String {
    return "track-list/\(n)/demux-w"
  }
  /** track-list/N/demux-h */
  static func trackListNDemuxH(_ n: Int) -> String {
    return "track-list/\(n)/demux-h"
  }
  /** track-list/N/demux-channel-count */
  static func trackListNDemuxChannelCount(_ n: Int) -> String {
    return "track-list/\(n)/demux-channel-count"
  }
  /** track-list/N/demux-channels */
  static func trackListNDemuxChannels(_ n: Int) -> String {
    return "track-list/\(n)/demux-channels"
  }
  /** track-list/N/demux-samplerate */
  static func trackListNDemuxSamplerate(_ n: Int) -> String {
    return "track-list/\(n)/demux-samplerate"
  }
  /** track-list/N/demux-fps */
  static func trackListNDemuxFps(_ n: Int) -> String {
    return "track-list/\(n)/demux-fps"
  }
  /** track-list/N/audio-channels */
  static func trackListNAudioChannels(_ n: Int) -> String {
    return "track-list/\(n)/audio-channels"
  }
  /** chapter-list */
  static let chapterList = "chapter-list"
  /** chapter-list/N/title */
  static func chapterListNTitle(_ n: Int) -> String {
    return "chapter-list/\(n)/title"
  }
  /** chapter-list/N/time */
  static func chapterListNTime(_ n: Int) -> String {
    return "chapter-list/\(n)/time"
  }
  /** af */
  static let af = "af"
  /** vf */
  static let vf = "vf"
  /** video-rotate */
  static let videoRotate = "video-rotate"
  /** video-stereo-mode */
  static let videoStereoMode = "video-stereo-mode"
  /** seekable */
  static let seekable = "seekable"
  /** partially-seekable */
  static let partiallySeekable = "partially-seekable"
  /** playback-abort */
  static let playbackAbort = "playback-abort"
  /** cursor-autohide */
  static let cursorAutohide = "cursor-autohide"
  /** osd-sym-cc */
  static let osdSymCc = "osd-sym-cc"
  /** osd-ass-cc */
  static let osdAssCc = "osd-ass-cc"
  /** vo-configured */
  static let voConfigured = "vo-configured"
  /** vo-performance */
  static let voPerformance = "vo-performance"
  /** upload */
  static let upload = "upload"
  /** render */
  static let render = "render"
  /** present */
  static let present = "present"
  /** last */
  static let last = "last"
  /** avg */
  static let avg = "avg"
  /** peak */
  static let peak = "peak"
  /** video-bitrate */
  static let videoBitrate = "video-bitrate"
  /** audio-bitrate */
  static let audioBitrate = "audio-bitrate"
  /** sub-bitrate */
  static let subBitrate = "sub-bitrate"
  /** packet-video-bitrate */
  static let packetVideoBitrate = "packet-video-bitrate"
  /** packet-audio-bitrate */
  static let packetAudioBitrate = "packet-audio-bitrate"
  /** packet-sub-bitrate */
  static let packetSubBitrate = "packet-sub-bitrate"
  /** audio-device-list */
  static let audioDeviceList = "audio-device-list"
  /** audio-device */
  static let audioDevice = "audio-device"
  /** current-vo */
  static let currentVo = "current-vo"
  /** current-ao */
  static let currentAo = "current-ao"
  /** audio-out-detected-device */
  static let audioOutDetectedDevice = "audio-out-detected-device"
  /** working-directory */
  static let workingDirectory = "working-directory"
  /** protocol-list */
  static let protocolList = "protocol-list"
  /** decoder-list */
  static let decoderList = "decoder-list"
  /** family */
  static let family = "family"
  /** codec */
  static let codec = "codec"
  /** driver */
  static let driver = "driver"
  /** description */
  static let description = "description"
  /** encoder-list */
  static let encoderList = "encoder-list"
  /** mpv-version */
  static let mpvVersion = "mpv-version"
  /** mpv-configuration */
  static let mpvConfiguration = "mpv-configuration"
  /** ffmpeg-version */
  static let ffmpegVersion = "ffmpeg-version"
  /** options/<name> */
  static func options(_ name: String) -> String {
    return "options/\(name)"
  }
  /** file-local-options/<name> */
  static func fileLocalOptions(_ name: String) -> String {
    return "file-local-options/\(name)"
  }
  /** option-info/<name> */
  static func optionInfo(_ name: String) -> String {
    return "option-info/\(name)"
  }
  /** option-info/<name>/name */
  static func optionInfoName(_ name: String) -> String {
    return "option-info/\(name)/name"
  }
  /** option-info/<name>/type */
  static func optionInfoType(_ name: String) -> String {
    return "option-info/\(name)/type"
  }
  /** option-info/<name>/set-from-commandline */
  static func optionInfoSetFromCommandline(_ name: String) -> String {
    return "option-info/\(name)/set-from-commandline"
  }
  /** option-info/<name>/set-locally */
  static func optionInfoSetLocally(_ name: String) -> String {
    return "option-info/\(name)/set-locally"
  }
  /** option-info/<name>/default-value */
  static func optionInfoDefaultValue(_ name: String) -> String {
    return "option-info/\(name)/default-value"
  }
  /** option-info/<name>/min */
  static func optionInfoMin(_ name: String) -> String {
    return "option-info/\(name)/min"
  }
  /** option-info/<name>/max */
  static func optionInfoMax(_ name: String) -> String {
    return "option-info/\(name)/max"
  }
  /** option-info/<name>/choices */
  static func optionInfoChoices(_ name: String) -> String {
    return "option-info/\(name)/choices"
  }
  /** property-list */
  static let propertyList = "property-list"
}
