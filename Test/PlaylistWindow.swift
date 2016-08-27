//
//  PlaylistWindow.swift
//  Test
//
//  Created by Adam Tomecek on 27/05/16.
//  Copyright © 2016 Adam Tomecek. All rights reserved.
//

import Foundation

func drawPlaylistLine(song: Song, i: Int){
  // song name consists of title, album and artist
  let songTitle = song.fullName
  // formatted duration
  let songDuration = timeToString(song.duration) // song duration
  let durationSize: Int = songDuration.characters.count
  
  wclrtoeol(playlistWindow)
  if (activeSong == selectedSong) && (activeSong == i) {
    wattrset(playlistWindow, COLOR_PAIR(3))
  } else if i == activeSong {
    wattrset(playlistWindow, COLOR_PAIR(1))
  } else if i == selectedSong {
    wattrset(playlistWindow, COLOR_PAIR(2))
  }
 
  /* normalize names to fit the actual size of line */
  var line = trimTextToFitLine(songTitle, maxLength: maxColumns - durationSize)
  line += songDuration
  
  waddstr(playlistWindow, line)
  
  if i == activeSong || i == selectedSong {
    wattrset(playlistWindow, COLOR_PAIR(0))
  }
}

func drawPlaylistWindow(height: Int32, width: Int32){
  wclear(playlistWindow)
 
  /* crash ahead while trying to draw empty playlist */
  if limitedSongs.count <= 0 {
    drawBorders(playlistWindow, y: height, x: width)
    wrefresh(playlistWindow)
    return
  }
  
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
  
    let song = songs[limitedSongs[i]]

    drawPlaylistLine(song, i: i)
    
    lines += 1
    if lines >= (y - songWindowSize - consoleWindowSize - 1) {
      break
    }
  }
  drawBorders(playlistWindow, y: height, x: width)
  wrefresh(playlistWindow)
}