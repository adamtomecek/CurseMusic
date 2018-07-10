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

// load all mp3 files for path
func readFolder(_ path: String) -> [Song]{
  let fm = FileManager.default
  let enumerator:FileManager.DirectoryEnumerator? = fm.enumerator(atPath: path)

  var songs: [Song] = []

  while let item = enumerator?.nextObject() as? String {
    let ext = (item as NSString).pathExtension
    if ext == "mp3" { // load only MP3 files
      let songPath = path + "/" + item

      var artist: String = ""
      var album: String = ""
      var title: String = ""

      let fileUrl = URL(fileURLWithPath: songPath)
      let asset = AVURLAsset(url: fileUrl)
      let duration = CMTimeGetSeconds(asset.duration)

      // ID3 tags
      for format in asset.availableMetadataFormats {
        for tag in asset.metadata(forFormat: format) {

          let commonKey = tag.commonKey

          if (commonKey == AVMetadataKey.commonKeyTitle){
            title = tag.stringValue!
          } else if (commonKey == AVMetadataKey.commonKeyTitle){
            artist = tag.stringValue!
          } else if (commonKey == AVMetadataKey.commonKeyTitle){
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
  for (index, _) in songs.enumerated() {
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

  for (index, song) in songs.enumerated() {
    if FuzzySearch.search(originalString: song.fullName, stringToSearch: consoleContent){
      searchSongs.append(index)
    }
  }

  return searchSongs
}

func playSound(_ path: String) {
  let fileData = try! Data(contentsOf: URL(fileURLWithPath: path))

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

func drawBorders(_ window: OpaquePointer, y: Int32, x: Int32){
  // spodni a horni linka
  mvwhline(window, 0, 1, UInt32("-"), x - 2)
  mvwhline(window, y - 1, 1, UInt32("-"), x - 2)

  // leva a prava linka
  mvwvline(window, 1, 1, UInt32("|"), y - 2)
  mvwvline(window, 1, x - 2, UInt32("|"), y - 2)
}

func trimTextToFitLine(_ line: String, maxLength: Int) -> String{
  var diff = maxLength - line.count - 1
  if diff <= 0 {
    diff *= -1
    let index1 = line.index(line.startIndex, offsetBy: diff)
    return line.substring(from: index1)
  }else{
    var out = line
    for _ in 0...diff{
      out += " "
    }
    return out
  }
}

func centerText(_ line: String, maxLength: Int) -> String{
  var diff = maxLength - line.count - 1
  if diff <= 0 { // line too long, trim instead of centering
    diff *= -1
    let index1 = line.index(line.startIndex, offsetBy: diff)
    return line.substring(from: index1)
  }

  let start = (maxLength - line.count - 1) / 2
  var out: String = ""
  for _ in 0...start{
    out += " "
  }
  if line.count > 0 { out += line }
  for _ in 0...start{
    out += " "
  }
  return out
}

func centerText(_ text:String, numlines:Int32, numcols:Int32) {
  let cy:Int32 = numlines / 2
  let cx:Int32 = (numcols - Int32(text.count)) / 2
  move(cy, cx)
  addstr(text)
  refresh()
}

func readInput(_ char: Int32){
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

      if player?.isPlaying == true {
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

func timeToString (_ audioLength: Float64) -> String{
  let minute_ = abs(Int((audioLength/60).truncatingRemainder(dividingBy: 60)))
  let second_ = abs(Int(audioLength.truncatingRemainder(dividingBy: 60)))


  let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
  let second = second_ > 9 ? "\(second_)" : "0\(second_)"
  return "\(minute):\(second)"
}

