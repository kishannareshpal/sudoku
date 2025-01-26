//
//  GameScreen.swift
//  sudoku
//
//  Created by Kishan Jadav on 17/08/2024.
//

import SwiftUI
import SpriteKit

struct GameScreen: View {
  @StateObject private var gameScene: WatchGameScene

  var difficulty: Difficulty
  var existingGame: SaveGameEntity?
  
  init(difficulty: Difficulty, existingGame: SaveGameEntity? = nil) {
    self.difficulty = difficulty
    self.existingGame = existingGame
    
    _gameScene = StateObject(
      wrappedValue: WatchGameScene(
        size: .init(width: 10, height: 10) // initial size. when the view is rendered and the screen geometry is known, the scene is automatically resized
      )
    )
  }
  
  var body: some View {
    GeometryReader { geometry in
      Color.clear.onAppear() {
        self.gameScene.resize(size: geometry.size)
      }

      GameSceneView(
        gameScene: self.gameScene,
        game: self.gameScene.game,
        cursorState: self.gameScene.cursorState
      )
      
      GameNotesToolbar(
        gameScene: self.gameScene,
        cursorState: self.gameScene.cursorState
      )
      
      GameMenuToolbar(
        gameScene: self.gameScene,
        cursorState: self.gameScene.cursorState
      )
      .frame(
        width: geometry.size.width,
        height: geometry.safeAreaInsets.top,
        alignment: .leading
      )
      .ignoresSafeArea(
        edges: [.top]
      )

    }
    .overlay {
      GameOverOverlay(game: self.gameScene.game)
    }
  }
}
