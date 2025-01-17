//
//  ExistingGameCard.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
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
  
  var body: some View {
    guard let existingGame = existingGame else {
      return AnyView(EmptyView())
    }

    return AnyView(
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
      }.listItemTint(Color(Theme.Colors.primary).opacity(0.3))
    )
  }
}
