//
//  ContentView.swift
//  MobileApp
//
//  Created by Kishan Jadav on 04/01/2025.
//

import SwiftUI
import SpriteKit
import UIKit.UIColor
import UIColorHexSwift

struct GameScreen: View {
  @StateObject private var gameScene: MobileGameScene
  
  var difficulty: Difficulty
  var existingGame: SaveGameEntity?
  
  init(difficulty: Difficulty, existingGame: SaveGameEntity? = nil) {
    self.difficulty = difficulty
    self.existingGame = existingGame
    
    _gameScene = StateObject(
      wrappedValue: MobileGameScene(
        size: .init(width: 10, height: 10), // initial size. when the view is rendered and the screen geometry is known, the scene is automatically resized.
        difficulty: difficulty
      )
    )
  }
  
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      GeometryReader { geometry in
        Color.clear.onAppear() {
          self.gameScene.resize(size: geometry.size)
        }

        VStack {
          GameHeader(gameScene: self.gameScene)

          Spacer()
        
          GameSceneView(gameScene: self.gameScene, game: self.gameScene.game)
          
          Spacer()
          
          VStack(spacing: 12) {
            NotesModeToggleButton(
              game: self.gameScene.game,
              cursorState: self.gameScene.cursorState
            )
            
            NumbersPad (
              gameScene: self.gameScene,
              game: self.gameScene.game,
              puzzle: self.gameScene.game.board.puzzle
            )
          }

          Spacer()
        }
      }
      .padding()
      .overlay {
        GameOverOverlay(game: self.gameScene.game)
      }
    }
  }
}

#Preview {
    ContentView()
}
