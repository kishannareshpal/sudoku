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
  @Environment(\.dismiss) var dismissScreen: DismissAction

//  @StateObject private var sessionTracker = GameSessionDurationTracker()
  @State private var cursorState: CursorState = .init(mode: .number)
  
  var difficulty: Difficulty
  var existingGame: SaveGameEntity?

  @State private var gameScene: MobileGameScene
  
  init(difficulty: Difficulty, existingGame: SaveGameEntity? = nil) {
    self.difficulty = difficulty
    self.existingGame = existingGame
    
    gameScene = MobileGameScene(
      size: .init(width: 10, height: 10),
      difficulty: difficulty,
      existingGame: existingGame
    )
  }
  
  var body: some View {
    ZStack {
      Color.black
        .ignoresSafeArea()

      GeometryReader { geometry in
        Color.clear.onAppear() {
          gameScene.resize(size: geometry.size)
        }

        VStack {
          Text("Hello")
            .foregroundStyle(.white)
          
          Button("Increment") {
            
          }
          
          HStack(alignment: .center) {
            Button {
              self.dismissScreen()
            } label: {
              Image(systemName: "chevron.left")
                .font(.system(size: 24))
                .foregroundStyle(.white)
            }
            .padding(12)
            
            Spacer()
            
            VStack {
              Text("01:43:23")
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.white)
              
              Text("\(difficulty.rawValue) • 10 Points")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.white)
            }
            
            Spacer()
            
            Button {
              gameScene.isPaused.toggle()
            } label: {
              Image(systemName: "pause.fill")
                .font(.system(size: 24))
                .foregroundStyle(.white)
            }
            .padding(12)
          }

          Spacer()
        
          SpriteView(
            scene: gameScene,
            preferredFramesPerSecond: 60
          )
          .scaledToFit()
          
          Spacer()
          
          VStack(spacing: 12) {
            HStack(spacing: 12) {
              ControlButton(
                title: "Notes mode",
                subtitle: self.cursorState.mode == .note ? "On" : "Off",
                imageSystemName: self.cursorState.mode == .note ? "pencil.circle.fill" : "pencil.circle"
              ) {
                self.cursorState.mode = self.cursorState.mode == .number ? .note : .number
              }
            }
            
            NumberPad (
              onNumberKeyPress: { number in
                if self.cursorState.mode == .note {
                  gameScene.applyActivatedNumberCellNoteValue(to: number)
                } else {
                  gameScene.changeActivatedNumberCellValue(to: number)
                }
              },
              onClearKeyPress: {
                gameScene.clearActivatedNumberCellValueOrNotes()
              }
            )
          }

          Spacer()
        }
      }
      .padding()
//      .overlay {
//        GameOverOverlay()
//      }
    }
  }
}

#Preview {
    ContentView()
}
