//
//  GameScene.swift
//  sudoku
//
//  Created by Kishan Jadav on 03/04/2022.
//

import SwiftUI
import WatchKit
import SpriteKit

class GameScene: SKScene {
  @Binding var crownRotationValue: Double
  @Binding var gameOver: Bool

  private var previousCrownRotationValue: Double = 0
  private var difficulty: Difficulty
  private var game: Game!

  init(
    size: CGSize,
    crownRotationValue: Binding<Double>,
    gameOver: Binding<Bool>,
    difficulty: Difficulty,
    existingGame: SaveGameEntity?
  ) {
    self.difficulty = difficulty
    self._crownRotationValue = crownRotationValue
    self._gameOver = gameOver

    self.game = Game(
      sceneSize: size,
      difficulty: difficulty
    )
    
    super.init(size: size)
    
    self.name = "GameScene"
    self.anchorPoint.x = 0
    self.anchorPoint.y = 0
    
    self.scaleMode = .aspectFill
    self.isUserInteractionEnabled = true
    
    // Setup the grid background color
    self.backgroundColor = Theme.Board.bg
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not supported on this application")
  }
  
  override func sceneDidLoad() {
    self.game.load(on: self)
  }
  
  override func update(_ currentTime: TimeInterval) {
    super.update(currentTime)
    
    self.listenToCrownRotationForCursorCellMovement()
    self.listenToCrownRotationForActivatedCellValueChange()
  }
  
  func toggleCellUnderCursor(mode: CursorActivationMode, cancelled: Bool = false) -> CursorState {
    let active = self.game.toggleNumberCellUnderCursor(mode: mode, cancelled: cancelled)
    
    let activationMode = active ? mode : .none
    return .init(
      activationMode: activationMode,
      location: self.game.cursorLocation,
      crownRotationValue: crownRotationValue,
      preActivationModeChangeCrownRotationValue: crownRotationValue
    )
  }
  
  func clearActivatedNumberCellNotes() -> Void {
    self.game.clearActivatedNumberCellNotes()
  }
  
  func applyActivatedNumberCellNoteValue(to value: Int) async -> Void {
    await self.game.applyActivatedNumberCellNoteValue(to: value)
  }
  
  func didGameOver() {
    self.isPaused = true
    self.isUserInteractionEnabled = false

    self.gameOver = true
  }
  
  private func listenToCrownRotationForActivatedCellValueChange() {
    guard self.game.isNumberCellActive else { return }
    
    if (crownRotationValue != previousCrownRotationValue) {
      let direction: Direction = (
        self.crownRotationValue > self.previousCrownRotationValue
      ) ? .forward : .backward

      self.game.changeActivatedNumberCellValue(direction: direction)

      self.previousCrownRotationValue = crownRotationValue
    }
  }
  
  private func listenToCrownRotationForCursorCellMovement() -> Void {
    guard (self.game.isNumberCellActive == false) else { return }
    
    let a = round(self.crownRotationValue)
    let b = round(self.previousCrownRotationValue)

    if (a != b) {
      let direction: Direction = (a > b) ? .forward : .backward
      self.game.moveCursor(direction: direction)
      
      // Update the previous value
      self.previousCrownRotationValue = crownRotationValue
    }
  }
}
