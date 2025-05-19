//
//  GameOverOverlay.swift
//  sudoku
//
//  Created by Kishan Jadav on 12/01/2025.
//

import SwiftUI

struct GameOverOverlay: View {
  private let currentColorScheme: ColorScheme = StyleManager.current.colorScheme
  @Environment(\.dismiss) var dismissScreen: DismissAction
  
  var game: Game
  @ObservedObject var gameState: GameState
  
  var body: some View {
    if (!self.gameState.isGameOver) {
      return AnyView(EmptyView())
    }
    
    return AnyView(
      ZStack {
        Color(
          self.currentColorScheme.board.cell.text.player.valid
        )
          .opacity(0.9)
          .ignoresSafeArea()
        
        VStack {
          Spacer()

          Image("Trophy")
            .tint(.white)
          
          VStack(alignment: .center) {
            Text("Well done!")
              .font(.system(size: 48, weight: .black))
              .foregroundStyle(
                Color(
                  self.currentColorScheme.ui.game.control.numpad.button.selected.text
                )
              )
            
            Text(
              "You successfully solved this \(self.game.difficulty.rawValue) puzzle in \(GameDurationHelper.format(self.gameState.duration.seconds, pretty: true)). Your final score is \(self.game.score) points!"
            )
            .font(.system(size: 24, weight: .bold))
              .foregroundStyle(
                Color(
                  self.currentColorScheme.ui.game.control.numpad.button.selected.text
                )
              )
              .multilineTextAlignment(.center)
          }
          
          Spacer()
          
          VStack(spacing: 14) {
            Text("Up for another challenge?")
              .font(.system(size: 12, weight: .bold))
              .foregroundStyle(
                Color(
                  self.currentColorScheme.ui.game.control.numpad.button.selected.text
                )
              )
            
            Button(
              action: {
                self.dismissScreen()
              },
              label: {
                HStack {
                  Text("New game")
                    .fontWeight(.bold)
                    .foregroundStyle(
                      Color(
                        self.currentColorScheme.ui.game.control.numpad.button.normal.text
                      )
                    )
                  
                  Spacer()
                  
                  Image(systemName: "plus")
                    .foregroundStyle(
                      Color(
                        self.currentColorScheme.ui.game.control.numpad.button.normal.text
                      )
                    )
                }
              }
            ).buttonStyle(
              NormalButtonStyle(
                backgroundColor: Color(
                  self.currentColorScheme.ui.game.control.numpad.button.normal.background
                )
              )
            )
          }
        }
        .frame(maxWidth: 400)
        .padding(24)
      }
    )
  }
}
