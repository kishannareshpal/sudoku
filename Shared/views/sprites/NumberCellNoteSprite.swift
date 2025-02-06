//
//  NumberCellsNoteSprite.swift
//  sudoku
//
//  Created by Kishan Jadav on 31/08/2024.
//

import SpriteKit
import UIColorHexSwift

class NumberCellNoteSprite: SKShapeNode {
  private let currentColorScheme = StyleManager.current.colorScheme
  
  let value: Int
  let containerSize: CGSize
  let size: CGSize
  
  private(set) var labelNode: SKLabelNode = SKLabelNode(fontNamed: TheTheme.Fonts.mono)
  private(set) var labelBackgroundNode: SKShapeNode = SKShapeNode()
  private(set) var highlighted: Bool = false

  private let gap: CGFloat = currentDevice == .appleWatch ? 1.4 : 0
  
  private lazy var roundedRectangleSize: CGSize = {
    return CGSize(
      width: self.size.width - self.gap,
      height: self.size.height - self.gap
    )
  }()
  
  private lazy var circleSize: CGSize = {
    return CGSize(
      width: self.size.width - self.gap,
      height: self.size.height - self.gap
    )
  }()
  
  
  private lazy var originPoint = {
    // This is the bottom left point, offset to allow for the gap if any
    return CGPoint(
      x: (-self.size.width.half() + self.gap.half()),
      y: (-self.size.height.half() + self.gap.half())
    )
  }()
  
  init(containerSize: CGSize, value: Int) {
    self.value = value
    self.containerSize = containerSize
    
    let colsCount = 3.0
    let rowsCount = 3.0
    
    self.size = CGSize(
      width: self.containerSize.width / colsCount,
      height: self.containerSize.height / rowsCount
    )
    
    super.init()
    
    if currentDevice == .appleWatch {
      self.drawAsShape()
    } else {
      self.drawAsText()
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func toggleVisibility(visible: Bool, animated: Bool = true) {
    if visible {
      if animated {
        self.animateAppearance()
      } else {
        self.instantApperance()
      }
    } else {
      if animated {
        self.animateDisappearance()
      } else {
        self.instantDisappearance()
      }
    }
  }
  
  static func color(for value: Int, with colorScheme: ColorScheme) -> SKColor {
    switch value {
    case 1:
      return colorScheme.board.cell.background.note.highlighted
    case 2:
      return colorScheme.board.cell.background.note.highlighted
    case 3:
      return colorScheme.board.cell.background.note.highlighted
    case 4:
      return colorScheme.board.cell.background.note.highlighted
    case 5:
      return colorScheme.board.cell.background.note.highlighted
    case 6:
      return colorScheme.board.cell.background.note.highlighted
    case 7:
      return colorScheme.board.cell.background.note.highlighted
    case 8:
      return colorScheme.board.cell.background.note.highlighted
    case 9:
      return colorScheme.board.cell.background.note.highlighted
    default:
      return .clear
    }
  }
  
  private func drawAsText() {
    self.updateLabelText(with: self.value)

    let locationIndex = value - 1
    let location = Location(
      index: locationIndex,
      orientation: .leftToRight,
      colsCount: 3,
      rowsCount: 3
    )
    
    let position = self.getPosition(from: location)
    
    self.labelBackgroundNode.path = CGPath(
      rect: CGRect(
        origin: self.originPoint,
        size: self.circleSize
      ),
      transform: .none
    )

    self.labelBackgroundNode.fillColor = self.currentColorScheme.board.cell.background.note.highlighted
    self.labelBackgroundNode.isAntialiased = true
    self.labelBackgroundNode.lineWidth = 0
    self.labelBackgroundNode.position = position
    self.labelBackgroundNode.zPosition = ZIndex.Cell.noteBackgroundShape
    self.labelBackgroundNode.isHidden = true

    self.labelNode.fontColor = self.currentColorScheme.board.cell.text.note.normal
    self.labelNode.position = position
    self.labelNode.fontSize = self.circleSize.width
    self.labelNode.numberOfLines = 1
    self.labelNode.verticalAlignmentMode = .center
    self.labelNode.horizontalAlignmentMode = .center
    self.labelNode.zPosition = ZIndex.Cell.noteText
    
    self.addChild(self.labelNode)
    self.addChild(self.labelBackgroundNode)
    
    // Initially rendered hidden. Must call #toggleVisiblity to make it appear manually.
    self.instantDisappearance()
  }
  
  private func updateLabelText(with value: Int) {
    self.labelNode.text = value.isNotEmpty ? value.toString() : ""
    
    let scale = SKAction.sequence([
      SKAction.scale(to: 1.3, duration: 0.1),
      SKAction.scale(to: 1.0, duration: 0.1)
    ])
    self.labelNode.run(scale)
  }
  
  func highlight() {
    guard !self.highlighted else { return }
    
    self.labelNode.fontColor = self.currentColorScheme.board.cell.text.note.highlighted
    print("highlighted: \(self.currentColorScheme.board.cell.text.note.highlighted)")
    
    self.highlighted = true;
    self.labelBackgroundNode.isHidden = false
  }
  
  func unhighlight() {
    guard self.highlighted else { return }
    
    self.labelNode.fontColor = self.currentColorScheme.board.cell.text.note.normal
    self.highlighted = false
    self.labelBackgroundNode.isHidden = true
  }
  
  private func drawAsShape() {
    self.path = UIBezierPath(
      ovalIn: CGRect(
        origin: self.originPoint,
        size: self.circleSize
      )
    ).cgPath
    
    let locationIndex = value - 1
    let location = Location(
      index: locationIndex,
      orientation: .leftToRight,
      colsCount: 3,
      rowsCount: 3
    )
    
    self.lineWidth = 0
    self.position = self.getPosition(from: location)
    self.fillColor = NumberCellNoteSprite.color(
      for: self.value,
      with: currentColorScheme
    )
    self.isAntialiased = true
    
    // Initially rendered hidden. Must call #toggleVisiblity to make it appear manually.
    self.instantDisappearance()
  }
  
  private func instantApperance() {
    self.alpha = 1
    self.setScale(1.0)
  }
  
  private func animateAppearance() {
    let fadeIn = SKAction.fadeIn(withDuration: 0.2)
    let scale = SKAction.scale(to: 1.0, duration: 0.2)
    
    let animation = SKAction.group([
      fadeIn,
      scale
    ])
    animation.timingMode = .easeInEaseOut
    
    self.run(animation)
  }
  
  private func animateDisappearance() {
    let fadeOut = SKAction.fadeOut(withDuration: 0.2)
    let scale = SKAction.scale(to: 0, duration: 0.2)
    
    let animation = SKAction.group([
      fadeOut,
      scale
    ])
    animation.timingMode = .easeInEaseOut
    
    self.run(animation)
  }
  
  private func instantDisappearance() {
    self.alpha = 0
    self.setScale(0.5)
  }
  
  private func getPosition(from location: Location) -> CGPoint {
    let topLeft = CGPoint(
      x: -self.size.width,
      y: self.size.height
    )
    let x = topLeft.x - (topLeft.x * location.col.toCGFloat())
    let y = topLeft.y - (topLeft.y * location.row.toCGFloat())
    
    return CGPoint(x: x, y: y)
  }
}
