//
//  PlaylistView.swift
//  mpvx
//
//  Created by lhc on 17/8/16.
//  Copyright © 2016年 lhc. All rights reserved.
//

import Cocoa

class PlaylistView: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
  
  weak var playerController: PlayerController!
  
  @IBOutlet weak var playlistTableView: NSTableView!
  

  override func viewDidLoad() {
    super.viewDidLoad()
    withAllTableViews { (view) in
      view.delegate = self
      view.dataSource = self
    }
  }
  
  // MARK: - NSTableViewDelegate
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    if tableView == playlistTableView {
      return playerController.info.playlist.count
    } else {
      return 0
    }
  }
  
  func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
    let item: MPVPlaylistItem?
    let columnName = tableColumn?.identifier
    if tableView == playlistTableView {
      item = playerController.info.playlist[row]
    } else {
      return nil
    }
    if columnName == Constants.Table.Identifier.isChosen {
      return item!.isPlaying ? Constants.Table.String.dot : ""
    } else if columnName == Constants.Table.Identifier.trackName {
      return item?.title ?? NSString(string: item!.filename).lastPathComponent
    } else {
      return nil
    }
  }
  
  func tableViewSelectionDidChange(_ notification: Notification) {
    
  }
  
  private func withAllTableViews(_ block: (NSTableView) -> Void) {
    block(playlistTableView)
  }
    
}
