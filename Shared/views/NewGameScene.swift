//
//  NewGameScene.swift
//  sudoku
//
//  Created by Kishan Jadav on 08/01/2025.
//

import SwiftUI
import SpriteKit

class NewGameScene: SKScene {
  internal var game: Game

  public init(
    size: CGSize,
    difficulty: Difficulty,
    existingGame: SaveGameEntity?
  ) {
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
    self.game.load(on: self)
  }
  
  func resize(size: CGSize) {
    // Cleanup previous elements from the scene
    self.removeAllActions()
    self.removeAllChildren()
    
    // Resize the scene
    self.size = size

    // Redraw all the elements to the scene
    self.game = Game(sceneSize: size, difficulty: self.game.difficulty)
    self.sceneDidLoad()
  }
  
  override func update(_ currentTime: TimeInterval) {
    super.update(currentTime)
    
    if self.game.isGameOver {
      self.didGameOver()
    }
  }

  func clearActivatedNumberCellNotes() -> Void {
    self.game.clearActivatedNumberCellNotes()
  }
  
  func clearActivatedNumberCellValueOrNotes() -> Void {
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
  }
}
