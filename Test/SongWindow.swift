//
//  SongWindow.swift
//  CurseMusic
//
//  Created by Adam Tomecek on 17/07/16.
//  Copyright © 2016 Adam Tomecek. All rights reserved.
//

import Foundation


func drawSongWindow(height: Int32, width: Int32){
  wclear(songWindow)
  drawBorders(songWindow, y: height, x: width)
  
  let songTitle = centerText(playingSong.title, maxLength: maxColumns)
  var songAlbum = ""
  if playingSong.album.characters.count > 0 || playingSong.artist.characters.count > 0 {
    songAlbum = centerText("\(playingSong.album) - \(playingSong.artist)", maxLength: maxColumns)
  }
  
  var progressBar: String = ""
  
  if player?.currentTime != nil{
    let currentTime: Float64? = Float64(player!.currentTime)
    let currentTimeStr: String? = timeToString(currentTime!)
    let progressSize = maxColumns / 2;
    let progressFull = Int(currentTime! / songs[activeSong].duration * Float64(progressSize));
    let progressEmpty = progressSize - progressFull
    
    progressBar += currentTimeStr! // song progress time
    progressBar += " [" // progress bar start
    for _ in 0...progressFull {
      progressBar += "█" // fill song progress
    }
    for _ in 0...(progressEmpty) {
      progressBar += "░" // fill the rest of progress bar
    }
    progressBar += "] " // progress bar end
    progressBar += timeToString(songs[activeSong].duration); // total song time
  }
  
  wmove(songWindow, 1, 3)
  wattrset(songWindow, COLOR_PAIR(1))
  waddstr(songWindow, songTitle)
  wattrset(songWindow, COLOR_PAIR(0))
  wmove(songWindow, 2, 3)
  waddstr(songWindow, songAlbum)
  wmove(songWindow, 3, 3)
  waddstr(songWindow, centerText(progressBar, maxLength: maxColumns))
  wrefresh(songWindow)
  refresh()
}