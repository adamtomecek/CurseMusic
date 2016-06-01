//
//  Utils.swift
//  Test
//
//  Created by Adam Tomecek on 27/05/16.
//  Copyright © 2016 Adam Tomecek. All rights reserved.
//

import Foundation
import AVFoundation

struct Song {
  var name: String
  var path: String
}

func readFolder(path: String) -> [Song]{
  let fm = NSFileManager.defaultManager()
  let enumerator:NSDirectoryEnumerator? = fm.enumeratorAtPath(path)
  
  var songs: [Song] = []
  
  while let item = enumerator?.nextObject() as? String {
    let ext = (item as NSString).pathExtension
    if ext == "mp3" {
      songs.append(Song(name: "test", path: path + "/" + item))
    }
  }
  
  return songs
}

func searchSongs() -> [Song] {
  var searchSongs: [Song] = []
  
  for song in songs {
    if FuzzySearch.search(originalString: song.path, stringToSearch: consoleContent){
      searchSongs.append(song)
    }
  }
  
  return searchSongs
}

func playSound(path: String) {
  let fileData = NSData(contentsOfFile: path)!
  
  do {
    player = try AVAudioPlayer(data: fileData);
    guard let player = player else { return }
    
    player.prepareToPlay()
    player.play()
  } catch let error as NSError {
    print(error.description)
  }
}

func drawBorders(window: COpaquePointer, y: Int32, x: Int32){
  // spodni a horni linka
  mvwhline(window, 0, 1, UInt32("-"), x - 2)
  mvwhline(window, y - 1, 1, UInt32("-"), x - 2)
  
  // leva a prava linka
  mvwvline(window, 1, 1, UInt32("|"), y - 2)
  mvwvline(window, 1, x - 2, UInt32("|"), y - 2)
}

func readInput(char: Int32){
  switch char {
    case Int32(UnicodeScalar("q").value):
        endwin()
        exit(EX_OK)
    case Int32(UnicodeScalar("j").value):
      selectedSong += 1
      playlistChanged = true
    case Int32(UnicodeScalar("k").value):
      selectedSong -= 1
      playlistChanged = true
    case Int32(UnicodeScalar("/").value):
      readConsole = true
    case Int32(UnicodeScalar("r").value): // random
      // activeSong = random(songsCount)
      playlistChanged = true
    case 13: // enter
      activeSong = selectedSong
      playSound(limitedSongs[activeSong].path)
      playlistChanged = true
    default: true
  }
}
