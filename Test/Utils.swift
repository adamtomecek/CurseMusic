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

func clearLimitedSongs() -> [Int] {
  var searchSongs: [Int] = []
  for (index, _) in songs.enumerate() {
    searchSongs.append(index)
  }
  return searchSongs
}

func searchSongs() -> [Int] {
  var searchSongs: [Int] = []
 
  /* seach string is empty, return all songs */
  if consoleContent == "" {
    return clearLimitedSongs()
  }
  
  for (index, song) in songs.enumerate() {
    if FuzzySearch.search(originalString: song.fullName, stringToSearch: consoleContent){
      searchSongs.append(index)
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

func playSong() {
  playingSong = songs[activeSong]
  playSound(songs[activeSong].path)
}

func playNextSong(){
  if limitedSongs.count == 0 { return }
  
  if limitedSongs.count == 0 {
    activeSong = -1
    player?.stop()
    player = nil
    return
  }

  if randomPlay {
    activeSong = Int(arc4random_uniform(UInt32(limitedSongs.count))) - 1
  } else {
    activeSong += 1
  }
  
  if limitedSongs.count <= activeSong {
    if repeatPlay {
      activeSong = 0
      playSong()
      return
    } else {
      player?.stop()
      player = nil
      activeSong = -1
      return
    }
  }
  
  playSong()
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
    case Int32(UnicodeScalar("s").value):
      randomPlay = !randomPlay
      songChanged = true
    case Int32(UnicodeScalar("r").value):
      repeatPlay = !repeatPlay
      songChanged = true
    case Int32(UnicodeScalar("p").value):
      if player == nil{
        playNextSong()
        return
      }
      
      if player?.playing == true {
        player?.pause()
      }else {
        player?.play()
      }
    case Int32(UnicodeScalar("n").value):
      playNextSong()
      playlistChanged = true
      songChanged = true
    case Int32(UnicodeScalar("/").value):
      consoleContent = ""
      consoleChanged = true
      readConsole = true
    case Int32(12): // ^l -> clear search
      consoleContent = ""
      limitedSongs = clearLimitedSongs()
      songsCount = songs.count
      playlistChanged = true
      consoleChanged = true
    case 13: // enter
      if limitedSongs.count > 0 {
        activeSong = limitedSongs[selectedSong]
        playSong()
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

