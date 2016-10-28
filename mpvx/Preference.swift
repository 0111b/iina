//
//  Preference.swift
//  mpvx
//
//  Created by lhc on 17/7/16.
//  Copyright © 2016年 lhc. All rights reserved.
//

import Cocoa

struct Preference {
  
  struct Key {
    /** Window position. (float) */
    // static let windowPosition = "windowPosition"
    
    /** Horizontal positon of control bar. (float, 0 - 1) */
    static let controlBarPositionHorizontal = "controlBarPositionHorizontal"
    
    /** Horizontal positon of control bar. In percentage from bottom. (float, 0 - 1) */
    static let controlBarPositionVertical = "controlBarPositionVertical"
    
    /** Whether control bar stick to center when dragging. (bool) */
    static let controlBarStickToCenter = "controlBarStickToCenter"
    
    /** Timeout for auto hiding control bar (float) */
    static let controlBarAutoHideTimeout  = "controlBarAutoHideTimeout"
    
    /** Material for OSC and title bar (Theme(int)) */
    static let themeMaterial = "themeMaterial"
    
    static let osdAutoHideTimeout = "osdAutoHideTimeout"
    
    /** Soft volume (int, 0 - 100)*/
    static let softVolume = "softVolume"
    
    static let arrowButtonAction = "arrowBtnAction"
    
    /** Pause st first (pause) (bool) */
    static let pauseWhenOpen = "pauseWhenOpen"
    
    static let useExactSeek = "useExactSeek"
    
    static let screenshotFolder = "screenShotFolder"
    static let screenshotIncludeSubtitle = "screenShotIncludeSubtitle"
    static let screenshotFormat = "screenShotFormat"
    static let screenshotTemplate = "screenShotTemplate"
    
  }
  
  enum ArrowButtonAction: Int {
    case speed = 0
    case playlist = 1
    case seek = 2
  }
  
  enum Theme: Int {
    case dark = 0
    case ultraDark
    case light
    case mediumLight
  }
  
  static let defaultPreference:[String : Any] = [
    Key.controlBarPositionHorizontal: Float(0.5),
    Key.controlBarPositionVertical: Float(0.1),
    Key.controlBarStickToCenter: true,
    Key.controlBarAutoHideTimeout: 5,
    Key.themeMaterial: Theme.dark.rawValue,
    Key.osdAutoHideTimeout: 1,
    Key.softVolume: 50,
    Key.arrowButtonAction: ArrowButtonAction.speed.rawValue,
    Key.pauseWhenOpen: false,
    Key.useExactSeek: true,
    Key.screenshotFolder: "~/Pictures/ScreenShots",
    Key.screenshotIncludeSubtitle: true,
    Key.screenshotFormat: "png",
    Key.screenshotTemplate: "%F-%n"
  ]

}
