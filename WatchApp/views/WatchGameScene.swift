//
//  WatchGameScene.swift
//  sudoku
//
//  Created by Kishan Jadav on 08/01/2025.
//

import SwiftUI
import SpriteKit

class WatchGameScene: GameScene {
  @Published private(set) var cursorState: CursorState = .init()

  override init(
    size: CGSize,
    difficulty: Difficulty
  ) {
    super.init(size: size, difficulty: difficulty)
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func update(_ currentTime: TimeInterval) {
    super.update(currentTime)

    self.listenToCrownRotationForCursorCellMovement()
    self.listenToCrownRotationForActivatedCellValueChange()
  }
  
  func toggleCellUnderCursor(mode: CursorMode, cancelled: Bool = false) -> Void {
    let active = self.game.toggleNumberCellUnderCursor(mode: mode, cancelled: cancelled)
    
    let nextCursorMode = active ? mode : .none
    
    withAnimation(.smooth) {
      self.cursorState.mode = nextCursorMode
    }
  }
  
  private func listenToCrownRotationForActivatedCellValueChange() {
    guard self.game.isNumberCellActive else { return }
    
    if (
      self.cursorState.crownRotationValue != self.cursorState.previousCrownRotationValue
    ) {
      let direction: Direction = (
        self.cursorState.crownRotationValue > self.cursorState.previousCrownRotationValue
      ) ? .forward : .backward
      
      self.game.changeActivatedNumberCellValue(
        cursorMode: self.cursorState.mode,
        direction: direction
      )
      
      self.cursorState.previousCrownRotationValue = self.cursorState.crownRotationValue
    }
  }
  
  private func listenToCrownRotationForCursorCellMovement() -> Void {
    guard (self.game.isNumberCellActive == false) else { return }
    
    let a = round(self.cursorState.crownRotationValue)
    let b = round(self.cursorState.previousCrownRotationValue)
    
    if (a != b) {
      let direction: Direction = (a > b) ? .forward : .backward
      self.game.moveCursor(direction: direction)
      
      // Update the previous value
      self.cursorState.previousCrownRotationValue = self.cursorState.crownRotationValue
    }
  }
}
