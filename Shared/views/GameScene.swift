//
//  GameScene.swift
//  sudoku
//
//  Created by Kishan Jadav on 08/01/2025.
//

import SwiftUI
import SpriteKit
import Combine

class GameScene: SKScene, ObservableObject {
  @Published var game: Game

  public init(
    size: CGSize,
    difficulty: Difficulty
  ) {
    self.game = Game(
      sceneSize: size,
      difficulty: difficulty
    )
    
    super.init(size: size)
    
    self.name = "GameScene"
    self.anchorPoint = .zero

    self.scaleMode = .aspectFill
    self.isUserInteractionEnabled = true
    
    // Setup the scene's background color
    self.backgroundColor = UIColor.clear
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not supported on this application")
  }
  
  override func sceneDidLoad() {
    super.sceneDidLoad()

    self.game.load(on: self)
  }
  
  override func update(_ currentTime: TimeInterval) {
    super.update(currentTime)
    
    if (self.game.isGamePaused) {
      self.gameDidPause()
    } else {
      self.gameDidResume()
    }
    
    if (self.game.isGameOver) {
      self.gameDidOver()
    }
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

  func clearActivatedNumberCellNotes() -> Void {
    self.game.clearActivatedNumberCellNotes()
  }
  
  func clearActivatedNumberCellValueAndNotes() -> Void {
    self.game.clearActivatedNumberValue()
    self.game.clearActivatedNumberCellNotes()
  }
  
  func changeActivatedNumberCellValue(with value: Int) -> Void {
    self.game.changeActivatedNumberCellValue(with: value)
  } 
  
  func toggleActivatedNumberCellNoteValue(with value: Int) -> Void {
    self.game.toggleActivatedNumberCellNoteValue(with: value)
  }
  
  private func gameDidPause() {
    self.isUserInteractionEnabled = false
  }
  
  private func gameDidOver() {
    self.gameDidPause()
  }
  
  private func gameDidResume() {
    self.isUserInteractionEnabled = true
  }
}
