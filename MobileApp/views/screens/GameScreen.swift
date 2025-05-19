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
  private let currentColorScheme: ColorScheme = StyleManager.current.colorScheme

  // TODO: Have an environment object for gameScene?
  @StateObject private var gameScene: MobileGameScene
  

  init() {
    // TODO: Show a loading indicator on the game scene
    _gameScene = StateObject(
      wrappedValue: MobileGameScene(
        size: .init(width: 10, height: 10) // initial placeholder size. When the screen is rendered and its geometry is known, this scene is automatically resized to best fit the available space, achieving great responsiveness!
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
          
          VStack(spacing: 4) {
            Spacer(minLength: 0)
            
            GameSceneView(gameScene: self.gameScene)
            
            Spacer(minLength: 0)
            
            VStack(spacing: 6) {
              ZStack(alignment: .center) {
                HStack(spacing: 12) {
                  HStack {
                    UndoButton(gameScene: self.gameScene)
                    RedoButton(gameScene: self.gameScene)
                  }
                  
                  Spacer()
                  
                  HStack {
                    HintButton(gameScene: self.gameScene)
                    EraseButton(gameScene: self.gameScene)
                  }
                }
              }
              .frame(maxWidth: .infinity)
              
              NumbersPad(gameScene: self.gameScene)
              
              NotesModeToggleButton(gameScene: self.gameScene)
            }
            .frame(maxWidth: 400)
          }.padding()
        }
      }
      .overlay {
        GameOverOverlay(
          game: self.gameScene.game,
          gameState: self.gameScene.game.state
        )
      }
    }
    .navigationBarHidden(true)
    .preferredColorScheme(currentColorScheme.mode == .dark ? .dark : .light)
  }
}

//struct GameScreenPreview: PreviewProvider {
//  struct Content: View {
//    private let sceneSize = CGSize(width: 250, height: 250)
//    private let currentColorScheme = StyleManager.current.colorScheme
//    
//    @StateObject var dataProvider = AppDataProvider.shared
//    @State var ready: Bool = false
//    
//    init() {
//      StyleManager.current.switchColorScheme(to: .lightBlue)
//    }
//    
//    var body: some View {
//      ZStack {
//        Color(currentColorScheme.ui.game.background).onAppear {
//          try! DataManager.default.saveGamesService.createNewSaveGame(
//            difficulty: .easy
//          )
//          
//          self.ready = true
//        }.ignoresSafeArea()
//        
//        if ready {
//          GameScreen()
//        } else {
//          Text("Scene not ready!")
//        }
//      }
//      .environment(\.managedObjectContext, dataProvider.container.viewContext)
//    }
//  }
//  
//  static var previews: some View {
//    return Content()
//  }
//}
