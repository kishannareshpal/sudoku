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
  @ObservedObject var game: Game

  @State var pauseGameBoardBlurRadius: CGFloat = 0.0
  @State var pauseGameTextScale: CGFloat = 0.0
  
  private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  private let currentColorScheme = StyleManager.current.colorScheme
  
  var body: some View {
    ZStack {
      SpriteView(scene: self.gameScene, preferredFramesPerSecond: 30)
        .scaledToFit()
        .blur(radius: pauseGameBoardBlurRadius)
        .animation(.easeInOut(duration: 0.2), value: pauseGameBoardBlurRadius)
        .onChange(of: self.game.isGamePaused) { _ in
          self.pauseGameBoardBlurRadius = self.game.isGamePaused ? 10 : 0
        }
        .apply { view in
          if #available(iOS 17.0, *) {
            view
              .focusable()
              .onKeyPress(phases: .down, action: self.gameScene.keyPressed)
          }
        }
      
      if self.game.isGamePaused {
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
    .onDisappear() {
      self.game.saveCurrentGameDuration()

    }.onChange(of: self.game.isGamePaused) { _ in
      self.pauseGameTextScale = self.game.isGamePaused ? 1 : 0

    }.overlay {
      GameDurationTracker(game: self.game)
    }
  }
}


struct GameSceneViewPreview: PreviewProvider {
  struct Content: View {
    private let sceneSize = CGSize(width: 250, height: 250)
    private let currentColorScheme = StyleManager.current.colorScheme

    @StateObject var dataProvider = AppDataProvider.shared
    @State var ready: Bool = false
    
    init() {
      StyleManager.current.switchColorScheme(to: .darkGrey)
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
          VStack {
            let gameScene = MobileGameScene(size: sceneSize)
            
            GameSceneView(
              gameScene: gameScene,
              game: gameScene.game
            )
          }.padding()
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
