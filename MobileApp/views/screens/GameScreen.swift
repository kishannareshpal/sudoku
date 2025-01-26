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
  // TODO: Have an environment object for gameScene and game
  @StateObject private var gameScene: MobileGameScene
  
  @State private var showDb: Bool = false // TODO: remove

  init(existingGame: SaveGameEntity? = nil) {
    _gameScene = StateObject(
      wrappedValue: MobileGameScene(
        size: .init(width: 10, height: 10) // initial size. when the view is rendered and the screen geometry is known, the scene is automatically resized.
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
            HStack(spacing: 12) {
              HStack {
                UndoButton(game: self.gameScene.game)
                RedoButton(game: self.gameScene.game)
              }

              NotesModeToggleButton(
                game: self.gameScene.game,
                cursorState: self.gameScene.cursorState
              )
              
              HStack {
                EraseButton(
                  gameScene: self.gameScene,
                  game: self.gameScene.game
                )
                HintButton(game: self.gameScene.game)
              }
            }
            
            NumbersPad (
              gameScene: self.gameScene,
              game: self.gameScene.game,
              puzzle: self.gameScene.game.puzzle
            )
          }

          Spacer()
        }
      }
      .padding()
      .overlay {
        GameOverOverlay(game: self.gameScene.game)
      }.sheet(isPresented: $showDb) {
        DatabaseScreen(game: self.gameScene.game)
      }
    }
  }
}
