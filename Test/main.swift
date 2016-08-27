//
//  main.swift
//  Test
//
//  Created by Adam Tomecek on 11/05/16.
//  Copyright © 2016 Adam Tomecek. All rights reserved.
//

import Foundation
import Darwin.ncurses
import AVFoundation

var player: AVAudioPlayer?
var songs: [Song] = readFolder("/Users/adamtomecek/Music/MP3/Parkway Drive")
var limitedSongs = clearLimitedSongs()

var playingSong: Song
//sleep(5)

setlocale(LC_ALL,"")
initscr()                   // Init window. Must be first
cbreak()
noecho()                    // Don't echo user input
nonl()                      // Disable newline mode
intrflush(stdscr, true)     // Prevent flush
keypad(stdscr, true)        // Enable function and arrow keys
curs_set(0)                 // Set cursor to invisible

start_color()
init_pair(1, Int16(COLOR_GREEN), Int16(COLOR_BLACK))
init_pair(2, Int16(COLOR_BLACK), Int16(COLOR_WHITE))
init_pair(3, Int16(COLOR_GREEN), Int16(COLOR_WHITE))

let songWindowSize: Int32 = 5
let consoleWindowSize: Int32 = 3

var x = getmaxx(stdscr)
var y = getmaxy(stdscr)
var activeSong: Int = 0
var selectedSong: Int = 0
let songWindow = newwin(songWindowSize, x, 0, 0)
let playlistWindow = newwin(y - songWindowSize - consoleWindowSize, x, songWindowSize, 0)
let consoleWindow = newwin(consoleWindowSize, x, y - consoleWindowSize, 0)
var songsCount = limitedSongs.count
var maxLines: Int = Int(y - 2 - 3)
var maxColumns: Int = Int(x - 6)

var readConsole = false
var consoleContent: String = ""

// Wait for user input
// Exit on 'q'
var playlistChanged: Bool = true
var consoleChanged: Bool = true
var songChanged: Bool = true
var refreshWindows: Bool = true
var lastTime = CFAbsoluteTimeGetCurrent()

let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
dispatch_async(dispatch_get_global_queue(priority, 0)) {
  while true {
    var char = getch()
    
    if !readConsole{
      readInput(char)
    }else{
      let ic = UInt32(char)
      let c  = Character(UnicodeScalar(ic))
      
      switch char {
      case 127: // backspace
        delch()
        consoleContent = String(consoleContent.characters.dropLast())
      case 13:  // enter
        if consoleContent == "" {
          limitedSongs = clearLimitedSongs()
        }
        
        selectedSong = 0
        
        readConsole = false
      default:
        consoleContent.append(c)
      }

      if readConsole {
        limitedSongs = searchSongs()
      }
      
      songsCount = limitedSongs.count
      consoleChanged = true
      playlistChanged = true
      songChanged = true
    }
  }
}

while true {
  let newX = getmaxx(stdscr)
  let newY = getmaxy(stdscr)
  var deltaTime = Float(CFAbsoluteTimeGetCurrent() - lastTime)
  usleep(100)
  
  if deltaTime > 0.5 {
    lastTime = CFAbsoluteTimeGetCurrent()
    songChanged = true
  }
  
  // po zmene velikosti okna zmenit i velikost vykreslovaneho okna
  if(newX != x || newY != y) {
    playlistChanged = true
    consoleChanged = true
    songChanged = true
    refreshWindows = true
    x = newX
    y = newY
    maxLines = Int(y - 2 - songWindowSize - consoleWindowSize)
    maxColumns = Int(x - 6)
    wresize(playlistWindow, y - songWindowSize - consoleWindowSize, x)
    wclear(stdscr)
    wclear(playlistWindow)
  }
  
  if songChanged { // draw song window after every song change
    drawSongWindow(songWindowSize, width: x)
    songChanged = false
    refreshWindows = true
  }
  
  if playlistChanged{ // draw playlist after every playlist change
    drawPlaylistWindow(y - songWindowSize - consoleWindowSize, width: x)
    playlistChanged = false
    refreshWindows = true
  }
  
  if consoleChanged{ // draw console after every console change
    drawConsoleWindow(consoleWindowSize, width: x)
    consoleChanged = false
    refreshWindows = true
  }
  
  if refreshWindows {
    refresh()
    refreshWindows = false
  }
}

