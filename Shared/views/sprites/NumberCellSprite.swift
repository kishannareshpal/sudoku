//
//  NumberCellSprite.swift
//  sudoku
//
//  Created by Kishan Jadav on 08/01/2023.
//

import SwiftUICore
import SpriteKit
import UIColorHexSwift

class NumberCellSprite: SKSpriteNode, ObservableObject {
  private let currentColorScheme = StyleManager.current.colorScheme
  
  static let NUMBER_VALUE_CHANGING_AMOUNT = 0.1
  static let NOTE_VALUE_CHANGING_AMOUNT = 0.1
  
  private let numberLabelNode = SKLabelNode(fontNamed: TheTheme.Fonts.mono)
  private(set) var notesNode = SKNode()
  private let invalidNumberShapeNode = SKShapeNode()

  private(set) var notes: [NumberCellNoteSprite] = []

  private(set) var isStatic: Bool
  private(set) var location: Location
  private(set) var highlighted: Bool = false
  
  private(set) var value: Int = 0
  private(set) var valid: Bool = true

  private var draftNumberValue: Double = 0.0
  private var draftNoteValue: Double = 0.0
  
  var numberValueToBeCommitted: Int {
    return round(self.draftNumberValue).toInt()
  }
  
  var noteValueToBeCommitted: Int {
    return round(self.draftNoteValue).toInt()
  }

  var isChangeable: Bool {
    return !self.isStatic
  }
  
  /// Whether or not a note can be added or removed from this cell
  /// - Can only add notes to a changeable cell and when it has no value on it
  var isNotable: Bool {
    return self.isValueEmpty
  }

  var isEraseable: Bool {
    return !self.isStatic && !(self.isValueEmpty && self.isNotesEmpty)
  }

  var isValueEmpty: Bool {
    return self.value.isEmpty
  }

  var isNotesEmpty: Bool {
    return self.notes.isEmpty
  }
  
  init(
    size: CGSize,
    location: Location,
    value: Int,
    isStatic: Bool
  ) {
    self.value = value
    self.isStatic = isStatic
    self.location = location
    
    if (!self.isStatic) {
      self.draftNumberValue = value.toDouble()
    }

    super.init(
      texture: nil,
      color: self.currentColorScheme.board.cell.background.number.normal,
      size: size
    )
    
    // Use the cell's location notation as the name for easy identification
    self.name = location.notation
    self.draw()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func move(to position: CGPoint) {
    self.position = position
  }
  
  func changeDraftNumberValue(to value: Double) -> Void {
    guard self.isChangeable else { return }
    
    self.draftNumberValue = value
    
    // Clamp the value to 0 through 9:
    if (self.draftNumberValue > 9) {
      self.draftNumberValue = 9.0
      
    } else if (self.draftNumberValue <= 0) {
      self.draftNumberValue = 0.0
    }
    
    // Only show the notes when changing to a non-empty value
    self.toggleNotesVisibility(visible: self.draftNumberValue.isEmpty)

    self.updateLabelText(with: self.numberValueToBeCommitted)
  }

  func changeDraftNumberValue(direction: Direction) -> Void {
    guard self.isChangeable else { return }
    
    if direction == .forward {
      self.draftNumberValue += NumberCellSprite.NUMBER_VALUE_CHANGING_AMOUNT
    } else {
      self.draftNumberValue -= NumberCellSprite.NUMBER_VALUE_CHANGING_AMOUNT
    }
    
    // Clamp the value to 0 through 9:
    if (self.draftNumberValue > 9) {
      self.draftNumberValue = 9.0
      
    } else if (self.draftNumberValue <= 0) {
      self.draftNumberValue = 0.0
    }

    // Only show the notes when changing to a non-empty value
    self.toggleNotesVisibility(visible: self.draftNumberValue.isEmpty)

    self.updateLabelText(with: self.numberValueToBeCommitted)
  }
  
  func toggleNotesVisibility(visible: Bool) -> Void {
    if visible {
      self.notesNode.run(SKAction.fadeIn(withDuration: 0.1))
    } else {
      self.notesNode.run(SKAction.fadeOut(withDuration: 0.1))
    }
  }
  
  func clearNotes() -> Void {
    self.notes.removeAll()
    self.notesNode.removeAllChildren()
  }
  
  func toggleNotes(values: [Int], forceVisible: Bool? = nil, animate: Bool = true) -> Void {
    values.forEach { value in
      self.toggleNote(value: value, forceVisible: forceVisible, animate: animate)
    }
  }
  
  func toggleNote(value: Int, forceVisible: Bool? = nil, animate: Bool = true) -> Void {
    let existingNote = self.notes.first { record in
      record.value == value
    }

    if let existingNote {
      // Already visible...

      if (forceVisible == true) {
        // And forced to be visible, so no need to do anything.
        return;
      }
      
      // Hide the note
      existingNote.toggleVisibility(visible: false, animated: animate)
      existingNote.removeFromParent()
      
      self.notes.removeAll { record in
        record.value == value
      }

    } else {
      // Already hidden...

      if (forceVisible == false) {
        // And forced to hide, so no need to do anything.
        return;
      }
      
      // Show the note
      let noteSprite = NumberCellNoteSprite(containerSize: size, value: value)
      self.notes.append(noteSprite)
      self.notesNode.addChild(noteSprite)
      noteSprite.toggleVisibility(visible: true, animated: animate)
    }
  }
  
  func changeDraftNoteValue(to value: Double) -> Void {
    guard self.isChangeable else { return }
    
    self.draftNoteValue = value
    
    // Clamp the note value to 0 through 9:
    if (self.draftNoteValue > 9) {
      self.draftNoteValue = 9.0
      
    } else if (self.draftNoteValue <= 0) {
      self.draftNoteValue = 0.0
    }
  }
  
  func changeDraftNoteValue(direction: Direction) {
    guard self.isChangeable else { return }

    if direction == .forward {
      self.draftNoteValue += NumberCellSprite.NOTE_VALUE_CHANGING_AMOUNT
    } else {
      self.draftNoteValue -= NumberCellSprite.NOTE_VALUE_CHANGING_AMOUNT
    }
    
    // Clamp the number value to 0 through 9:
    if (self.draftNoteValue > 9) {
      self.draftNoteValue = 9.0
      
    } else if (self.draftNoteValue <= 0) {
      self.draftNoteValue = 0.0
    }
  }
  
  func discardDraftNumberValueChange() -> Void {
    self.draftNumberValue = self.value.toDouble()
    self.updateLabelText(with: self.value)

    // Only show the notes when the cell value is empty
    self.toggleNotesVisibility(visible: self.value.isEmpty)
  }
  
  func commitValueChange() -> Void {
    self.value = self.numberValueToBeCommitted
    self.updateLabelText(with: self.value)
  }
  
  func resetValidation() {
    // The same as a valid cell
    self.toggleValidation(valid: true)
  }
  
  func toggleValidation(valid: Bool, valueCleared: Bool = false) {
    guard self.isChangeable else { return }
    
    if (valid) {
      self.numberLabelNode.fontColor = self.currentColorScheme.board.cell.text.player.valid
    } else {
      self.numberLabelNode.fontColor = self.currentColorScheme.board.cell.text.player.invalid
    }
    
    self.invalidNumberShapeNode.isHidden = valueCleared || valid
    self.valid = valid
  }
  
  func toggleHighlighForNotes(with value: Int) {
    self.notes.forEach {
      if $0.value == value {
        $0.highlight()
      } else {
        $0.unhighlight()
      }
    }
  }
  
  func highlight() {
    guard !self.highlighted else { return }
    
    self.color = self.currentColorScheme.board.cell.background.number.highlighted
    self.highlighted = true;
  }
  
  func unhighlight() {
    guard self.highlighted else { return }
    
    self.color = self.currentColorScheme.board.cell.background.number.normal
    self.highlighted = false
  }

  private func draw() {
    self.updateLabelText(with: self.value)

    // Draw the number label
    self.numberLabelNode.fontColor = self.isStatic
      ? self.currentColorScheme.board.cell.text.given
      : self.currentColorScheme.board.cell.text.player.valid

    self.numberLabelNode.fontSize = self.size.width * 0.65
    self.numberLabelNode.numberOfLines = 1
    self.numberLabelNode.verticalAlignmentMode = .center
    self.numberLabelNode.horizontalAlignmentMode = .center
    self.numberLabelNode.zPosition = ZIndex.Cell.numberText
    self.addChild(self.numberLabelNode)
    
    // Create a path from the bottom-left to the top-right corner
    let forwardDiagonalLinePath = CGMutablePath()
    let invalidNumberShapePadding: CGFloat = 6.0
    let bottomLeftPoint = CGPoint(
      x: -self.size.width.half() + invalidNumberShapePadding,
      y: -self.size.height.half() + invalidNumberShapePadding
    )
    let topRightPoint = CGPoint(
      x: self.size.width.half() - invalidNumberShapePadding,
      y: self.size.height.half() - invalidNumberShapePadding
    )
    forwardDiagonalLinePath.move(to: bottomLeftPoint)
    forwardDiagonalLinePath.addLine(to: topRightPoint)

    self.invalidNumberShapeNode.path = forwardDiagonalLinePath
    self.invalidNumberShapeNode.isUserInteractionEnabled = false
    self.invalidNumberShapeNode.lineWidth = 4.0
    self.invalidNumberShapeNode.strokeColor = self.currentColorScheme.board.cell.text.player.invalid
    self.invalidNumberShapeNode.alpha = 0.3
    self.invalidNumberShapeNode.zPosition = ZIndex.Cell.invalidNumberShape
    self.invalidNumberShapeNode.isHidden = true
    self.invalidNumberShapeNode.isAntialiased = true
    self.addChild(invalidNumberShapeNode)
    
    // Draw the notes holding node
    self.notesNode.zPosition = ZIndex.Cell.noteText
    self.addChild(self.notesNode)
  }
  
  private func updateLabelText(with value: Int) {
    self.numberLabelNode.text = value.isNotEmpty ? value.toString() : ""

    let scale = SKAction.sequence([
      SKAction.scale(to: 1.3, duration: 0.1),
      SKAction.scale(to: 1.0, duration: 0.1)
    ])
    self.numberLabelNode.run(scale)
  }
}
