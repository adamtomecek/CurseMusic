import Foundation
import AVFoundation
import CNCurses

var player: AVAudioPlayer?


var playingSong: Song

var readConsole: Bool = false
var consoleContent: String = ""

var playlistChanged: Bool = true
var consoleChanged: Bool = true
var songChanged: Bool = true

var refreshWindows: Bool = true
var lastTime = CFAbsoluteTimeGetCurrent()
var repeatPlay: Bool = false
var randomPlay: Bool = false

var activeSong: Int = -1
var selectedSong: Int = 0

var songs: [Song] = []
var limitedSongs: [Int] = []
var songsCount = 0


// user current path is no argument is passed
if CommandLine.argc > 1 {
  readFolder(CommandLine.arguments[1])
} else {
  loadState()
}
limitedSongs = clearLimitedSongs()
songsCount = limitedSongs.count

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
init_pair(4, Int16(COLOR_WHITE), Int16(COLOR_GREEN))

let songWindowSize: Int32 = 6
let consoleWindowSize: Int32 = 3

var x = getmaxx(stdscr)
var y = getmaxy(stdscr)
let songWindow = newwin(songWindowSize, x, 0, 0)
let playlistWindow = newwin(y - songWindowSize - consoleWindowSize, x, songWindowSize, 0)
let consoleWindow = newwin(consoleWindowSize, x, y - consoleWindowSize, 0)
var maxLines: Int = Int(y - 2 - 3)
var maxColumns: Int = Int(x - 6)

DispatchQueue.global(qos: .default).async {
  while true {
    var char = getch()

    if !readConsole{
      readInput(char)
    }else{
      let ic = UInt32(char)
      let c  = Character(UnicodeScalar(ic)!)

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


  if player != nil { // think about better way of handling song switches
    let duration = player!.duration
    let currentTime = player!.currentTime
    if (player!.currentTime + 0.005) > player!.duration {
      playNextSong()
    }
  }

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
    drawSongWindow(height: songWindowSize, width: x)
    songChanged = false
    refreshWindows = true
  }

  if playlistChanged{ // draw playlist after every playlist change
    drawPlaylistWindow(y - songWindowSize - consoleWindowSize, width: x)
    playlistChanged = false
    refreshWindows = true
  }

  if consoleChanged{ // draw console after every console change
    drawConsoleWindow(height: consoleWindowSize, width: x)
    consoleChanged = false
    refreshWindows = true
  }

  if refreshWindows {
    refresh()
    refreshWindows = false
  }
}

