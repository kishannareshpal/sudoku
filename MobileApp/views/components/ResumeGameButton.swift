//
//  ExistingGameCard.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

import SwiftUI

struct ResumeGameButton: View {
  var existingGame: SaveGameEntity?

  private let vibrator = UIImpactFeedbackGenerator(style: .rigid)
  
  var body: some View {
    guard let existingGame = existingGame else {
      return AnyView(EmptyView())
    }
    
    return AnyView (
      NavigationLink(
        destination: GameScreen(
          difficulty: Difficulty(rawValue: existingGame.difficulty!)!,
          existingGame: existingGame
        ).navigationBarBackButtonHidden()
      ) {
        HStack(alignment: .top) {
          VStack(alignment: .leading) {
            Text(existingGame.difficulty ?? "Unknown difficulty")
              .font(.system(size: 18, weight: .black))
              .foregroundStyle(.white)
            
            Spacer()
              .frame(height: 8)
            
            Text("Time spent: \(GameSessionDurationTracker.format(existingGame.durationInSeconds))")
              .font(.system(size: 12, weight: .regular))
              .foregroundStyle(.white)
            
            Text("Score: \(existingGame.score)")
              .foregroundStyle(.white)
              .font(.system(size: 12, weight: .regular))
            
            Text("Tap to continue")
              .font(.system(size: 14, weight: .medium))
              .foregroundStyle(Color(Theme.Colors.primary))
          }.scaledToFit()
          
          Spacer().frame(width: 24)
          
          Image(systemName: "play.circle.fill")
            .font(.system(size: 28))
            .foregroundStyle(Color(Theme.Colors.primary))
        }
      }
      .buttonStyle(ResumeGameButtonStyle())
    )
  }
}

struct ResumeGameButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaledToFit()
      .padding(12)
      .background(Color(Theme.Colors.primary).opacity(0.3))
      .clipShape(RoundedRectangle(cornerSize: .init(width: 14, height: 14)))
      .scaleEffect(configuration.isPressed ? 0.9 : 1)
      .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
  }
}
