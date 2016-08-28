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
 
  var currentTime: Float64 = 0.0
  if player?.currentTime != nil{
    currentTime = Float64(player!.currentTime)
  }
  
  let currentTimeStr: String = timeToString(currentTime)
  let progressSize = maxColumns / 2;
  
  var progressFull: Int = 0
  if activeSong >= 0 {
    progressFull = Int(currentTime / songs[activeSong].duration * Float64(progressSize));
  }
  
  let progressEmpty = progressSize - progressFull
  
  progressBar += currentTimeStr // song progress time
  progressBar += " [" // progress bar start
  if currentTime == 0 {
    progressBar += "░" // fill the rest of progress bar
  } else {
    for _ in 0...progressFull {
      progressBar += "█" // fill song progress
    }
  }
  for _ in 0...(progressEmpty) {
    progressBar += "░" // fill the rest of progress bar
  }
  progressBar += "] " // progress bar end
  var currentSongDuration: Float64 = 0
  if activeSong >= 0 {
    currentSongDuration = songs[activeSong].duration
  }
  progressBar += timeToString(currentSongDuration); // total song time
  
  wmove(songWindow, 1, 3)
  wattrset(songWindow, COLOR_PAIR(1))
  waddstr(songWindow, songTitle)
  wattrset(songWindow, COLOR_PAIR(0))
  wmove(songWindow, 2, 3)
  waddstr(songWindow, songAlbum)
  wmove(songWindow, 3, 3)
  waddstr(songWindow, centerText(progressBar, maxLength: maxColumns))
  
  // 2 for borders, - 2 for first symbol to center
  wmove(songWindow, 4, Int32(2 + maxColumns / 2 - 2))
  if randomPlay {
    wattrset(songWindow, COLOR_PAIR(4))
    waddstr(songWindow, "🔀 ")
    wattrset(songWindow, COLOR_PAIR(0))
  } else {
    waddstr(songWindow, "🔀 ")
  }
  
  if repeatPlay {
    wattrset(songWindow, COLOR_PAIR(4))
    waddstr(songWindow, "🔁 ")
    wattrset(songWindow, COLOR_PAIR(0))
  } else {
    waddstr(songWindow, "🔁 ")
  }
  wrefresh(songWindow)
  refresh()
}