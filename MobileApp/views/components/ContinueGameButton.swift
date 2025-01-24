//
//  ContinueGameCard.swift
//  sudoku
//
//  Created by Kishan Jadav on 12/01/2025.
//

import SwiftUI

struct ContinueGameButton: View {
  @FetchRequest(
    sortDescriptors: [],
    predicate: .all
  ) private var saveGames: FetchedResults<SaveGameEntity>
  
  private var existingGame: SaveGameEntity? {
    return self.saveGames.last
  }

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
            
            Text("Points: \(existingGame.score)")
              .foregroundStyle(.white)
              .font(.system(size: 12, weight: .regular))
            
            Text(
              "Played for: \(GameDurationHelper.format(existingGame.durationInSeconds, pretty: true))"
            )
              .font(.system(size: 12, weight: .regular))
              .foregroundStyle(.white)
            
            Spacer().frame(height: 8)
            
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
      .buttonStyle(ContinueGameButtonStyle())
      .onAppear(perform: vibrator.prepare)
    )
  }
}

struct ContinueGameButtonStyle: ButtonStyle {
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
