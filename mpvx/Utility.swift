//
//  Utility.swift
//  mpvx
//
//  Created by lhc on 8/7/16.
//  Copyright © 2016年 lhc. All rights reserved.
//

import Cocoa

class Utility {
  
  // MARK: - Logs, alerts
  
  static func showAlert(message: String, alertStyle: NSAlertStyle = .critical) {
    let alert = NSAlert()
    alert.messageText = message
    alert.alertStyle = alertStyle
    alert.runModal()
  }
  
  static func log(_ message: String) {
    NSLog("%@", message)
  }
  
  static func assert(_ expr: Bool, _ errorMessage: String, _ block: () -> Void = {}) {
    if !expr {
      NSLog("%@", errorMessage)
      block()
      exit(1)
    }
  }
  
  static func fatal(_ message: String, _ block: () -> Void = {}) {
    NSLog("%@", message)
    print(Thread.callStackSymbols)
    block()
    exit(1)
  }
  
  // MARK: - Panels, Alerts
  
  static func quickOpenPanel(title: String, ok: (URL) -> Void) {
    let panel = NSOpenPanel()
    panel.title = title
    panel.canCreateDirectories = false
    panel.canChooseFiles = true
    panel.canChooseDirectories = false
    panel.resolvesAliases = true
    panel.allowsMultipleSelection = false
    if panel.runModal() == NSFileHandlingPanelOKButton {
      if let url = panel.url {
        ok(url)
      }
    }
  }
  
  static func quickPromptPanel(messageText: String, informativeText: String, ok: (String) -> Void) {
    let panel = NSAlert()
    panel.messageText = messageText
    panel.informativeText = informativeText
    let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 240, height: 24))
    input.bezelStyle = .roundedBezel
    panel.accessoryView = input
    panel.addButton(withTitle: "Jump")
    panel.addButton(withTitle: "Cancel")
    let response = panel.runModal()
    if response == NSAlertFirstButtonReturn {
      ok(input.stringValue)
    }
  }
  
  // MARK: - Util functions
  
  static func swap<T>(_ a: inout T, _ b: inout T) {
    let temp = a
    a = b
    b = temp
  }
    
  // MARK: - Util classes
  
  class Regex {
    var regex: RegularExpression?
    
    init (_ pattern: String) {
      if let exp = try? RegularExpression(pattern: pattern, options: []) {
        self.regex = exp
      } else {
        Utility.fatal("Cannot create regex \(pattern)")
      }
    }
    
    func matches(_ str: String) -> Bool {
      return regex?.numberOfMatches(in: str, options: [], range: NSMakeRange(0, str.characters.count)) > 0
    }
  }

}

