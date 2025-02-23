//
//  GameOverOverlay.swift
//  sudoku
//
//  Created by Kishan Jadav on 28/08/2024.
//

import SwiftUI
import UIColorHexSwift

struct GameOverOverlay: View {
  @Environment(\.dismiss) var dismissScreen: DismissAction

  var game: Game
  @ObservedObject var gameState: GameState
  
  var body: some View {
    if (!self.gameState.isGameOver) {
      return AnyView(EmptyView())
    }
    
    return AnyView(
      ZStack {
        Color(UIColor("#352800"))
          .opacity(0.95)
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
              
              Text(
                "You've solved this \(self.game.difficulty) puzzle in \(GameDurationHelper.format(self.gameState.duration.seconds, pretty: true)). Your final score is \(self.game.score) points!"
              )
                .font(.system(size: 12))
                .fontWeight(.regular)
                .multilineTextAlignment(.center)
              
              Text("Up for another challenge?")
                .font(.system(size: 12))
                .fontWeight(.regular)
                .multilineTextAlignment(.center)
              
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
