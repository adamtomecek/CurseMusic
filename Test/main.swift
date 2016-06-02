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
var songs: [Song] = readFolder("/Users/adamtomecek/Music/MP3/Architects")
var limitedSongs: [Song] = []
limitedSongs = songs

// sleep(5)

initscr()                   // Init window. Must be first
cbreak()
noecho()                    // Don't echo user input
nonl()                      // Disable newline mode
intrflush(stdscr, true)     // Prevent flush
keypad(stdscr, true)        // Enable function and arrow keys
curs_set(1)                 // Set cursor to invisible

start_color()
init_pair(1, Int16(COLOR_GREEN), Int16(COLOR_BLACK))
init_pair(2, Int16(COLOR_BLACK), Int16(COLOR_WHITE))
init_pair(3, Int16(COLOR_GREEN), Int16(COLOR_WHITE))

var x = getmaxx(stdscr)
var y = getmaxy(stdscr)
var activeSong: Int = 0
var selectedSong: Int = 0
let playlistWindow = newwin(y - 3, x, 0, 0)
let searchWindow = newwin(3, x, y - 3, 0)
var songsCount = limitedSongs.count
var maxLines: Int = Int(y - 2 - 3)
var maxColumns: Int = Int(x - 6)

var readConsole = false
var consoleContent: String = ""

// Wait for user input
// Exit on 'q'
var playlistChanged: Bool = true
var consoleChanged: Bool = true
while true {
  let newX = getmaxx(stdscr)
  let newY = getmaxy(stdscr)
  
  // po zmene velikosti okna zmenit i velikost vykreslovaneho okna
  if(newX != x || newY != y) {
    playlistChanged = true
    consoleChanged = true
    x = newX
    y = newY
    maxLines = Int(y - 2 - 3)
    maxColumns = Int(x - 6)
    wresize(playlistWindow, y - 3, x)
    wclear(stdscr)
    wclear(playlistWindow)
  }

  if playlistChanged{ // po jakekoliv zmene znova vykreslit seznam skladeb
    drawPlaylistWindow(y - 3, width: x)
    playlistChanged = false
  }
  
  if consoleChanged{ // po jakekoliv zmene znova vykreslit seznam skladeb
    drawConsoleWindow(3, width: x)
    consoleChanged = false
  }
  
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
        limitedSongs = songs
      }
      
      readConsole = false
      consoleContent = ""
    default:
      consoleContent.append(c)
    }

    if readConsole {
      limitedSongs = searchSongs()
    }
    
    songsCount = limitedSongs.count
    consoleChanged = true
    playlistChanged = true
  }
}


