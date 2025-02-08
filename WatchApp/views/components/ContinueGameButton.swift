//
//  ExistingGameCard.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

import SwiftUI

struct ContinueGameSection: View {
  @FetchRequest(
    fetchRequest:
      FetchRequestHelper.buildFetchRequest(
        predicate: NSPredicate(
          format: "active == %d",
          true
        )
      ),
    animation: .interpolatingSpring
  ) private var activeSaveGames: FetchedResults<SaveGameEntity>
  
  private var activeSaveGame: SaveGameEntity? {
    return self.activeSaveGames.first
  }
  
  var body: some View {
    guard let activeSaveGame else {
      return AnyView(EmptyView())
    }

    return AnyView(
      Section(
        header: VStack(alignment: .leading) {
          Text("Welcome back!").fontWeight(.bold)
          Text("Continue where you left off:").font(.system(size: 12))
        }
      ) {
        ContinueGameButton(
          difficulty: Difficulty(rawValue: activeSaveGame.difficulty!)!,
          activeSaveGame: activeSaveGame
        )
      }.padding(.vertical)
    )
  }
}

struct ContinueGameButton: View {
  var difficulty: Difficulty
  @ObservedObject var activeSaveGame: SaveGameEntity
  
  var body: some View {
    NavigationLink(
      destination: GameScreen().navigationBarBackButtonHidden()
    ) {
      HStack(alignment: .top) {
        VStack(alignment: .leading) {
          Text(activeSaveGame.difficulty ?? "Unknown difficulty")
            .font(.system(size: 18, weight: .black))
            .foregroundStyle(.white)
          
          Text("Points: \(activeSaveGame.score)")
            .foregroundStyle(.white)
            .font(.system(size: 12, weight: .regular))
          
          Text(
            "Played for: \(GameDurationHelper.format(activeSaveGame.durationInSeconds, pretty: true))"
          )
          .font(.system(size: 12, weight: .regular))
          .foregroundStyle(.white)
          
          Spacer().frame(height: 8)
          
          Text("Tap to continue")
            .font(.system(size: 14, weight: .medium))
            .foregroundStyle(Color(TheTheme.Colors.primary))
        }.scaledToFit()
        
        Spacer().frame(width: 24)
        
        Image(systemName: "play.circle.fill")
          .font(.system(size: 28))
          .foregroundStyle(Color(TheTheme.Colors.primary))
      }
    }.listItemTint(Color(TheTheme.Colors.primary).opacity(0.3))
  }
}
