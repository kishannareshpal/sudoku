//
//  GameScreen.swift
//  sudoku
//
//  Created by Kishan Jadav on 17/08/2024.
//

import SwiftUI
import SpriteKit

struct GameScreen: View {
  private let currentColorScheme: ColorScheme = StyleManager.current.colorScheme

  @StateObject private var gameScene: WatchGameScene
  
  init() {
    _gameScene = StateObject(
      wrappedValue: WatchGameScene(
        size: .init(width: 10, height: 10) // initial size. when the view is rendered and the screen geometry is known, the scene is automatically resized
      )
    )
  }
  
  var body: some View {
    GeometryReader { geometry in
      ScreenBackgroundColor(
        currentColorScheme: self.currentColorScheme
      )
      .onAppear() {
        self.gameScene.resize(size: geometry.size)
      }
      .ignoresSafeArea()

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
    .apply { view in
      if #available(watchOS 9.0, *) {
        view
          .toolbarColorScheme(
            self.currentColorScheme.mode == .light ? .light : .dark,
            for: .automatic
          )
      } else {
        view
      }
    }
    .overlay {
      GameOverOverlay(
        game: self.gameScene.game,
        gameState: self.gameScene.game.state
      )
    }
    .navigationBarBackButtonHidden()
  }
}
