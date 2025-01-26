//
//  GameHeaderInformation.swift
//  MobileApp
//
//  Created by Kishan Jadav on 12/01/2025.
//

import SwiftUI

struct GameHeaderInformation: View {
  @ObservedObject var game: Game

  var body: some View {
    VStack {      
      Text(GameDurationHelper.format(self.game.durationInSeconds))
        .font(.system(size: 24, weight: .bold).monospaced())
        .foregroundStyle(.white)
      
      Text("\(self.game.difficulty.rawValue) • \(self.game.score) Points")
        .font(.system(size: 14, weight: .regular))
        .foregroundStyle(.white)

    }
  }
}
