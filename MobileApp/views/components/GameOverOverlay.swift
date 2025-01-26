//
//  GameOverOverlay.swift
//  sudoku
//
//  Created by Kishan Jadav on 12/01/2025.
//

import SwiftUI

struct GameOverOverlay: View {
  @Environment(\.dismiss) var dismissScreen: DismissAction
  
  @ObservedObject var game: Game
  
  var body: some View {
    if (!self.game.isGameOver) {
      return AnyView(EmptyView())
    }
    
    return AnyView(
      ZStack {
        Color(UIColor("#352800"))
          .opacity(0.95)
          .ignoresSafeArea()
        
        VStack {
          Spacer()

          Image("Trophy")
            .tint(.white)
          
          VStack(alignment: .center) {
            Text("Well done!")
              .font(.system(size: 48, weight: .bold))
              .foregroundStyle(.accent)
            
            Text(
              "You successfully solved this \(self.game.difficulty) puzzle in \(GameDurationHelper.format(self.game.durationInSeconds, pretty: true)). Your final score is \(self.game.score) points!"
            )
              .font(.system(size: 24, weight: .regular))
              .foregroundStyle(.white)
              .multilineTextAlignment(.center)
          }
          
          Spacer()
          
          VStack(spacing: 14) {
            Text("Up for another challenge?")
              .font(.system(size: 12, weight: .bold))
              .foregroundStyle(.white)
            
            Button(
              action: {
                try! DataManager.default.usersService.detachActiveSaveGame()

                self.dismissScreen()
              },
              label: {
                HStack {
                  Text("New game")
                    .fontWeight(.bold)
                    .foregroundStyle(.black)
                  
                  Spacer()
                  
                  Image(systemName: "plus")
                    .foregroundStyle(.black)
                }
              }
            ).buttonStyle(NormalButtonStyle(backgroundColor: .accent))
          }
        }
        .padding(24)
      }
    )
  }
}
