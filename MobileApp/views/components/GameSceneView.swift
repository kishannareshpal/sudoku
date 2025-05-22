//
//  GameSceneView.swift
//  sudoku
//
//  Created by Kishan Jadav on 12/01/2025.
//

import SpriteKit
import SwiftUI

struct GameSceneView: View {
  var gameScene: MobileGameScene
  
  var body: some View {
    GameSceneViewContent(
      gameScene: self.gameScene,
      gameState: self.gameScene.game.state
    )
    .onDisappear() {
      self.gameScene.game.saveCurrentGameDuration()
    }
  }
}

private struct GameSceneViewContent: View {
  private let currentColorScheme = StyleManager.current.colorScheme
  
  var gameScene: MobileGameScene
  @ObservedObject var gameState: GameState

  @State var pauseGameTextScale: CGFloat = 0.0
  @State var pauseGameBoardBlurRadius: CGFloat = 0.0

  var body: some View {
    ZStack {
      SpriteView(
        scene: self.gameScene,
        preferredFramesPerSecond: 60
      )
        .scaledToFit()
        .blur(radius: self.pauseGameBoardBlurRadius)
        .animation(.easeInOut(duration: 0.2), value: self.pauseGameBoardBlurRadius)
        .apply { view in
          if #available(iOS 17.0, *) {
            view
              .focusable()
              .focusEffectDisabled(self.gameState.isGamePaused)
              .onKeyPress(phases: .down, action: self.gameScene.keyPressed)
          } else {
            view
          }
        }
      
      if self.gameState.isGamePaused {
        Text("Paused")
          .font(.system(size: 48, weight: .bold))
          .foregroundStyle(
            Color(self.currentColorScheme.ui.game.pauseText)
          )
          .scaleEffect(self.pauseGameTextScale)
          .animation(
            .spring(response: 0.5, dampingFraction: 0.6),
            value: self.pauseGameTextScale
          )
      }
    }
    .onChange(of: self.gameState.isGamePaused) { isPaused in
      self.pauseGameTextScale = isPaused ? 1 : 0
      self.pauseGameBoardBlurRadius = isPaused ? 10 : 0
    }
  }
}


//struct GameSceneViewPreview: PreviewProvider {
//  struct Content: View {
//    private let sceneSize = CGSize(width: 250, height: 250)
//    private let currentColorScheme = StyleManager.current.colorScheme
//
//    @StateObject var dataProvider = AppDataProvider.shared
//    @State var ready: Bool = false
//    
//    init() {
//      StyleManager.current.switchColorScheme(to: .darkGrey)
//    }
//    
//    var body: some View {
//      ZStack {
//        Color(currentColorScheme.ui.game.background).onAppear {
//          Task {
//            try! await DataManager.default.saveGamesService.createNewSaveGame(
//              difficulty: .easy
//            )
//            
//            self.ready = true
//          }
//        }.ignoresSafeArea()
//        
//        if ready {
//          VStack {
//            let gameScene = MobileGameScene(size: sceneSize)
//            
//            GameSceneView(
//              gameScene: gameScene
////              gameState: gameScene.game.state
//            )
//          }.padding()
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
