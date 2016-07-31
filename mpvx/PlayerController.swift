//
//  PlayerController.swift
//  mpvx
//
//  Created by lhc on 8/7/16.
//  Copyright © 2016年 lhc. All rights reserved.
//

import Cocoa

class PlayerController: NSObject {
  
  let ud: UserDefaults = UserDefaults.standard
  
  lazy var mainWindow: MainWindow = {
    let window = MainWindow()
    window.playerController = self
    return window
  }()
  
  lazy var mpvController: MPVController = {
    let controller = MPVController(playerController: self)
    return controller
  }()
  
  lazy var preferenceWindow: PreferenceWindow = {
    let window = PreferenceWindow()
    return window
  }()
  
  lazy var info: PlaybackInfo = PlaybackInfo()
  
  var syncPlayTimeTimer: Timer?
  
  var statusPaused: Bool = false
  
  // Open a file
  func openFile(_ url: URL!) {
    let path = url.path
    guard path != nil else {
      Utility.log("Error: empty file path or url")
      return
    }
    Utility.log("Open File \(path!)")
    info.currentURL = url
    mainWindow.showWindow(nil)
    // Send load file command
    mpvController.mpvCommand([MPVCommand.loadfile, path, nil])
  }
  
  func startMPV() {
    mpvController.mpvInit()
  }
  
  func startMPVOpenGLCB(_ videoView: VideoView) {
    let mpvGLContext = mpvController.mpvInitCB()
    videoView.mpvGLContext = OpaquePointer(mpvGLContext)
  }
  
  // Terminate mpv
  func terminateMPV() {
    syncPlayTimeTimer?.invalidate()
    mpvController.mpvQuit()
    mainWindow.videoView.clearGLContext()
  }
  
  // MARK: - mpv commands
  
  /** Pause / resume. Reset speed to 0 when pause. */
  func togglePause(_ set: Bool?) {
    if let setPause = set {
      mpvController.mpvSetFlagProperty(MPVProperty.pause, setPause)
      if setPause {
        setSpeed(0)
      }
    } else {
      if (info.isPaused) {
        mpvController.mpvSetFlagProperty(MPVProperty.pause, false)
      } else {
        mpvController.mpvSetFlagProperty(MPVProperty.pause, true)
        setSpeed(0)
      }
    }
  }
  
  func toogleMute(_ set: Bool?) {
    if let setMute = set {
      mpvController.mpvSetFlagProperty(MPVProperty.mute, setMute)
    } else {
      if (mpvController.mpvGetFlagProperty(MPVProperty.mute)) {
        mpvController.mpvSetFlagProperty(MPVProperty.mute, false)
      } else {
        mpvController.mpvSetFlagProperty(MPVProperty.mute, true)
      }
    }
  }
  
  func seek(percent: Double) {
    let seekMode = ud.bool(forKey: Preference.Key.useExactSeek) ? "absolute-percent+exact" : "absolute-percent"
    mpvController.mpvCommand([MPVCommand.seek, "\(percent)", seekMode, nil])
  }

  func seek(relativeSecond: Double) {
    let seekMode = ud.bool(forKey: Preference.Key.useExactSeek) ? "relative+exact" : "relative"
    mpvController.mpvCommand([MPVCommand.seek, "\(relativeSecond)", seekMode, nil])
  }
  
  func setVolume(_ volume: Int) {
    info.volume = volume
    mpvController.mpvSetIntProperty(MPVProperty.volume, volume)
  }
  
  func setTrack(_ index: Int, forType: MPVTrack.TrackType) {
    let name: String
    switch forType {
    case .audio:
      name = MPVProperty.aid
    case .video:
      name = MPVProperty.vid
    case .sub:
      name = MPVProperty.sid
    case .secondSub:
      name = MPVProperty.secondarySid
    }
    mpvController.mpvSetIntProperty(name, index)
    getSelectedTracks()
  }

  /** Set speed. A negative speed -x means slow by x times */
  func setSpeed(_ speed: Double) {
    var realSpeed = speed
    if realSpeed == 0 {
      realSpeed = 1
    } else if realSpeed < 0 {
      realSpeed = -1 / realSpeed
    }
    mpvController.mpvSetDoubleProperty(MPVProperty.speed, realSpeed)
  }
  
  func fileLoaded() {
    DispatchQueue.main.sync {
      self.getTrackInfo()
      self.getSelectedTracks()
      syncPlayTimeTimer = Timer.scheduledTimer(timeInterval: TimeInterval(AppData.getTimeInterval),
                                               target: self, selector: #selector(self.syncUITime), userInfo: nil, repeats: true)
      mainWindow.adjustFrameByVideoSize()
    }
    mpvController.mpvResume()
  }
  
  /** Sync with UI in MainWindow */
  
  enum SyncUIOption {
    case Time
    case PlayButton
    case MuteButton
  }
  
  func syncUITime() {
    syncUI(.Time)
  }
  
  func syncUI(_ option: SyncUIOption) {
    switch option {
    case .Time:
      let time = mpvController.mpvGetIntProperty(MPVProperty.timePos)
      info.videoPosition!.second = time
      DispatchQueue.main.async {
        self.mainWindow.updatePlayTime(withDuration: false, andProgressBar: true)
      }
    case .PlayButton:
      let pause = mpvController.mpvGetFlagProperty(MPVProperty.pause)
      info.isPaused = pause
      DispatchQueue.main.async {
        self.mainWindow.updatePlayButtonState(pause ? NSOffState : NSOnState)
      }
    case .MuteButton:
      let mute = mpvController.mpvGetFlagProperty(MPVProperty.mute)
      DispatchQueue.main.async {
        self.mainWindow.muteButton.state = mute ? NSOnState : NSOffState
      }
    }
  }
  
  /** Get info */
  
  private func getTrackInfo() {
    info.audioTracks.removeAll(keepingCapacity: true)
    info.videoTracks.removeAll(keepingCapacity: true)
    info.subTracks.removeAll(keepingCapacity: true)
    let trackCount = mpvController.mpvGetIntProperty(MPVProperty.trackListCount)
    for index in 0...trackCount-1 {
      // get info for each track
      let track = MPVTrack(id:         mpvController.mpvGetIntProperty(MPVProperty.trackListNId(index)),
                           type: MPVTrack.TrackType(rawValue:
                                       mpvController.mpvGetStringProperty(MPVProperty.trackListNType(index))!
                           )!,
                           isDefault:  mpvController.mpvGetFlagProperty(MPVProperty.trackListNDefault(index)),
                           isForced:   mpvController.mpvGetFlagProperty(MPVProperty.trackListNForced(index)),
                           isSelected: mpvController.mpvGetFlagProperty(MPVProperty.trackListNSelected(index)),
                           isExternal: mpvController.mpvGetFlagProperty(MPVProperty.trackListNExternal(index)))
      track.srcId = mpvController.mpvGetIntProperty(MPVProperty.trackListNSrcId(index))
      track.title = mpvController.mpvGetStringProperty(MPVProperty.trackListNTitle(index))
      track.lang = mpvController.mpvGetStringProperty(MPVProperty.trackListNLang(index))
      track.codec = mpvController.mpvGetStringProperty(MPVProperty.trackListNCodec(index))
      track.externalFilename = mpvController.mpvGetStringProperty(MPVProperty.trackListNExternalFilename(index))
      // add to lists
      switch track.type {
      case .audio:
        info.audioTracks.append(track)
      case .video:
        info.videoTracks.append(track)
      case .sub:
        info.subTracks.append(track)
      default:
        break
      }
    }
  }
  
  private func getSelectedTracks() {
    info.aid = mpvController.mpvGetIntProperty(MPVProperty.aid)
    info.vid = mpvController.mpvGetIntProperty(MPVProperty.vid)
    info.sid = mpvController.mpvGetIntProperty(MPVProperty.sid)
    info.secondSid = mpvController.mpvGetIntProperty(MPVProperty.secondarySid)
  }

}
