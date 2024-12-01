//
//  ExistingGameCard.swift
//  sudoku
//
//  Created by Kishan Jadav on 27/08/2024.
//

import SwiftUI

struct ExistingGameCard: View {
  @FetchRequest(
    sortDescriptors: [],
    predicate: .all
  ) var saveGames: FetchedResults<SaveGameEntity>
  
  var existingGame: SaveGameEntity? {
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
        VStack(alignment: .leading) {
          HStack(alignment: .center) {
            Text(existingGame.difficulty ?? "Unknown")
              .font(.title3)
              .fontWeight(.black)
            
            Spacer()
            
            Image(systemName: "play.circle.fill")
              .font(.title2)
              .foregroundStyle(Color(Theme.Colors.primary))
          }
          
          Spacer(minLength: 8)
          
          Text("Tap to continue")
            .font(.footnote)
            .fontWeight(.medium)
            .foregroundStyle(Color(Theme.Colors.primary))
          
          Spacer()
        }
      }.listItemTint(Color(Theme.Colors.primary).opacity(0.3))
    )
  }
}

#Preview {
  NavigationView {
    List {
      ExistingGameCard()
    }
  }
}
