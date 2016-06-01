//
//  PlaylistWindow.swift
//  Test
//
//  Created by Adam Tomecek on 27/05/16.
//  Copyright © 2016 Adam Tomecek. All rights reserved.
//

import Foundation

func drawPlaylistLine(song: Song, i: Int){
  let pathSize: Int = song.path.characters.count
  wclrtoeol(playlistWindow)
  if (activeSong == selectedSong) && (activeSong == i) {
    wattrset(playlistWindow, COLOR_PAIR(3))
  } else if i == activeSong {
    wattrset(playlistWindow, COLOR_PAIR(1))
  } else if i == selectedSong {
    wattrset(playlistWindow, COLOR_PAIR(2))
  }
 
  // orezat nazev nebo doplnit mezerami na celou sirku okna
  var line = song.path
  var diff = maxColumns - pathSize - 1
  if diff <= 0 {
    diff *= -1
    let index1 = line.startIndex.advancedBy(diff)
    line = line.substringFromIndex(index1)
  } else {
    for _ in 0...diff{
      line += " "
    }
  }
  
  waddstr(playlistWindow, line)
  
  if i == activeSong || i == selectedSong {
    wattrset(playlistWindow, COLOR_PAIR(0))
  }
}

func drawPlaylistWindow(height: Int32, width: Int32){
  wclear(playlistWindow)
  var lines: Int32 = 0
  
  if selectedSong < 0 { selectedSong = 0 }
  if selectedSong == songsCount { selectedSong = songsCount - 1 }
  
  let maxPlaylistLines: Int = height - 3
  
  var minIndex = selectedSong - (maxLines / 2)
  var maxIndex = selectedSong + (maxLines / 2)
  
  if minIndex < 0 {
    maxIndex = maxLines
  }
  
  if maxIndex >= (songsCount){
    maxIndex = songsCount - 1
    minIndex = songsCount - 1 - maxPlaylistLines
  }
  
  if minIndex < 0 {
    minIndex = 0
  }
  
  for i in minIndex...maxIndex {
    wmove(playlistWindow, lines + 1, 3)
    
    drawPlaylistLine(limitedSongs[i], i: i)
    
    lines += 1
    if lines >= (y - 2) {
      break
    }
  }
  refresh()
  drawBorders(playlistWindow, y: height, x: width)
  wrefresh(playlistWindow)
}