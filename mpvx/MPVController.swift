//
//  MPVController.swift
//  mpvx
//
//  Created by lhc on 8/7/16.
//  Copyright © 2016年 lhc. All rights reserved.
//

import Cocoa

// Global functions

func getGLProcAddress(ctx: UnsafeMutablePointer<Void>?, name: UnsafePointer<Int8>?) -> UnsafeMutablePointer<Void>? {
  let symbolName: CFString = CFStringCreateWithCString(kCFAllocatorDefault, name, kCFStringEncodingASCII);
  let addr = CFBundleGetFunctionPointerForName(CFBundleGetBundleWithIdentifier(CFStringCreateCopy(kCFAllocatorDefault, "com.apple.opengl")), symbolName);
  return addr;
}

func wakeup(_ ctx: UnsafeMutablePointer<Void>?) {
  let mpvController = unsafeBitCast(ctx, to: MPVController.self)
  mpvController.readEvents()
}

protocol MPVEventDelegate {
  func onMPVEvent(_ event: MPVEvent)
}

class MPVController: NSObject {
  // The mpv_handle
  var mpv: OpaquePointer!
  // The mpv client name
  var mpvClientName: UnsafePointer<Int8>!
  lazy var queue: DispatchQueue! = DispatchQueue(label: "mpvx", attributes: .serial)
  var playerController: PlayerController!
  
  init(playerController: PlayerController) {
    self.playerController = playerController
  }
  
  /**
   Init the mpv context
   */
  func mpvInit() {
    // Create a new mpv instance and an associated client API handle to control the mpv instance.
    mpv = mpv_create()
    
    // Get the name of this client handle.
    mpvClientName = mpv_client_name(mpv)
    
    // Set options that can be override by user's config
    let screenshotPath = playerController.ud.string(forKey: Preference.Key.screenshotFolder)!
    let absoluteScreenshotPath = NSString(string: screenshotPath).expandingTildeInPath
    e(mpv_set_option_string(mpv, MPVOption.Screenshot.screenshotDirectory, absoluteScreenshotPath))
    
    let screenshotFormat = playerController.ud.string(forKey: Preference.Key.screenshotFormat)!
    e(mpv_set_option_string(mpv, MPVOption.Screenshot.screenshotFormat, screenshotFormat))
    
    let screenshotTemplate = playerController.ud.string(forKey: Preference.Key.screenshotTemplate)!
    e(mpv_set_option_string(mpv, MPVOption.Screenshot.screenshotTemplate, screenshotTemplate))
    
    // Load user's config file.
    // e(mpv_load_config_file(mpv, ""))
    
    // Set options. Should be called before initialization.
    e(mpv_set_option_string(mpv, MPVOption.Input.inputMediaKeys, "yes"))
    e(mpv_set_option_string(mpv, MPVOption.Video.vo, "opengl-cb"))
    e(mpv_set_option_string(mpv, MPVOption.Video.hwdecPreload, "auto"))
    
    // Load external scripts
    e(mpv_set_option_string(mpv, MPVOption.ProgramBehavior.script, "/Users/admin/Project/mpvx/mpvx/tools/autoload.lua"))
    
    // Receive log messages at warn level.
    e(mpv_request_log_messages(mpv, "warn"))
    
    // Request tick event.
    // e(mpv_request_event(mpv, MPV_EVENT_TICK, 1))
    
    // Set a custom function that should be called when there are new events.
    mpv_set_wakeup_callback(self.mpv, wakeup, UnsafeMutablePointer(unsafeAddress(of: self)))
    
    //
    // mpv_observe_property(mpv, 0, "track-list", MPV_FORMAT_NODE_ARRAY)
    
    // Initialize an uninitialized mpv instance. If the mpv instance is already running, an error is retuned.
    e(mpv_initialize(mpv))
  }
  
  func mpvInitCB() -> UnsafeMutablePointer<Void> {
    // Get opengl-cb context.
    let mpvGL = mpv_get_sub_api(mpv, MPV_SUB_API_OPENGL_CB)!;
    // Ask delegate (actually VideoView) to setup openGL context.
//    self.delegate!.setUpMpvGLContext(mpvGL)
    return mpvGL
  }
  
  // Basically send quit to mpv
  func mpvQuit() {
    mpv_suspend(mpv)
    command([MPVCommand.quit, nil])
  }
  
  func mpvSuspend() {
    mpv_suspend(mpv)
  }
  
  func mpvResume() {
    mpv_resume(mpv)
  }
  
  // MARK: Command & property
  
  // Send arbitrary mpv command.
  func command(_ args: [String?]) {
    var cargs = args.map { $0.flatMap { UnsafePointer<Int8>(strdup($0)) } }
    self.e(mpv_command(self.mpv, &cargs))
    for ptr in cargs { free(UnsafeMutablePointer(ptr)) }
  }
  
  // Set property
  func setFlag(_ name: String, _ flag: Bool) {
    var data: Int = flag ? 1 : 0
    mpv_set_property(mpv, name, MPV_FORMAT_FLAG, &data)
  }
  
  func setInt(_ name: String, _ value: Int) {
    var data = Int64(value)
    mpv_set_property(mpv, name, MPV_FORMAT_INT64, &data)
  }
  
  func setDouble(_ name: String, _ value: Double) {
    var data = value
    mpv_set_property(mpv, name, MPV_FORMAT_DOUBLE, &data)
  }
  
  func setString(_ name: String, _ value: String) {
    mpv_set_property_string(mpv, name, value)
  }
  
  func getInt(_ name: String) -> Int {
    var data = Int64()
    mpv_get_property(mpv, name, MPV_FORMAT_INT64, &data)
    return Int(data)
  }
  
  func getDouble(_ name: String) -> Double {
    var data = Double()
    mpv_get_property(mpv, name, MPV_FORMAT_DOUBLE, &data)
    return data
  }
  
  func getFlag(_ name: String) -> Bool {
    var data = Int64()
    mpv_get_property(mpv, name, MPV_FORMAT_FLAG, &data)
    return data > 0
  }
  
  func getString(_ name: String) -> String? {
    let cstr = mpv_get_property_string(mpv, name)
    let str: String? = cstr == nil ? nil : String(cString: cstr!)
    mpv_free(cstr)
    return str
  }
  
  // MARK: - Events
  
  // Read event and handle it async
  private func readEvents() {
    queue.async {
      while ((self.mpv) != nil) {
        let event = mpv_wait_event(self.mpv, 0)
        // Do not deal with mpv-event-none
        if event?.pointee.event_id == MPV_EVENT_NONE {
          break
        }
        self.handleEvent(event)
      }
    }
  }
  
  // Handle the event
  private func handleEvent(_ event: UnsafePointer<mpv_event>!) {
    let eventId = event.pointee.event_id
    switch eventId {
    case MPV_EVENT_SHUTDOWN:
      mpv_detach_destroy(mpv)
      mpv = nil
      Utility.log("MPV event: shutdown")
      
    case MPV_EVENT_LOG_MESSAGE:
      let msg = UnsafeMutablePointer<mpv_event_log_message>(event.pointee.data)
      let prefix = String(cString: (msg?.pointee.prefix)!)
      let level = String(cString: (msg?.pointee.level)!)
      let text = String(cString: (msg?.pointee.text)!)
      Utility.log("MPV log: [\(prefix)] \(level): \(text)")
      
    case MPV_EVENT_PROPERTY_CHANGE:
      if let property = UnsafePointer<mpv_event_property>(event.pointee.data)?.pointee {
        let propertyName = String(property.name)
        switch propertyName {
        case MPVProperty.videoParams:
          onVideoParamsChange(UnsafePointer<mpv_node_list>(property.data))
        case MPVProperty.mute:
          playerController.syncUI(.MuteButton)
        default:
          Utility.log("MPV property changed (unhandled): \(propertyName)")
        }
      }
      
    case MPV_EVENT_AUDIO_RECONFIG:
      break
      
    case MPV_EVENT_VIDEO_RECONFIG:
      onVideoReconfig()
      break
      
    case MPV_EVENT_METADATA_UPDATE:
      break
      
    case MPV_EVENT_START_FILE:
      break
      
    case MPV_EVENT_FILE_LOADED:
      onFileLoaded()
      
    case MPV_EVENT_TRACKS_CHANGED:
      onTrackChanged()
      
    case MPV_EVENT_SEEK:
      playerController.syncUI(.Time)
      
    case MPV_EVENT_PLAYBACK_RESTART:
      playerController.syncUI(.Time)
      
    case MPV_EVENT_PAUSE, MPV_EVENT_UNPAUSE:
      playerController.syncUI(.PlayButton)
      
    case MPV_EVENT_CHAPTER_CHANGE:
      playerController.syncUI(.Time)
      playerController.syncUI(.chapterList)
      
    default:
      let eventName = String(cString: mpv_event_name(eventId))
      Utility.log("MPV event (unhandled): \(eventName)")
    }
  }
  
  private func onVideoParamsChange (_ data: UnsafePointer<mpv_node_list>) {
    //let params = data.pointee
    //params.keys.
  }
  
  private func onFileLoaded() {
    mpvSuspend()
    // Get video size and set the initial window size
    let width = getInt(MPVProperty.width)
    let height = getInt(MPVProperty.height)
    let dwidth = getInt(MPVProperty.dwidth)
    let dheight = getInt(MPVProperty.dheight)
    let duration = getInt(MPVProperty.duration)
    let pos = getInt(MPVProperty.timePos)
    playerController.info.videoHeight = height
    playerController.info.videoWidth = width
    playerController.info.displayWidth = dwidth
    playerController.info.displayHeight = dheight
    playerController.info.videoDuration = VideoTime(duration)
    playerController.info.videoPosition = VideoTime(pos)
    let filename = getString(MPVProperty.filename)
    playerController.info.currentURL = URL(fileURLWithPath: filename ?? "")
    playerController.fileLoaded()
    mpvResume()
  }
  
  private func onTrackChanged() {
    
  }
  
  private func onVideoReconfig() {
    // If loading file, video reconfig can return 0 width and height
    if playerController.info.fileLoading {
      return
    }
    var dwidth = getInt(MPVProperty.dwidth)
    var dheight = getInt(MPVProperty.dheight)
    if playerController.info.rotation == 90 || playerController.info.rotation == 270 {
      Utility.swap(&dwidth, &dheight)
    }
    // according to client api doc, check whether changed
    if playerController.info.displayWidth! == 0 && playerController.info.displayHeight! == 0 {
      playerController.info.displayWidth = dwidth
      playerController.info.displayHeight = dheight
      return
    }
    if dwidth != playerController.info.displayWidth! || dheight != playerController.info.displayHeight! {
      // video size changed
      playerController.info.displayWidth = dwidth
      playerController.info.displayHeight = dheight
      mpvSuspend()
      playerController.notifyMainWindowVideoSizeChanged()
      mpvResume()
    }
  }
  
  
  // MARK: Utils
  
  /**
   Utility function for checking mpv api error
   */
  private func e(_ status: Int32!) {
    if status < 0 {
      Utility.showAlert(message: "Cannot start MPV!")
      Utility.fatal("MPV API error: \(String(cString: mpv_error_string(status)))")
    }
  }
  
  
  
}
