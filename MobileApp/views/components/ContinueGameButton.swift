//
//  ContinueGameButton.swift
//  sudoku
//
//  Created by Kishan Jadav on 12/01/2025.
//

import SwiftUI
import CoreData

struct ContinueGameSection: View {
  @FetchRequest(
    fetchRequest:
      FetchRequestHelper.buildFetchRequestWithRelationship(
        predicate: NSPredicate(
          format: "SELF == %@",
          DataManager.default.usersService.repository.currentUserId
        ),
        relationshipKeyPathsForPrefetching: ["activeSaveGame"]
      ),
    animation: .interpolatingSpring
  ) private var users: FetchedResults<UserEntity>

  private var activeSaveGame: SaveGameEntity? {
    return self.users.first?.activeSaveGame
  }
  
  var body: some View {
    guard let activeSaveGame else {
      return AnyView(EmptyView())
    }
    
    return AnyView (
      ContinueGameButton(
        difficulty: Difficulty(rawValue: activeSaveGame.difficulty!)!,
        activeSaveGame: activeSaveGame
      )
    )
  }
}

struct ContinueGameButton: View {
  var difficulty: Difficulty
  @ObservedObject var activeSaveGame: SaveGameEntity
  
  private let vibrator = UIImpactFeedbackGenerator(style: .rigid)
  
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
    }
    .buttonStyle(ContinueGameButtonStyle())
    .onAppear(perform: vibrator.prepare)
  }
}

struct ContinueGameButtonStyle: ButtonStyle {
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .scaledToFit()
      .padding(12)
      .background(Color(TheTheme.Colors.primary).opacity(0.3))
      .clipShape(RoundedRectangle(cornerRadius: 14))
      .scaleEffect(configuration.isPressed ? 0.9 : 1)
      .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
  }
}
