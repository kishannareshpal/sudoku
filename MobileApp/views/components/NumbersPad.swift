//
//  NumbersPad.swift
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
  @ObservedObject var cursorState: CursorState
  
  private var currentColorScheme = StyleManager.current.colorScheme
  private var numberKeyVibrator = UIImpactFeedbackGenerator(style: .medium)

  init(
    gameScene: MobileGameScene,
    game: Game,
    puzzle: Puzzle,
    cursorState: CursorState
  ) {
    self.gameScene = gameScene
    self.game = game
    self.puzzle = puzzle
    self.cursorState = cursorState
  }
  
  var canInsertNumbersOrNotes: Bool {
    if self.game.isGamePaused || self.game.isGameOver {
      return false
    }
    
    if (cursorState.mode == .note) {
      return self.game.activatedNumberCell?.isNotable ?? false
    } else {
      return self.game.activatedNumberCell?.isChangeable ?? false
    }
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
          let isNoteToggled = self.cursorState.mode == .note && self.puzzle.isNoteToggled(
            value: number,
            at: self.game.cursorLocation
          )
          
          Button("\(number)", action: { onNumberKeyPress(number) })
            .disabled(unavailable)
            .buttonStyle(
              NumbersPadButtonStyle(
                isEnabled: !unavailable,
                isChecked: isNoteToggled
              )
            )
        }
      }
      
      HStack(spacing: 8) {
        ForEach(4...6, id: \.self) { number in
          let isNumberUsedUp = (self.puzzle.remainingNumbersWithCount[number] ?? 0) <= 0
          let unavailable = !self.canInsertNumbersOrNotes || isNumberUsedUp
          let isNoteToggled = self.cursorState.mode == .note && self.puzzle.isNoteToggled(
            value: number,
            at: self.game.cursorLocation
          )
          
          Button("\(number)", action: { onNumberKeyPress(number) })
            .disabled(unavailable)
            .buttonStyle(
              NumbersPadButtonStyle(
                isEnabled: !unavailable,
                isChecked: isNoteToggled
              )
            )
        }
      }
      
      HStack {
        ForEach(7...9, id: \.self) { number in
          let isNumberUsedUp = (self.puzzle.remainingNumbersWithCount[number] ?? 0) <= 0
          let unavailable = !self.canInsertNumbersOrNotes || isNumberUsedUp
          let isNoteToggled = self.cursorState.mode == .note && self.puzzle.isNoteToggled(
            value: number,
            at: self.game.cursorLocation
          )
          
          Button("\(number)", action: { onNumberKeyPress(number) })
            .disabled(unavailable)
            .buttonStyle(
              NumbersPadButtonStyle(
                isEnabled: !unavailable,
                isChecked: isNoteToggled
              )
            )
        }
      }
    }
    .padding(8)
    .background {
      if self.cursorState.mode == .note {
        Color(
          currentColorScheme.ui.game.control.numpad.button.normal.background
        ).clipShape(
          RoundedRectangle(cornerRadius: 12)
        )
      }
    }
    .onAppear() {
      self.numberKeyVibrator.prepare()
    }
  }
}

struct NumbersPadButtonStyle: ButtonStyle {
  var isEnabled: Bool = true
  var isChecked: Bool = false
  
  private var currentColorScheme = StyleManager.current.colorScheme
  
  init(isEnabled: Bool, isChecked: Bool) {
    self.isEnabled = isEnabled
    self.isChecked = isChecked
  }
  
  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(.custom(TheTheme.Fonts.mono, size: 22))
      .frame(width: 56, height: 56)
      .background(
        Color(
          self.isChecked
            ? self.currentColorScheme.ui.game.control.numpad.button.selected.background
            : self.currentColorScheme.ui.game.control.numpad.button.normal.background
        )
      )
      .foregroundStyle(
        Color(
          self.isChecked
            ? self.currentColorScheme.ui.game.control.numpad.button.selected.text
            : self.currentColorScheme.ui.game.control.numpad.button.normal.text
        )
      )
      .opacity(self.isEnabled ? 1 : 0.3)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .scaleEffect(configuration.isPressed ? 0.9 : 1)
      .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
  }
}


struct NumbersPadPreview: PreviewProvider {
  struct Content: View {
    private let sceneSize = CGSize(width: 250, height: 250)
    private let currentColorScheme = StyleManager.current.colorScheme
    
    @StateObject var dataProvider = AppDataProvider.shared
    @State var ready: Bool = false
    
    init() {
      StyleManager.current.switchColorScheme(to: .darkGreen)
    }
    
    var body: some View {
      ZStack {
        Color(currentColorScheme.ui.game.background).onAppear {
          Task {
            try! await DataManager.default.saveGamesService.createNewSaveGame(
              difficulty: .easy
            )
            
            self.ready = true
          }
        }.ignoresSafeArea()
        
        if ready {
          VStack {
            let gameScene = MobileGameScene(size: sceneSize)

            NotesModeToggleButton(
              game: gameScene.game,
              cursorState: gameScene.cursorState
            )
            
            NumbersPad(
              gameScene: gameScene,
              game: gameScene.game,
              puzzle: gameScene.game.puzzle,
              cursorState: gameScene.cursorState
            )
          }.padding()
        } else {
          Text("Scene not ready!")
        }
      }
      .environment(\.managedObjectContext, dataProvider.container.viewContext)
    }
  }
  
  static var previews: some View {
    return Content()
  }
}

