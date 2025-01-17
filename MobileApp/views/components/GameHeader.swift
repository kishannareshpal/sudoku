//
//  GameHeader.swift
//  MobileApp
//
//  Created by Kishan Jadav on 12/01/2025.
//

import SwiftUI

struct GameHeader: View {
  @Environment(\.dismiss) var dismissScreen: DismissAction
  
  @ObservedObject var gameScene: MobileGameScene
  
  var body: some View {
    ZStack {
      HStack(alignment: .center) {
        Button(
          action: {
            self.dismissScreen()
          },
          label: {
            Image(systemName: "chevron.left")
              .font(.system(size: 24))
              .foregroundStyle(.white)
          }
        )
        
        Spacer()
        
        PauseGameButton(game: self.gameScene.game)
      }
      
      VStack(alignment: .center) {
        GameHeaderInformation(game: self.gameScene.game)
      }
    }
    .padding(12)
  }
}
