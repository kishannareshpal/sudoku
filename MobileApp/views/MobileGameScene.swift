//
//  MobileGameScene.swift
//  sudoku
//
//  Created by Kishan Jadav on 08/01/2025.
//

import SwiftUI
import SpriteKit
import UIKit

class MobileGameScene: GameScene {
  var id = UUID()
  
  @Published private(set) var cursorState: CursorState = .init()
  
  private var lastCursorLocation: Location = .zero
  private let cellSelectionVibrator = UIImpactFeedbackGenerator(style: .light)
  
  private var validNumberKeys = "1"..."9"
  
  override init(size: CGSize) {
    super.init(size: size)

    self.cellSelectionVibrator.prepare()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func sceneDidLoad() {
    super.sceneDidLoad()
    
    // Activate the initial cell on load
    self.game.moveCursor(
      to: self.game.cursorLocation,
      activateCellImmediately: true
    )
    
    self.lastCursorLocation = self.game.cursorLocation
  }

  // MARK: - Touch events

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let touchPosition = touch.location(in: self)
    
    self.registerCursorChange(whenTouchedOrHoveredAt: touchPosition)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touch = touches.first else { return }
    let touchPosition = touch.location(in: self)
    
    self.registerCursorChange(
      whenTouchedOrHoveredAt: touchPosition,
      forceChange: true
    )
  }
  
  /// To use this, setup .onContinuousHover(coordinateSpace: .local, perform: self.gameScene.onHovered) to the SpriteView element in GameSceneView.
  @available(iOS 16.0, *)
  func onHovered(phase: HoverPhase) {
    if self.isPaused { return }
    guard view != nil else { return }
    
    switch phase {
    case .active(let rawLocation):
      let hoverPosition = convertPoint(fromView: rawLocation)

      self.registerCursorChange(
        whenTouchedOrHoveredAt: hoverPosition
      )
    case .ended: break
    }
  }
  
  @available(iOS 17.0, *)
  func keyPressed(_ keyPress: KeyPress) -> KeyPress.Result {
    // Enter a number or a note
    if self.isNumberKey(keyPress.characters) {
      let number = Int(keyPress.characters)!
      
      if keyPress.modifiers == .shift && self.cursorState.mode == .number {
        // SHIFT + <NUM>
        // If in numbers mode, and the user is holding the Shift key, insert a note instead.
        self.toggleActivatedNumberCellNoteValue(with: number)
      } else {
        // Otherwise, insert a note or value based on whatever mode the user is currently on
        self.changeOrToggleActivatedNumberCellValueOrNote(with: number)
      }
      
      return .handled
    }
    
    // Clear
    if (
      keyPress.key == .delete
      || keyPress.key == .delete
      || keyPress.key == .clear
      || keyPress.characters == "0"
    ) {
      self.clearActivatedNumberCellValueAndNotes()
      return .handled
    }
    
    // Hint
    if keyPress.characters == "h" {
      self.game.solveActivatedNumberCell()
      return .handled
    }
    
    // Undo / Redo
    if keyPress.characters == "z" || keyPress.characters == "y" {
      switch keyPress.characters {
      case "z":
        if (
          keyPress.modifiers == .command
            || keyPress.modifiers == .control
        ) {
          // CMD/CTRL + SHIFT + Z
          // Redo
          self.game.redoLastMove()
        } else {
          // CMD/CTRL + Z
          // Undo
          self.game.undoLastMove()
        }
        
      case "y":
        // Not a standard in Apple ecosystem as it prefers CMD+SHIFT+Z instead.
        // However it is a standard in the Windows ecosystem, so just for fun
        if (
          keyPress.modifiers == .command
            || keyPress.modifiers == .control
        ) {
          // CMD/CTRL + Y
          // Redo
          self.game.redoLastMove()
        }
        
      default:
        break
      }
      return .handled
    }
    
    // Cursor movement
    if (
      keyPress.key == .upArrow
        || keyPress.key == .downArrow
        || keyPress.key == .leftArrow
        || keyPress.key == .rightArrow
        || keyPress.characters == "w"
        || keyPress.characters == "a"
        || keyPress.characters == "s"
        || keyPress.characters == "d"
    ) {
      switch keyPress.characters {
      case "w":
        self.game.cursorLocation.moveUp(wrap: true)
        break
      case "a":
        self.game.cursorLocation.moveLeft(wrap: true)
        break
      case "s":
        self.game.cursorLocation.moveDown(wrap: true)
        break
      case "d":
        self.game.cursorLocation.moveRight(wrap: true)
        break
      default:
        break
      }
      
      switch keyPress.key {
      case .downArrow:
        self.game.cursorLocation.moveDown(wrap: true)
        break
      case .upArrow:
        self.game.cursorLocation.moveUp(wrap: true)
        break
      case .rightArrow:
        self.game.cursorLocation.moveRight(wrap: true)
        break
      case .leftArrow:
        self.game.cursorLocation.moveLeft(wrap: true)
        break
      default:
        break
      }
      
      self.game.moveCursor(
        to: self.game.cursorLocation,
        activateCellImmediately: true
      )
      return .handled
    }
    
    // Toggle cursor mode
    if keyPress.key == .space || keyPress.key == .return {
      self.cursorState.toggleMode()
      return .handled
    }
    
    return .ignored
  }
  
  func changeOrToggleActivatedNumberCellValueOrNote(with number: Int) {
    if self.cursorState.mode == .note {
      self.toggleActivatedNumberCellNoteValue(with: number)
    } else {
      self.changeActivatedNumberCellValue(to: number)
    }
  }
  
  /// Register a cursor movement based on a point.
  ///
  /// - Parameters:
  ///   - position: The point to move the cursor to as it will determine the cell to select underneath it.
  ///   - forceChange: Whether or not to treat this as a change, regardless of selecting the same cell.
  ///                  If set to false, selecting the same cell will not have any side-effects like vibration.
  ///                  Default: nil – meaning: Does not force by default.
  private func registerCursorChange(
    whenTouchedOrHoveredAt touchOrHoverPosition: CGPoint,
    forceChange: Bool? = nil
  ) -> Void {
    let potentialNumberCellLocation = self.getNumberCellLocationAt(touchOrHoverPosition)
    
    guard let cellLocation = potentialNumberCellLocation else {
      return
    }

    let hasCursorLocationChanged = cellLocation != self.lastCursorLocation
    if !hasCursorLocationChanged && forceChange != true {
      return
    }

    self.game.moveCursor(
      to: cellLocation,
      activateCellImmediately: true
    )

    self.lastCursorLocation = cellLocation
    if forceChange != false {
      self.onCursorLocationChanged()
    }
  }
  
  private func getNumberCellLocationAt(_ position: CGPoint) -> Location? {
    let nodesAtTouchLocation = self.nodes(at: position)
    for node in nodesAtTouchLocation {
      guard let nodeName = node.name else { continue }
      guard Location.validateNotationFormat(nodeName) else { continue }
      
      return Location(notation: nodeName)
    }

    return nil
  }
  
  private func onCursorLocationChanged() {
    cellSelectionVibrator.impactOccurred()
  }
  
  private func isNumberKey(_ key: String) -> Bool {
    return validNumberKeys.contains(key)
  }
}
