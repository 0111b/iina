//
//  MainWindow.swift
//  mpvx
//
//  Created by lhc on 8/7/16.
//  Copyright © 2016年 lhc. All rights reserved.
//

import Cocoa

class MainWindow: NSWindowController, NSWindowDelegate, MPVControllerDelegate {
  
  var selfWindow: NSWindow!
  var playerController: PlayerController!
  lazy var videoView: VideoView! = self.initVideoView()
  
  var mousePosRelatedToWindow: CGPoint?
  
  @IBOutlet weak var btn: NSButton!
  
  override var windowNibName: String {
    return "MainWindow"
  }

  override func windowDidLoad() {
    super.windowDidLoad()
    selfWindow = self.window!
    selfWindow.titlebarAppearsTransparent = true
    selfWindow.title = AppData.currentURL!.lastPathComponent!
    selfWindow.minSize = NSMakeSize(200, 200)
    selfWindow.contentView?.addSubview(videoView)
    selfWindow.makeMain()
    selfWindow.makeKeyAndOrderFront(nil)
  }
  
  // MARK: Lazy initializers
  
  func initVideoView() -> VideoView {
    let v = VideoView(frame: selfWindow.contentView!.bounds)
    return v
  }
  
  // MARK: - NSWindowDelegate
  
  func windowDidEndLiveResize(_ notification: Notification) {
    window!.setFrame(window!.constrainFrameRect(window!.frame, to: window!.screen), display: false)
  }
  
  override func keyDown(_ event: NSEvent) {
    playerController.togglePause(nil)
  }
  
  override func mouseDown(_ event: NSEvent) {
    mousePosRelatedToWindow = NSEvent.mouseLocation()
    mousePosRelatedToWindow!.x -= window!.frame.origin.x
    mousePosRelatedToWindow!.y -= window!.frame.origin.y
  }
  
  override func mouseDragged(_ event: NSEvent) {
    if mousePosRelatedToWindow != nil {
      let currentLocation = NSEvent.mouseLocation()
      let newOrigin = CGPoint(
        x: currentLocation.x - mousePosRelatedToWindow!.x,
        y: currentLocation.y - mousePosRelatedToWindow!.y
      )
      window?.setFrameOrigin(newOrigin)
    }
  }
  
  // MARK: - MPVControllerDelegate
  
  func setUpMpvGLContext(_ context: UnsafePointer<Void>) {
    videoView.mpvGLContext = OpaquePointer(context)
  }
  
  /**
   Set video size when info available.
   */
  func fileLoadedWithVideoSize(_ width: Int, _ height: Int) {
    let videoSize = NSSize(width: width, height: height)
    self.window!.setContentSize(videoSize)
    self.window!.aspectRatio = videoSize
    if videoView.videoSize == nil {
      videoView.videoSize = videoSize
    }
    self.showWindow(nil)
  }
  
}
