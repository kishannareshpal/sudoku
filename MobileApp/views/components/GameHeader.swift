//
//  GameHeader.swift
//  MobileApp
//
//  Created by Kishan Jadav on 12/01/2025.
//

import SwiftUI

struct GameHeader: View {  
  @ObservedObject var gameScene: MobileGameScene
  
  var body: some View {
    ZStack {
      HStack(alignment: .center) {
        BackButton()
        
        Spacer()
        
        PauseGameButton(game: self.gameScene.game)
      }
      
      VStack(alignment: .center) {
        Content(game: self.gameScene.game)
      }
    }
    .padding(12)
  }
}

struct Content: View {
  private let currentColorScheme: ColorScheme = StyleManager.current.colorScheme
  @ObservedObject var game: Game
  
  var body: some View {
    VStack {
      Text(GameDurationHelper.format(self.game.durationInSeconds))
        .font(.system(size: 24, weight: .bold).monospaced())
        .foregroundStyle(Color(currentColorScheme.ui.game.nav.text))
      
      Text("\(self.game.difficulty.rawValue) • \(self.game.score) Points")
        .font(
          .system(size: 14, weight: .regular)
        )
        .foregroundStyle(
          Color(currentColorScheme.ui.game.nav.text.cgColor)
        )
    }
  }
}

