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
//  @StateObject private var sessionTracker = GameSessionDurationTracker()
  @State private var exitedGame: Bool = false
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
          HStack(alignment: .center) {
            Button {
              
            } label: {
              Image(systemName: "chevron.left")
                .font(.system(size: 24))
            }
            .padding(12)
            
            Spacer()
            
            Text("Sudoku")
              .font(.largeTitle.weight(.black))
              .foregroundStyle(Color(Theme.Colors.primary))
            
            Spacer()
            
            Button {
              
            } label: {
              Image(systemName: "pause.fill")
                .font(.system(size: 24))
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
            
            KeyPad (
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
    }
  }
}

#Preview {
    ContentView()
}
