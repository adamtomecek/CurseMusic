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
  var path: String
  var artist: String
  var album: String
  var title: String
  var duration: Float64
  var fullName: String
}

func readFolder(path: String) -> [Song]{
  let fm = NSFileManager.defaultManager()
  let enumerator:NSDirectoryEnumerator? = fm.enumeratorAtPath(path)
  
  var songs: [Song] = []
  
  while let item = enumerator?.nextObject() as? String {
    let ext = (item as NSString).pathExtension
    if ext == "mp3" { // load only MP3 files
      let songPath = path + "/" + item
      
      var artist: String = ""
      var album: String = ""
      var title: String = ""
      
      let fileUrl = NSURL.fileURLWithPath(songPath)
      let asset = AVURLAsset(URL: fileUrl)
      let duration = CMTimeGetSeconds(asset.duration)
     
      // ID3 tags
      for format in asset.availableMetadataFormats {
        for tag in asset.metadataForFormat(format) {
          if (tag.commonKey == "title"){
            title = tag.stringValue!
          } else if (tag.commonKey == "artist"){
            artist = tag.stringValue!
          } else if (tag.commonKey == "albumName"){
            album = tag.stringValue!
          }
        }
      }
      songs.append(
        Song(
          path: songPath,
          artist: artist,
          album: album,
          title: title,
          duration: duration,
          fullName: "\(artist) - \(album) - \(title)"
        )
      )
    }
  }
  
  return songs
}

func searchSongs() -> [Song] {
  var searchSongs: [Song] = []
 
  /* seach string is empty, return all songs */
  if consoleContent == "" {
    return songs
  }
  
  for song in songs {
    if FuzzySearch.search(originalString: song.fullName, stringToSearch: consoleContent){
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

func trimTextToFitLine(line: String, maxLength: Int) -> String{
  var diff = maxLength - line.characters.count - 1
  if diff <= 0 {
    diff *= -1
    let index1 = line.startIndex.advancedBy(diff)
    return line.substringFromIndex(index1)
  }else{
    var out = line
    for _ in 0...diff{
      out += " "
    }
    return out
  }
}

func centerText(line: String, maxLength: Int) -> String{
  var diff = maxLength - line.characters.count - 1
  if diff <= 0 { // line too long, trim instead of centering
    diff *= -1
    let index1 = line.startIndex.advancedBy(diff)
    return line.substringFromIndex(index1)
  }
  
  let start = (maxLength - line.characters.count - 1) / 2
  var out: String = ""
  for _ in 0...start{
    out += " "
  }
  if line.characters.count > 0 { out += line }
  for _ in 0...start{
    out += " "
  }
  return out
}

func centerText(text:String, numlines:Int32, numcols:Int32) {
  let cy:Int32 = numlines/2
  let cx:Int32 = (numcols - Int32(text.characters.count))/2
  move(cy,cx)
  addstr(text)
  refresh()
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
    case Int32(UnicodeScalar("p").value):
      if player?.playing == true {
        player?.pause()
      }else {
        player?.play()
      }
    case Int32(UnicodeScalar("/").value):
      consoleContent = ""
      readConsole = true
    case Int32(12): // ^l -> clear search
      consoleContent = ""
      limitedSongs = songs
      songsCount = songs.count
      playlistChanged = true
      consoleChanged = true
    case Int32(UnicodeScalar("r").value): // random
      // activeSong = random(songsCount)
      playlistChanged = true
    case 13: // enter
      if limitedSongs.count > 0 {
        activeSong = selectedSong
        playingSong = limitedSongs[activeSong]
        playSound(limitedSongs[activeSong].path)
      }
      playlistChanged = true
      songChanged = true
    default: true
  }
}

func timeToString (audioLength: Float64) -> String{
  let minute_ = abs(Int((audioLength/60) % 60))
  let second_ = abs(Int(audioLength % 60))
  
  let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
  let second = second_ > 9 ? "\(second_)" : "0\(second_)"
  return "\(minute):\(second)"
}

