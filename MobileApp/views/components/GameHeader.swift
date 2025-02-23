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

        PauseGameButton(gameScene: self.gameScene)
      }
  
      CenteredInformation(gameScene: self.gameScene)
    }
    .padding(12)
  }
}

struct CenteredInformation: View {
  var gameScene: MobileGameScene

  private let currentColorScheme: ColorScheme = StyleManager.current.colorScheme
  @AppStorage(UserDefaultKey.showTimer.rawValue) private var showTimer: Bool = true
  
  var body: some View {
    VStack(alignment: .center) {      
      if showTimer {
        DurationText(gameDuration: self.gameScene.game.state.duration)
          .overlay {
            GameDurationTracker(gameState: self.gameScene.game.state)
          }
      }
      
      Text(
        "\(self.gameScene.game.difficulty.rawValue) • \(self.gameScene.game.score) Points"
      )
        .font(.system(size: 14, weight: .regular))
        .foregroundStyle(Color(self.currentColorScheme.ui.game.nav.text.cgColor))
    }
  }
}



