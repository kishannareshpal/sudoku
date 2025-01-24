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

  @State var pauseGameBlurRadius: CGFloat = 0
  @State var pauseGameTextValue: CGFloat = 0
  
  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
  
  var body: some View {
    ZStack {
      SpriteView(scene: self.gameScene, preferredFramesPerSecond: 60)
        .scaledToFit()
        .blur(radius: pauseGameBlurRadius)
        .animation(.easeInOut(duration: 0.2), value: pauseGameBlurRadius)
        .onChange(of: self.game.isGamePaused) { _ in
          self.pauseGameBlurRadius = self.game.isGamePaused ? 10 : 0
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
          .foregroundStyle(.white)
          .scaleEffect(pauseGameTextValue)
          .animation(
            .spring(response: 0.5, dampingFraction: 0.6),
            value: pauseGameTextValue
          )
      }

    }
    .onDisappear() {
      self.game.saveCurrentGameDuration()

    }.onChange(of: self.game.isGamePaused) { _ in
      self.pauseGameTextValue = self.game.isGamePaused ? 1 : 0

    }.overlay {
      GameDurationTracker(game: self.game)
    }
  }
}
