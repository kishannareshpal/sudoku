//
//  PreviewGameSceneView.swift
//  sudoku
//
//  Created by Kishan Jadav on 13/02/2025.
//

import SpriteKit
import SwiftUI

struct PreviewGameSceneView: View {
  @StateObject private var gameScene: PreviewGameScene
  
  init(puzzle: Puzzle) {
    _gameScene = StateObject(
      wrappedValue: PreviewGameScene(
        size: .init(width: 10, height: 10), // initial size. when the view is rendered and the screen geometry is known, the scene is automatically resized
        puzzle: puzzle
      )
    )
  }
  
  var body: some View {
    GeometryReader { geometry in
      Color.clear.onAppear() {
        self.gameScene.resize(size: geometry.size)
      }
      
      SpriteView(
        scene: self.gameScene,
        preferredFramesPerSecond: 1
      )
      .scaledToFit()
    }
    .transition(.scale.animation(.easeInOut(duration: 1)))
  }
}
