//
//  MainWindowController.swift
//  mpvx
//
//  Created by lhc on 8/7/16.
//  Copyright © 2016年 lhc. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController, NSWindowDelegate {
  
  let ud: UserDefaults = UserDefaults.standard
  let minSize = NSMakeSize(500, 300)
  
  lazy var playerCore = PlayerCore.shared
  lazy var videoView: VideoView = self.initVideoView()
  
  var mousePosRelatedToWindow: CGPoint?
  var isDragging: Bool = false
  
  var isInFullScreen: Bool = false
  
  override var windowNibName: String {
    return "MainWindowController"
  }
  
  var fadeableViews: [NSView?] = []
  
  /** Animation state of he hide/show part */
  enum UIAnimationState {
    case shown, hidden, willShow, willHide
  }
  
  var animationState: UIAnimationState = .shown
  
  var osdAnimationState: UIAnimationState = .hidden
  
  /** For auto hiding ui after a timeout */
  var hideControlTimer: Timer?
  
  var hideOSDTimer: Timer?
  
  /** The index of current speed in speed value array */
  var speedValueIndex: Int = 5
  
  enum ScrollDirection {
    case horizontal
    case vertical
  }
  
  var scrollDirection: ScrollDirection?
  
  /** The view embedded in sidebar */
  enum SideBarViewType {
    case hidden  // indicating sidebar is hidden. Should only be used by sideBarStatus
    case settings
    case playlist
    func width() -> CGFloat {
      switch self {
      case .settings:
        return 360
      case .playlist:
        return 240
      default:
        Utility.fatal("SideBarViewType.width shouldn't be called here")
        return 0
      }
    }
  }
  
  var sideBarStatus: SideBarViewType = .hidden
  
  @IBOutlet weak var sideBarRightConstraint: NSLayoutConstraint!
  @IBOutlet weak var sideBarWidthConstraint: NSLayoutConstraint!
  
  /** The quick setting window */
  lazy var quickSettingView: QuickSettingViewController = {
    let quickSettingView = QuickSettingViewController()
    quickSettingView.mainWindow = self
    return quickSettingView
  }()
  
  lazy var playlistView: PlaylistViewController = {
    let playListView = PlaylistViewController()
    playListView.mainWindow = self
    return playListView
  }()
  
  @IBOutlet weak var titleBarView: NSVisualEffectView!
  @IBOutlet weak var titleTextField: NSTextField!
  @IBOutlet weak var controlBar: ControlBarView!
  @IBOutlet weak var playButton: NSButton!
  @IBOutlet weak var playSlider: NSSlider!
  @IBOutlet weak var volumeSlider: NSSlider!
  @IBOutlet weak var muteButton: NSButton!
  @IBOutlet weak var sideBarView: NSVisualEffectView!
  
  @IBOutlet weak var rightLabel: NSTextField!
  @IBOutlet weak var leftLabel: NSTextField!
  @IBOutlet weak var leftArrowLabel: NSTextField!
  @IBOutlet weak var rightArrowLabel: NSTextField!
  @IBOutlet weak var osd: NSTextField!

  override func windowDidLoad() {
    super.windowDidLoad()
    guard let w = self.window else { return }
    w.titleVisibility = .hidden;
    w.styleMask.insert(NSFullSizeContentViewWindowMask);
    w.titlebarAppearsTransparent = true
    // need to deal with control bar, so handle it manually
    // w.isMovableByWindowBackground  = true
    // set background color to black
    w.backgroundColor = NSColor.black
    titleBarView.layerContentsRedrawPolicy = .onSetNeedsDisplay;
    updateTitle()
    if #available(OSX 10.11, *), UserDefaults.standard.bool(forKey: Preference.Key.controlBarDarker) {
      titleBarView.material = .ultraDark
    }
    // size
    w.minSize = minSize
    // fade-able views
    withStandardButtons { button in
      self.fadeableViews.append(button)
    }
    fadeableViews.append(titleBarView)
    fadeableViews.append(controlBar)
    guard let cv = w.contentView else { return }
    cv.addTrackingArea(NSTrackingArea(rect: cv.bounds, options: [.activeAlways, .inVisibleRect, .mouseEnteredAndExited, .mouseMoved], owner: self, userInfo: nil))
    // video view
    cv.addSubview(videoView, positioned: .below, relativeTo: nil)
    playerCore.startMPVOpenGLCB(videoView)
    // init quick setting view now
    let _ = quickSettingView
    // other initialization
    osd.isHidden = true
    leftArrowLabel.isHidden = true
    rightArrowLabel.isHidden = true
    // make main
    w.makeMain()
    w.makeKeyAndOrderFront(nil)
    w.setIsVisible(false)
  }
  
  // MARK: - Lazy initializers
  
  func initVideoView() -> VideoView {
    let v = VideoView(frame: window!.contentView!.bounds)
    return v
  }
  
  // MARK: - Mouse / Trackpad event
  
  override func keyDown(with event: NSEvent) {
    window!.makeFirstResponder(window!.contentView)
    playerCore.togglePause(nil)
  }
  
  /** record mouse pos on mouse down */
  override func mouseDown(with event: NSEvent) {
    if controlBar.isDragging {
      return
    }
    mousePosRelatedToWindow = NSEvent.mouseLocation()
    mousePosRelatedToWindow!.x -= window!.frame.origin.x
    mousePosRelatedToWindow!.y -= window!.frame.origin.y
  }
  
  /** move window while dragging */
  override func mouseDragged(with event: NSEvent) {
    isDragging = true
    if controlBar.isDragging {
      return
    }
    if mousePosRelatedToWindow != nil {
      let currentLocation = NSEvent.mouseLocation()
      let newOrigin = CGPoint(
        x: currentLocation.x - mousePosRelatedToWindow!.x,
        y: currentLocation.y - mousePosRelatedToWindow!.y
      )
      window?.setFrameOrigin(newOrigin)
    }
  }
  
  /** if don't do so, window will jitter when dragging in titlebar */
  override func mouseUp(with event: NSEvent) {
    mousePosRelatedToWindow = nil
    if isDragging {
      // if it's a mouseup after dragging
      isDragging = false
    } else {
      // if it's a mouseup after clicking
      let mouseInSideBar = window!.contentView!.mouse(event.locationInWindow, in: sideBarView.frame)
      if !mouseInSideBar && sideBarStatus != .hidden {
        hideSideBar()
      }
    }
  }
  
  override func mouseEntered(with event: NSEvent) {
    showUI()
  }
  
  override func mouseExited(with event: NSEvent) {
    if controlBar.isDragging {
      return
    }
    hideUI()
  }
  
  override func mouseMoved(with event: NSEvent) {
    showUIAndUpdateTimer()
  }
  
  override func scrollWheel(with event: NSEvent) {
    if event.phase.contains(.began) {
      if event.scrollingDeltaX != 0 {
        scrollDirection = .horizontal
      } else if event.scrollingDeltaY != 0 {
        scrollDirection = .vertical
      }
    } else if event.phase.contains(.ended) {
      scrollDirection = nil
    }
    // handle the value
    let seekFactor = 0.05
    if scrollDirection == .horizontal {
      playerCore.seek(relativeSecond: seekFactor * Double(event.scrollingDeltaX))
    } else if scrollDirection == .vertical {
      let newVolume = playerCore.info.volume - Int(event.scrollingDeltaY)
      playerCore.setVolume(newVolume)
      volumeSlider.integerValue = newVolume
      displayOSD(.volume(playerCore.info.volume))
    }
  }
  
  // MARK: - Window delegate
  
  func windowWillEnterFullScreen(_ notification: Notification) {
    // show titlebar
    window!.titlebarAppearsTransparent = false
    window!.titleVisibility = .visible
    removeTitlebarFromFadeableViews()
    // stop animation and hide titleBarView
    animationState = .hidden
    titleBarView.isHidden = true
    Swift.print("fullscreen")
    isInFullScreen = true
  }
  
  func windowWillExitFullScreen(_ notification: Notification) {
    // hide titlebar
    window!.titlebarAppearsTransparent = true
    window!.titleVisibility = .hidden
    // show titleBarView
    titleBarView.isHidden = false
    animationState = .shown
    addBackTitlebarToFadeableViews()
    Swift.print("exit fullscreen")
    isInFullScreen = false
    // set back frame of videoview
    videoView.frame = window!.contentView!.frame
  }
  
  func windowDidResize(_ notification: Notification) {
    guard let w = window else { return }
    w.setFrame(w.constrainFrameRect(w.frame, to: w.screen), display: false)
    let wSize = w.frame.size, cSize = controlBar.frame.size
    // update videoview size if in full screen, since aspect ratio may changed
    if (isInFullScreen) {
      let aspectRatio = w.aspectRatio.width / w.aspectRatio.height
      let tryHeight = wSize.width / aspectRatio
      Swift.print(wSize, aspectRatio, tryHeight)
      if tryHeight < wSize.height {
        // should have black above and below
        let targetHeight = wSize.width / aspectRatio
        let yOffset = (wSize.height - targetHeight) / 2
        videoView.frame = NSMakeRect(0, yOffset, wSize.width, targetHeight)
      } else if tryHeight > wSize.height{
        // should have black left and right
        let targetWidth = wSize.height * aspectRatio
        let xOffset = (wSize.width - targetWidth) / 2
        videoView.frame = NSMakeRect(xOffset, 0, targetWidth, wSize.height)
      }
    }
    // update control bar position
    let cph = ud.float(forKey: Preference.Key.controlBarPositionHorizontal)
    let cpv = ud.float(forKey: Preference.Key.controlBarPositionVertical)
    controlBar.setFrameOrigin(NSMakePoint(
      wSize.width * CGFloat(cph) - cSize.width * 0.5,
      wSize.height * CGFloat(cpv)
    ))
  }
  
  // MARK: - Control UI
  
  func hideUIAndCurdor() {
    // don't hide UI when dragging control bar
    if controlBar.isDragging {
      return
    }
    hideUI()
    NSCursor.setHiddenUntilMouseMoves(true)
  }
  
  private func hideUI() {
    fadeableViews.forEach { (v) in
      v?.alphaValue = 1
    }
    animationState = .willHide
    NSAnimationContext.runAnimationGroup({ (context) in
      context.duration = 0.5
      fadeableViews.forEach { (v) in
        v?.animator().alphaValue = 0
      }
    }) {
      // if no interrupt then hide animation
      if self.animationState == .willHide {
        self.fadeableViews.forEach { (v) in
          v?.isHidden = true
        }
        self.animationState = .hidden
      }
    }
  }
  
  private func showUI () {
    animationState = .willShow
    fadeableViews.forEach { (v) in
      v?.isHidden = false
      v?.alphaValue = 0
    }
    NSAnimationContext.runAnimationGroup({ (context) in
      context.duration = 0.5
      fadeableViews.forEach { (v) in
        v?.animator().alphaValue = 1
      }
    }) {
      self.animationState = .shown
    }
  }
  
  private func showUIAndUpdateTimer() {
    if animationState == .hidden {
      showUI()
    }
    // if timer exist, destroy first
    if hideControlTimer != nil {
      hideControlTimer!.invalidate()
      hideControlTimer = nil
    }
    // create new timer
    let timeout = ud.float(forKey: Preference.Key.controlBarAutoHideTimeout)
    hideControlTimer = Timer.scheduledTimer(timeInterval: TimeInterval(timeout), target: self, selector: #selector(self.hideUIAndCurdor), userInfo: nil, repeats: false)
  }
  
  func updateTitle() {
    if let w = window, let url = playerCore.info.currentURL?.lastPathComponent {
      w.title = url
      titleTextField.stringValue = url
    }
  }
  
  func displayOSD(_ message: OSDMessage) {
    if hideOSDTimer != nil {
      hideOSDTimer!.invalidate()
      hideOSDTimer = nil
    }
    osdAnimationState = .shown
    osd.stringValue = message.message()
    osd.alphaValue = 1
    osd.isHidden = false
    let timeout = ud.integer(forKey: Preference.Key.osdAutoHideTimeout)
    hideOSDTimer = Timer.scheduledTimer(timeInterval: TimeInterval(timeout), target: self, selector: #selector(self.hideOSD), userInfo: nil, repeats: false)
  }
  
  @objc private func hideOSD() {
    NSAnimationContext.runAnimationGroup({ (context) in
      self.osdAnimationState = .willHide
      context.duration = 0.5
      osd.animator().alphaValue = 0
    }) {
      if self.osdAnimationState == .willHide {
        self.osdAnimationState = .hidden
      }
    }
  }
  
  private func showSideBar(view: NSView, type: SideBarViewType) {
    // adjust sidebar width
    let width = type.width()
    sideBarWidthConstraint.constant = width
    sideBarRightConstraint.constant = -width
    sideBarView.isHidden = false
    // add view and constraints
    sideBarView.addSubview(view)
    let constraintsH = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[v]-0-|", options: [], metrics: nil, views: ["v": view])
    let constraintsV = NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[v]-0-|", options: [], metrics: nil, views: ["v": view])
    NSLayoutConstraint.activate(constraintsH)
    NSLayoutConstraint.activate(constraintsV)
    // show sidebar
    NSAnimationContext.runAnimationGroup({ (context) in
      context.duration = 0.2
      context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
      sideBarRightConstraint.animator().constant = 0
    }) {
      self.sideBarStatus = type
    }
  }
  
  private func hideSideBar(_ after: @escaping () -> Void = {}) {
    let currWidth = sideBarWidthConstraint.constant
    NSAnimationContext.runAnimationGroup({ (context) in
      context.duration = 0.2
      context.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
      sideBarRightConstraint.animator().constant = -currWidth
    }) {
      self.sideBarStatus = .hidden
      self.sideBarView.subviews.removeAll()
      self.sideBarView.isHidden = true
      after()
    }
  }
  
  private func removeTitlebarFromFadeableViews() {
    // remove buttons from fade-able views
    withStandardButtons { button in
      if let index = (self.fadeableViews.index {$0 === button}) {
        self.fadeableViews.remove(at: index)
      }
    }
    // remove titlebar view from fade-able views
    if let index = (self.fadeableViews.index {$0 === titleBarView}) {
      self.fadeableViews.remove(at: index)
    }
  }
  
  private func addBackTitlebarToFadeableViews() {
    // add back buttons to fade-able views
    withStandardButtons { button in
      self.fadeableViews.append(button)
    }
    // add back titlebar view to fade-able views
    self.fadeableViews.append(titleBarView)
  }
  
  // MARK: - Player controller's delegation
  
  /** Set video size when info available. */
  func adjustFrameByVideoSize(_ width: Int, _ height: Int) {
    guard let w = window else { return }
    // set aspect ratio
    let aspectRatio = Float(width) / Float(height)
    let originalVideoSize = NSSize(width: width, height: height)
    w.aspectRatio = originalVideoSize
    
    var videoSize = w.convertFromBacking(
      NSMakeRect(w.frame.origin.x, w.frame.origin.y, CGFloat(width), CGFloat(height))
    ).size
    
    // check screen size
    let screenSizeOptional = NSScreen.main()?.visibleFrame.size
    if let screenSize = screenSizeOptional {
      // check if video size > screen size
      let tryWidth = CGFloat(Float(screenSize.height) * aspectRatio)
      let tryHeight = CGFloat(Float(screenSize.width) / aspectRatio)
      if screenSize.width >= videoSize.width {
        if screenSize.height < videoSize.height {
          videoSize.height = screenSize.height
          videoSize.width = tryWidth
        }
      } else {
        // screenSize.width < videoSize.width
        if screenSize.height < videoSize.height {
          if (screenSize.height >= tryHeight) {
            videoSize.width = screenSize.width
            videoSize.height = tryHeight
          } else {
            videoSize.height = screenSize.height
            videoSize.width = tryWidth
          }
        } else {
          videoSize.width = screenSize.width
          videoSize.height = tryHeight
        }
      }
      // check default window position
    }
    
//    window!.setContentSize(videoSize.satisfyMinSizeWithFixedAspectRatio(minSize))
    let rect = NSRect(origin: w.frame.origin, size: videoSize.satisfyMinSizeWithFixedAspectRatio(minSize))
    w.setFrame(rect, display: true, animate: true)
    videoView.videoSize = originalVideoSize
    if (!window!.isVisible) {
      window!.setIsVisible(true)
    }
    // UI and slider
    updatePlayTime(withDuration: true, andProgressBar: true)
    updateVolume()
    
  }
  
  // MARK: - Sync UI with playback
  
  func updatePlayTime(withDuration: Bool, andProgressBar: Bool) {
    guard let duration = playerCore.info.videoDuration, let pos = playerCore.info.videoPosition else {
      Utility.fatal("video info not available")
      return
    }
    let percantage = (Double(pos.second) / Double(duration.second)) * 100
    leftLabel.stringValue = pos.stringRepresentation
    if withDuration {
      rightLabel.stringValue = duration.stringRepresentation
    }
    if andProgressBar {
      playSlider.doubleValue = percantage
    }
  }
  
  func updateVolume() {
    let volume = ud.integer(forKey: Preference.Key.softVolume)
    playerCore.setVolume(volume)
    volumeSlider.integerValue = volume
  }
  
  func updatePlayButtonState(_ state: Int) {
    playButton.state = state
    if state == NSOffState {
      speedValueIndex = 5
      leftArrowLabel.isHidden = true
      rightArrowLabel.isHidden = true
    }
  }
  
  // MARK: - IBAction
  
  /** Play button: pause & resume */
  @IBAction func playButtonAction(_ sender: NSButton) {
    if sender.state == NSOnState {
      playerCore.togglePause(false)
    }
    if sender.state == NSOffState {
      playerCore.togglePause(true)
      // speed is already reset by playerCore
      speedValueIndex = 5
      leftArrowLabel.isHidden = true
      rightArrowLabel.isHidden = true
    }
  }
  
  /** mute button */
  @IBAction func muteButtonAction(_ sender: NSButton) {
    if sender.state == NSOnState {
      playerCore.toogleMute(true)
      displayOSD(.mute)
    }
    if sender.state == NSOffState {
      playerCore.toogleMute(false)
      displayOSD(.unMute)
    }
  }
  
  /** left btn */
  @IBAction func leftButtonAction(_ sender: NSButton) {
    arrowButtonAction(left: true)
  }
  
  @IBAction func rightButtonAction(_ sender: NSButton) {
    arrowButtonAction(left: false)
  }
  
  /** handle action of both left and right arrow button */
  private func arrowButtonAction(left: Bool) {
    let actionType = Preference.ArrowButtonAction(rawValue: ud.integer(forKey: Preference.Key.arrowButtonAction))
    switch actionType! {
    case .speed:
      if left {
        if speedValueIndex >= 5 {
          speedValueIndex = 4
        } else if speedValueIndex <= 0 {
          speedValueIndex = 0
        } else {
          speedValueIndex -= 1
        }
      } else {
        if speedValueIndex <= 5 {
          speedValueIndex = 6
        } else if speedValueIndex >= 10 {
          speedValueIndex = 10
        } else {
          speedValueIndex += 1
        }
      }
      let speedValue = AppData.availableSpeedValues[speedValueIndex]
      playerCore.setSpeed(speedValue)
      if speedValueIndex == 5 {
        leftArrowLabel.isHidden = true
        rightArrowLabel.isHidden = true
      } else if speedValueIndex < 5 {
        leftArrowLabel.isHidden = false
        rightArrowLabel.isHidden = true
        leftArrowLabel.stringValue = String(format: "%.0fx", speedValue)
      } else if speedValueIndex > 5 {
        leftArrowLabel.isHidden = true
        rightArrowLabel.isHidden = false
        rightArrowLabel.stringValue = String(format: "%.0fx", speedValue)
      }
      displayOSD(.speed(speedValue))
      // if is paused
      if playButton.state == NSOffState {
        updatePlayButtonState(NSOnState)
        playerCore.togglePause(false)
      }
    case .playlist:
      break
    case .seek:
      playerCore.seek(relativeSecond: left ? -10 : 10)
      break
    }
  }
  
  @IBAction func settingsButtonAction(_ sender: AnyObject) {
    let view = quickSettingView.view
    switch sideBarStatus {
    case .hidden:
      showSideBar(view: view, type: .settings)
    case .playlist:
      hideSideBar {
        self.showSideBar(view: view, type: .settings)
      }
    case .settings:
      hideSideBar()
    }
  }
  
  @IBAction func playlistButtonAction(_ sender: AnyObject) {
    let view = playlistView.view
    switch sideBarStatus {
    case .hidden:
      showSideBar(view: view, type: .playlist)
    case .playlist:
      hideSideBar()
    case .settings:
      hideSideBar {
        self.showSideBar(view: view, type: .playlist)
      }
    }
  }
  
  
  /** When slider changes */
  @IBAction func playSliderChanges(_ sender: NSSlider) {
    let percentage = 100 * sender.doubleValue / sender.maxValue
    playerCore.seek(percent: percentage)
  }
  
  
  @IBAction func volumeSliderChanges(_ sender: NSSlider) {
    let value = sender.integerValue
    playerCore.setVolume(value)
    displayOSD(.volume(value))
  }
  
  
  // MARK: - Utilility
  
  private func withStandardButtons(_ block: (NSButton?) -> Void) {
    guard let w = window else { return }
    block(w.standardWindowButton(.closeButton))
    block(w.standardWindowButton(.miniaturizeButton))
    block(w.standardWindowButton(.zoomButton))
  }
  
  // MARK: - Menu Actions
  
  @IBAction func menuTogglePause(_ sender: NSMenuItem) {
    if sender.title == "Play" {
      playerCore.togglePause(false)
      sender.title = "Pause"
    } else {
      playerCore.togglePause(true)
      sender.title = "Play"
    }
  }
  
  @IBAction func menuStop(_ sender: NSMenuItem) {
    // FIXME: handle stop
    playerCore.stop()
    displayOSD(.stop)
  }
  
  @IBAction func menuStep(_ sender: NSMenuItem) {
    if sender.tag == 0 { // -> 5s
      playerCore.seek(relativeSecond: 5)
    } else if sender.tag == 1 { // <- 5s
      playerCore.seek(relativeSecond: -5)
    }
  }
  
  @IBAction func menuStepFrame(_ sender: NSMenuItem) {
    if !playerCore.info.isPaused {
      playerCore.togglePause(true)
    }
    if sender.tag == 0 { // -> 1f
      playerCore.frameStep(backwards: false)
    } else if sender.tag == 1 { // <- 1f
      playerCore.frameStep(backwards: true)
    }
  }
  
  
  @IBAction func menuJumpToBegin(_ sender: NSMenuItem) {
    playerCore.seek(absoluteSecond: 0)
  }
  
  @IBAction func menuJumpTo(_ sender: NSMenuItem) {
    Utility.quickPromptPanel(messageText: "Jump to:", informativeText: "Example: 20:35") { input in
      if let vt = VideoTime(input) {
        self.playerCore.seek(absoluteSecond: Double(vt.second))
      }
    }
  }
  
  @IBAction func menuSnapshot(_ sender: NSMenuItem) {
    playerCore.screenShot()
    displayOSD(.screenShot)
  }
  
  @IBAction func menuABLoop(_ sender: NSMenuItem) {
    playerCore.abLoop()
    displayOSD(.abLoop(playerCore.info.abLoopStatus))
  }
  
  @IBAction func menuPlaylistItem(_ sender: NSMenuItem) {
    let index = sender.tag
    playerCore.playFileInPlaylist(index)
  }
  
  @IBAction func menuShowPlaylistPanel(_ sender: NSMenuItem) {
    playlistView.pleaseSwitchToTab(.playlist)
    playlistButtonAction(sender)
  }
  
  @IBAction func menuShowChaptersPanel(_ sender: NSMenuItem) {
    playlistView.pleaseSwitchToTab(.chapters)
    playlistButtonAction(sender)
  }
  
  @IBAction func menuChapterSwitch(_ sender: NSMenuItem) {
    let index = sender.tag
    playerCore.playChapter(index)
    let chapter = playerCore.info.chapters[index]
    displayOSD(.chapter(chapter.title))
  }
  
  @IBAction func menuShowVideoQuickSettings(_ sender: NSMenuItem) {
    quickSettingView.pleaseSwitchToTab(.video)
    settingsButtonAction(sender)
  }
  
  @IBAction func menuShowAudioQuickSettings(_ sender: NSMenuItem) {
    quickSettingView.pleaseSwitchToTab(.audio)
    settingsButtonAction(sender)
  }
  
  @IBAction func menuShowSubQuickSettings(_ sender: NSMenuItem) {
    quickSettingView.pleaseSwitchToTab(.sub)
    settingsButtonAction(sender)
  }
  
  @IBAction func menuChangeTrack(_ sender: NSMenuItem) {
    if let trackObj = sender.representedObject as? MPVTrack {
      playerCore.setTrack(trackObj.id, forType: trackObj.type)
    }
  }

  @IBAction func menuChangeAspect(_ sender: NSMenuItem) {
    if let aspectStr = sender.representedObject as? String {
      playerCore.setVideoAspect(aspectStr)
      displayOSD(.aspect(aspectStr))
    } else {
      Utility.log("Unknown aspect in menuChangeAspect(): \(sender.representedObject)")
    }
  }
  
  @IBAction func menuChangeWindowSize(_ sender: NSMenuItem) {
    // -1: normal(non-retina), same as 1 when on non-retina screen
    //  0: half
    //  1: normal
    //  2: double
    //  3: fit screen
    let size = sender.tag
    // FIXME: implement
  }
  
  @IBAction func menuToggleFullScreen(_ sender: NSMenuItem) {
    if let window = window {
      window.toggleFullScreen(sender)
      sender.title = isInFullScreen ? Constants.String.exitFullScreen : Constants.String.fullScreen
    }
  }
  
}
