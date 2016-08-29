//
//  Data.swift
//  mpvx
//
//  Created by lhc on 8/7/16.
//  Copyright © 2016年 lhc. All rights reserved.
//

import Foundation

struct AppData {
  
  /** time interval to sync play pos */
  static let getTimeInterval: Double = 0.5
  
  /** speed values when clicking left / right arrow button */
  static let availableSpeedValues: [Double] = [-32, -16, -8, -4, -2, 0, 2, 4, 8, 16, 32]
}


struct Constants {
  struct Identifier {
    static let isChosen = "IsChosen"
    static let trackName = "TrackName"
    static let isPlayingCell = "IsPlayingCell"
    static let trackNameCell = "TrackNameCell"
  }
  struct String {
    static let dot = "●"
    static let play = "▶︎"
    static let none = "<None>"
    static let chapter = "Chapter"
  }
}
