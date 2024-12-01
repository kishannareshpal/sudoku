//
//  WKInterfaceDevceExtension.swift
//  sudoku
//
//  Created by Kishan Jadav on 30/11/2024.
//

import WatchKit

extension WKInterfaceDevice {
  func is40mm() -> Bool {
    let currentDevice = WKInterfaceDevice.current()
    let bounds = currentDevice.screenBounds
    let retinaFactor = currentDevice.screenScale
    
    let width = bounds.width * retinaFactor
    let height = bounds.height * retinaFactor
    
    // Matches 40mm
    return (width == 324) && (height == 394)
  }
  
  func statusBarHeight() -> CGFloat {
    // current device
    let currentDevice = WKInterfaceDevice.current()
    let bounds = currentDevice.screenBounds
    let retinaFactor = currentDevice.screenScale
    
    // dimensions in pixels
    let width = bounds.width * retinaFactor
    let height = bounds.height * retinaFactor
    
    if #available(watchOS 10, *) {
      switch (width, height) {
      // 40mm: statusBar = 28pt (56px), screenBounds: 324 x 394
      case (324, 394):
        return 32
      // 41mm: statusBar = 34pt (68px), screenBounds: 352 x 430
      case (352, 430):
        return 38
      // 44mm: statusBar = 31pt (62px), screenBounds: 368 x 448
      case (368, 448):
        return 38
      // 45mm: statusBar = 35pt (70px), screenBounds: 396 x 484
      case (396, 484):
        return 42
      // 49mm: statusBar = 37pt (74px), screenBounds: 410 x 502
      case (410, 502):
        return 46
      // default to 40mm
      default:
        return 32
      }
    } else {
      switch (width, height) {
      // 38mm: statusBar = 19pt (38px), screenBounds: 272 x 340
      case (272, 340):
        return 19
      // 40mm: statusBar = 28pt (56px), screenBounds: 324 x 394
      case (324, 394):
        return 31
      // 41mm: statusBar = 34pt (68px), screenBounds: 352 x 430
      case (352, 430):
        return 34
      // 42mm: statusBar = 21pt (42px), screenBounds: 312 x 390
      case (312, 390):
        return 21
      // 44mm: statusBar = 31pt (62px), screenBounds: 368 x 448
      case (368, 448):
        return 31
      // 45mm: statusBar = 35pt (70px), screenBounds: 396 x 484
      case (396, 484):
        return 35
      // 49mm: statusBar = 37pt (74px), screenBounds: 410 x 502
      case (410, 502):
        return 37
      // default to 38mm
      default:
        return 19
      }
    }
  }
}
