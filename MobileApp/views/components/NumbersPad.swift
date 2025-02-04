//
//  NumberPad.swift
//  sudoku
//
//  Created by Kishan Jadav on 07/01/2025.
//

import SwiftUI
import SpriteKit
import UIKit.UIColor
import UIColorHexSwift

struct NumbersPad: View {
  var gameScene: MobileGameScene
  @ObservedObject var game: Game
  @ObservedObject var puzzle: Puzzle
  
  private var numberKeyVibrator = UIImpactFeedbackGenerator(style: .medium)

  init(
    gameScene: MobileGameScene,
    game: Game,
    puzzle: Puzzle
  ) {
    self.gameScene = gameScene
    self.game = game
    self.puzzle = puzzle
  }
  
  var canInsertNumbersOrNotes: Bool {
    if self.game.isGamePaused || self.game.isGameOver {
      return false
    }
    
    return self.game.activatedNumberCell?.isChangeable ?? false
  }
  
  var isActiveNumberCellEraseable: Bool {
    if self.game.isGamePaused || self.game.isGameOver {
      return false
    }
    
    return self.game.activatedNumberCell?.isEraseable ?? false
  }

  private func onNumberKeyPress(_ number: Int) {
    numberKeyVibrator.impactOccurred()

    self.gameScene.changeOrToggleActivatedNumberCellValueOrNote(
      with: number
    )
  }
  
  var body: some View {
    VStack(spacing: 8) {
      HStack(spacing: 8) {
        ForEach(1...3, id: \.self) { number in
          let isNumberUsedUp = (self.puzzle.remainingNumbersWithCount[number] ?? 0) <= 0
          let unavailable = !self.canInsertNumbersOrNotes || isNumberUsedUp
          
          Button("\(number)", action: { onNumberKeyPress(number) })
            .disabled(unavailable)
            .buttonStyle(NumberButtonStyle(disabled: unavailable))
        }
      }
      
      HStack(spacing: 8) {
        ForEach(4...6, id: \.self) { number in
          let isNumberUsedUp = (self.puzzle.remainingNumbersWithCount[number] ?? 0) <= 0
          let unavailable = !self.canInsertNumbersOrNotes || isNumberUsedUp
          
          Button("\(number)", action: { onNumberKeyPress(number) })
            .disabled(unavailable)
            .buttonStyle(NumberButtonStyle(disabled: unavailable))
        }
      }
      
      HStack {
        ForEach(7...9, id: \.self) { number in
          let isNumberUsedUp = (self.puzzle.remainingNumbersWithCount[number] ?? 0) <= 0
          let unavailable = !self.canInsertNumbersOrNotes || isNumberUsedUp
          
          Button("\(number)", action: { onNumberKeyPress(number) })
            .disabled(unavailable)
            .buttonStyle(NumberButtonStyle(disabled: unavailable))
        }
      }
    }
    .onAppear() {
      numberKeyVibrator.prepare()
    }
  }
}

struct NumberButtonStyle: ButtonStyle {
  var disabled: Bool = false
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.custom(Theme.Fonts.mono, size: 22))
      .frame(width: 56, height: 56)
      .background(Color(UIColor("#141414")))
      .foregroundStyle(.white)
      .opacity(self.disabled ? 0.3 : 1)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .scaleEffect(configuration.isPressed ? 0.9 : 1)
      .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
  }
}
