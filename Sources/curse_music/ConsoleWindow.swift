//
//  SearchWindow.swift
//  Test
//
//  Created by Adam Tomecek on 27/05/16.
//  Copyright © 2016 Adam Tomecek. All rights reserved.
//

import Foundation

func drawConsoleWindow(height: Int32, width: Int32){
  wclear(consoleWindow)
  drawBorders(consoleWindow!, y: height, x: width)

  var line = consoleContent

  var diff = maxColumns - line.count - 1
  if diff <= 0 {
    diff *= -1
    let index1 = line.index(line.startIndex, offsetBy: diff)
    line = line.substring(from: index1)
  }

  wmove(consoleWindow, 1, 3)
  waddstr(consoleWindow, line)
  wrefresh(consoleWindow)
}
