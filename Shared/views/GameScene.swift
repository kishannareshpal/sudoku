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
  private let currentColorScheme = StyleManager.current.colorScheme

  @Published var game: Game

  public override init(size: CGSize) {
    self.game = try! Game(sceneSize: size)
    
    super.init(size: size)
    
    self.name = "GameScene"
    self.anchorPoint = .zero

    self.scaleMode = .aspectFill
    self.isUserInteractionEnabled = true
    
    // Setup the scene's background color
    self.backgroundColor = self.currentColorScheme.board.background
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not supported by this application")
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
    self.game = try! Game(sceneSize: size)
    
    self.sceneDidLoad()
  }

  func clearActivatedNumberCellNotes() -> Void {
    self.game.clearActivatedNumberCellNotes(recordMove: true)
  }
  
  func clearActivatedNumberCellValueAndNotes() -> Void {
    self.game.clearActivatedNumberCellValueAndNotes(recordMove: true)
  }
  
  func changeActivatedNumberCellValue(to value: Int) -> Void {
    self.game.changeActivatedNumberCellValue(to: value, recordMove: true)
  }
  
  func toggleActivatedNumberCellNoteValue(with value: Int) -> Void {
    self.game.toggleActivatedNumberCellNoteValue(with: value, recordMove: true)
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
