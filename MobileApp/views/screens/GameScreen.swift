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
  // TODO: Have an environment object for gameScene?
  @StateObject private var gameScene: MobileGameScene
  
  private let currentColorScheme: ColorScheme = StyleManager.current.colorScheme

  init() {
    // TODO: Show a loading indicator on the game scene
    _gameScene = StateObject(
      wrappedValue: MobileGameScene(
        size: .init(width: 10, height: 10) // initial size. when the view is rendered and the screen geometry is known, the scene is automatically resized.
      )
    )
  }
  
  var body: some View {
    ZStack {
      Color(currentColorScheme.ui.game.background)
        .ignoresSafeArea()

      GeometryReader { geometry in
        Color.clear.onAppear() {
          self.gameScene.resize(size: geometry.size)
        }

        VStack {
          GameHeader(gameScene: self.gameScene)
            .padding(.horizontal)

          Spacer()
        
          VStack {
            GameSceneView(gameScene: self.gameScene, game: self.gameScene.game)
            
            Spacer()
            
            VStack(spacing: 12) {
              HStack(spacing: 12) {
                HStack {
                  UndoButton(game: self.gameScene.game)
                  //                RedoButton(game: self.gameScene.game)
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
                  //                HintButton(game: self.gameScene.game)
                }
              }
              
              NumbersPad (
                gameScene: self.gameScene,
                game: self.gameScene.game,
                puzzle: self.gameScene.game.puzzle,
                cursorState: self.gameScene.cursorState
              )
            }
          }.padding()
        }
      }
      .overlay {
        GameOverOverlay(game: self.gameScene.game)
      }
    }
  }
}

struct GameScreenPreview: PreviewProvider {
  struct Content: View {
    private let sceneSize = CGSize(width: 250, height: 250)
    private let currentColorScheme = StyleManager.current.colorScheme
    
    @StateObject var dataProvider = AppDataProvider.shared
    @State var ready: Bool = false
    
    init() {
      StyleManager.current.switchColorScheme(to: .lightBlue)
    }
    
    var body: some View {
      ZStack {
        Color(currentColorScheme.ui.game.background).onAppear {
          Task {
            try! await DataManager.default.saveGamesService.createNewSaveGame(
              difficulty: .easy
            )
            
            self.ready = true
          }
        }.ignoresSafeArea()
        
        if ready {
          GameScreen()
        } else {
          Text("Scene not ready!")
        }
      }
      .environment(\.managedObjectContext, dataProvider.container.viewContext)
    }
  }
  
  static var previews: some View {
    return Content()
  }
}
