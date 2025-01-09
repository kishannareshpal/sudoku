//
//  GameScene.swift
//  sudoku
//
//  Created by Kishan Jadav on 03/04/2022.
//

import SwiftUI
import SpriteKit

class GameScene: SKScene {
  @Binding var gameOver: Bool

  internal var difficulty: Difficulty
  internal var game: Game!

  public init(
    size: CGSize,
    gameOver: Binding<Bool>,
    difficulty: Difficulty,
    existingGame: SaveGameEntity?
  ) {
    self.difficulty = difficulty
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
    
    // Setup the scene's background color
    self.backgroundColor = UIColor.clear
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not supported on this application")
  }
  
  override func sceneDidLoad() {
//    self.game.load(on: self)
  }
  
  override func update(_ currentTime: TimeInterval) {
    super.update(currentTime)
  }

  func clearActivatedNumberCellNotes() -> Void {
    self.game.clearActivatedNumberCellNotes()
  }
  
  func clearActivatedNumberCellValue() -> Void {
    self.game.clearActivatedNumberValue()
    self.game.clearActivatedNumberCellNotes()
  }
  
  func changeActivatedNumberCellValue(to value: Int) -> Void {
    self.game.changeActivatedNumberCellValue(to: value)
  }
  
  func applyActivatedNumberCellNoteValue(to value: Int) -> Void {
    self.game.applyActivatedNumberCellNoteValue(to: value)
  }
  
  func didGameOver() {
    self.isPaused = true
    self.isUserInteractionEnabled = false

    self.gameOver = true
  }
}
