//
//  GameOverOverlay.swift
//  sudoku
//
//  Created by Kishan Jadav on 28/08/2024.
//

import SwiftUI
import UIColorHexSwift

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
        
        GeometryReader { geometry in
          ScrollView(showsIndicators: false) {
            VStack {
              Spacer()
              
              Image("Trophy")
                .resizable()
                .frame(width: 64, height: 64)
                .tint(.white)
              
              Spacer(minLength: 8)
              
              Text("Well done!")
                .font(.headline)
                .fontWeight(.black)
                .foregroundStyle(
                  Color(
                    self.currentColorScheme.ui.game.control.numpad.button.selected.text
                  )
                )
              
              Text(
                "You've solved this \(self.game.difficulty) puzzle in \(GameDurationHelper.format(self.gameState.duration.seconds, pretty: true)). Your final score is \(self.game.score) points!"
              )
                .font(.system(size: 12))
                .fontWeight(.regular)
                .multilineTextAlignment(.center)
                .foregroundStyle(
                  Color(
                    self.currentColorScheme.ui.game.control.numpad.button.selected.text
                  )
                )
              
              Text("Up for another challenge?")
                .font(.system(size: 12))
                .fontWeight(.regular)
                .multilineTextAlignment(.center)
                .foregroundStyle(
                  Color(
                    self.currentColorScheme.ui.game.control.numpad.button.selected.text
                  )
                )
              
              Spacer(minLength: 12)
              
              Button {
//                Task {
//                  await DataManager.default.saveGamesService.detachActiveSaveGame()                  
//                }

                self.dismissScreen()
              } label: {
                Image(systemName: "plus")
                Text("New game")
              }
              .tint(
                Color(
                  self.currentColorScheme.ui.game.control.numpad.button.normal.background
                )
              )
              
              
              Spacer()
            }
            .frame(width: geometry.size.width)
            .frame(minHeight: geometry.size.height)
          }
          .focusable(self.gameState.isGameOver)
          .frame(maxWidth: .infinity, maxHeight:.infinity)
        }
      }
    )
  }
}
