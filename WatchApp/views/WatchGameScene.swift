//
//  WatchGameScene.swift
//  sudoku
//
//  Created by Kishan Jadav on 08/01/2025.
//

import SwiftUI
import SpriteKit

class WatchGameScene: GameScene {
  @Binding var cursorState: CursorState
  
  init(
    size: CGSize,
    gameOver: Binding<Bool>,
    difficulty: Difficulty,
    existingGame: SaveGameEntity?,
    cursorState: Binding<CursorState>
  ) {
    self._cursorState = cursorState
    
    super.init(
      size: size,
      gameOver: gameOver,
      difficulty: difficulty,
      existingGame: existingGame
    )
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not supported on this application")
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
