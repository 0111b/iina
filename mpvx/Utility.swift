//
//  Utility.swift
//  mpvx
//
//  Created by lhc on 8/7/16.
//  Copyright © 2016年 lhc. All rights reserved.
//

import Cocoa

class Utility {
  static func showAlert(message: String, alertStyle: NSAlertStyle = .critical) {
    let alert = NSAlert()
    alert.messageText = message
    alert.alertStyle = alertStyle
    alert.runModal()
  }
  
  static func log(_ message: String) {
    NSLog("%@", message)
  }
  
  static func assert(_ expr: Bool, _ errorMessage: String) {
    if !expr {
      NSLog("%@", errorMessage)
    }
  }
  
  static func fatal(_ message: String) {
    NSLog("%@", message)
    NSApp.terminate(self)
  }

}
