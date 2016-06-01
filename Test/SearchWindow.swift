//
//  SearchWindow.swift
//  Test
//
//  Created by Adam Tomecek on 27/05/16.
//  Copyright © 2016 Adam Tomecek. All rights reserved.
//

import Foundation

func drawConsoleWindow(height: Int32, width: Int32){
  refresh()
  wclear(searchWindow)
  drawBorders(searchWindow, y: height, x: width)
  
  var line = consoleContent
  
  var diff = maxColumns - line.characters.count - 1
  if diff <= 0 {
    diff *= -1
    let index1 = line.startIndex.advancedBy(diff)
    line = line.substringFromIndex(index1)
  }
  
  wmove(searchWindow, 1, 3)
  waddstr(searchWindow, line)
  wrefresh(searchWindow)
}