//
//  ControlButton.swift
//  sudoku
//
//  Created by Kishan Jadav on 08/01/2025.
//

import SwiftUI
import SpriteKit
import UIKit.UIColor
import UIColorHexSwift

struct NotesModeToggleButton: View {
  var gameScene: MobileGameScene
  
  var body: some View {
    NotesModeToggleButtonContent(
      cursorState: self.gameScene.cursorState,
      gameState: self.gameScene.game.state
    )
  }
}

struct NotesModeToggleButtonContent: View {
  private let vibrator = UIImpactFeedbackGenerator(style: .rigid)
  
  @ObservedObject var cursorState: CursorState
  @ObservedObject var gameState: GameState
  
  var isNotesModeToggleable: Bool {
    return !self.gameState.isGameOver && !self.gameState.isGamePaused
  }
  
  var body: some View {
    SegmentedPicker(
      selection: Binding(
        get: { cursorState.mode.rawValue },
        set: { newValue in
          withAnimation(.smooth) {
            self.cursorState.mode = CursorMode(rawValue: newValue) ?? .number
          }

          vibrator.impactOccurred()
        }
      ),
      options: ["Pen", "Notes"],
      isEnabled: self.isNotesModeToggleable
    )
    .scaledToFit()
    .frame(minWidth: 0)
    .apply { view in
      if #available(iOS 17.0, *) {
        view
          .focusable()
          .onKeyPress(keys: [.space, .return], phases: .down, action: { keyPress in
            withAnimation(.smooth) {
              self.cursorState.mode = self.cursorState.mode == .number ? .note : .number
            }
            return .handled
          })
          .focusEffectDisabled(!self.isNotesModeToggleable)
      } else {
        view
      }
    }
  }
}

struct SegmentedPicker: UIViewRepresentable {
  @Binding var selection: Int
  var options: [String]
  var isEnabled: Bool = true
  
  func makeUIView(context: Context) -> UISegmentedControl {
    let segmentedControl = UISegmentedControl(items: options)
    segmentedControl.selectedSegmentIndex = selection
    segmentedControl.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged), for: .valueChanged)
    
    // Apply custom appearance locally
    let normalAttributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: UIColor.gray
    ]
    let selectedAttributes: [NSAttributedString.Key: Any] = [
      .foregroundColor: UIColor.black,
      .font: UIFont.systemFont(ofSize: 14, weight: .bold)
    ]
    
    segmentedControl.setTitleTextAttributes(normalAttributes, for: .normal)
    segmentedControl.setTitleTextAttributes(selectedAttributes, for: .selected)
    
    segmentedControl.selectedSegmentTintColor = UIColor("#fff")
    segmentedControl.backgroundColor = UIColor("#141414")
    segmentedControl.isEnabled = isEnabled
    
    return segmentedControl
  }
  
  func updateUIView(_ uiView: UISegmentedControl, context: Context) {
    uiView.selectedSegmentIndex = selection
    uiView.isEnabled = isEnabled
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject {
    var parent: SegmentedPicker
    
    init(_ parent: SegmentedPicker) {
      self.parent = parent
    }
    
    @objc func valueChanged(_ sender: UISegmentedControl) {
      parent.selection = sender.selectedSegmentIndex
    }
  }
}
