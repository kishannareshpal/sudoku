//
//  PreviewGameScene.swift
//  sudoku
//
//  Created by Kishan Jadav on 08/02/2025.
//

import Foundation
import SpriteKit

class PreviewGameScene: SKScene, ObservableObject {
  private let currentColorScheme = StyleManager.current.colorScheme

  var game: PreviewGame
  
  init(size: CGSize, puzzle: Puzzle) {
    self.game = PreviewGame(sceneSize: size, puzzle: puzzle)
    
    super.init(size: size)
    
    self.name = "GameScene"
    self.anchorPoint = .zero
    self.scaleMode = .aspectFill
    self.isUserInteractionEnabled = false
    self.isPaused = true
    
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
  
  func resize(size: CGSize) {
    // Cleanup previous elements from the scene
    self.removeAllActions()
    self.removeAllChildren()
    
    // Resize the scene
    self.size = size
    
    // Redraw all the elements to the scene
    self.game = PreviewGame(sceneSize: size, puzzle: self.game.puzzle)

    self.sceneDidLoad()
  }
}
