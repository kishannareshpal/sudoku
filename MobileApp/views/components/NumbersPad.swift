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
  
  var body: some View {
    NumbersPadContent(
      gameScene: self.gameScene,
      cursorState: self.gameScene.cursorState,
      gameState: self.gameScene.game.state,
      activeCursorState: self.gameScene.game.activeCursorState
    )
  }
}

private struct NumbersPadContent: View {
  private let numberKeyVibrator = UIImpactFeedbackGenerator(style: .medium)
  private let currentColorScheme = StyleManager.current.colorScheme
  
  var gameScene: MobileGameScene
  @ObservedObject var cursorState: CursorState
  @ObservedObject var gameState: GameState
  @ObservedObject var activeCursorState: ActiveCursorState
  
  @AppStorage(
    UserDefaultKey.useGridNumberPadStyle.rawValue
  ) private var useGridNumberPadStyle: Bool = true
  
  private func onNumberKeyPress(_ number: Int) {
    self.numberKeyVibrator.impactOccurred()
    self.gameScene.changeOrToggleActivatedNumberCellValueOrNote(
      with: number
    )
  }
  
  var isPressable: Bool {
    if self.gameState.isGamePaused || self.gameState.isGameOver {
      return false
    }
    
    if (self.cursorState.mode == .note) {
      return self.activeCursorState.numberCell?.isNotable ?? false
    } else {
      return self.activeCursorState.numberCell?.isChangeable ?? false
    }
  }
  
  var body: some View {
    Group {    
      if (useGridNumberPadStyle) {
        ThreeByThreeNumberPadGrid(
          isPressable: self.isPressable,
          cursorState: self.cursorState,
          gameScene: self.gameScene,
          onNumberKeyPress: self.onNumberKeyPress
        )
      } else {
        FiveByTwoNumberPadGrid(
          isPressable: self.isPressable,
          cursorState: self.cursorState,
          gameScene: self.gameScene,
          onNumberKeyPress: self.onNumberKeyPress
        )
      }
    }
    .background {
      if self.cursorState.mode == .note {
        Color(
          self.currentColorScheme.ui.game.control.numpad.button.normal.background
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

// Build a 9x9 grid of numbers:
// - Starting from 123 at the top,
//   then 456 in the middle,
//   and lastly 789 at the bottom.
private struct ThreeByThreeNumberPadGrid: View {
  var isPressable: Bool
  var cursorState: CursorState
  var gameScene: MobileGameScene
  var onNumberKeyPress: (Int) -> Void
  
  var body: some View {
    VStack(spacing: 8) {
      ForEach(0..<3) { row in
        HStack(spacing: 8) {
          ForEach(1...3, id: \.self) { column in
            let number = column + row * 3
            
            NumberPadButton(
              number: number,
              isPressable: self.isPressable,
              cursorStateMode: self.cursorState.mode,
              game: self.gameScene.game,
              puzzle: self.gameScene.game.puzzle
            ) {
              self.onNumberKeyPress(number)
            }
          }
        }
      }
    }
    .padding(8)
  }
}

private struct FiveByTwoNumberPadGrid: View {
  var isPressable: Bool
  var cursorState: CursorState
  var gameScene: MobileGameScene
  var onNumberKeyPress: (Int) -> Void
  
  var body: some View {
    VStack {
      ForEach(0..<2) { row in
        HStack(spacing: 8) {
          ForEach(0..<5) { column in
            let index = row * 5 + column
            
            if index < 9 {
              let number = index + 1
              NumberPadButton(
                number: number,
                isPressable: self.isPressable,
                cursorStateMode: self.cursorState.mode,
                game: self.gameScene.game,
                puzzle: self.gameScene.game.puzzle
              ) {
                self.onNumberKeyPress(number)
              }
            }
            //          else if index == 9 {
            //            // "Clear" button
            //          }
          }
        }
      }
    }
    .padding(8)
  }
}

private struct NumberPadButton: View {
  var number: Int
  var isPressable: Bool
  var cursorStateMode: CursorMode
  var game: Game
  @ObservedObject var puzzle: Puzzle

  var onPress: () -> Void

  var isNumberUsedUp: Bool {
    (self.puzzle.remainingNumbersWithCount[number] ?? 0) <= 0
  }
  
  var isNoteForNumberToggled: Bool {
    guard self.cursorStateMode == .note else {
      return false
    }
    
    return self.puzzle.isNoteToggled(value: self.number, at: self.game.cursorLocation)
  }
  
  var body: some View {
    Button("\(self.number)", action: self.onPress)
      .disabled(!self.isPressable || self.isNumberUsedUp)
      .buttonStyle(
        NumbersPadButtonStyle(
          isEnabled: self.isPressable && !self.isNumberUsedUp,
          isChecked: self.isNoteForNumberToggled
        )
      )
  }
}


private struct NumbersPadButtonStyle: ButtonStyle {
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


//struct NumbersPadPreview: PreviewProvider {
//  struct Content: View {
//    private let sceneSize = CGSize(width: 250, height: 250)
//    private let currentColorScheme = StyleManager.current.colorScheme
//    
//    @StateObject var dataProvider = AppDataProvider.shared
//    @State var ready: Bool = false
//    
//    init() {
//      StyleManager.current.switchColorScheme(to: .darkGreen)
//    }
//    
//    var body: some View {
//      ZStack {
//        Color(currentColorScheme.ui.game.background).onAppear {
//          Task {
//            try! await DataManager.default.saveGamesService.createNewSaveGame(
//              difficulty: .easy
//            )
//            
//            self.ready = true
//          }
//        }.ignoresSafeArea()
//        
//        if ready {
//          VStack {
//            let gameScene = MobileGameScene(size: sceneSize)
//
//            NotesModeToggleButton(
//              gameState: gameScene.game.state,
//              cursorState: gameScene.cursorState
//            )
//            
//            NumbersPad(
//              gameScene: gameScene,
//              game: gameScene.game,
//              gameState: gameScene.game.state,
//              puzzle: gameScene.game.puzzle,
//              cursorState: gameScene.cursorState
//            )
//          }.padding()
//        } else {
//          Text("Scene not ready!")
//        }
//      }
//      .environment(\.managedObjectContext, dataProvider.container.viewContext)
//    }
//  }
//  
//  static var previews: some View {
//    return Content()
//  }
//}

