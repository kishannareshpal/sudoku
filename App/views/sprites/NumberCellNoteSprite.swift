//
//  HintSprite.swift
//  sudoku
//
//  Created by Kishan Jadav on 31/08/2024.
//

import SpriteKit
import UIColorHexSwift

class NumberCellNoteSprite: SKShapeNode {
  let value: Int
  let containerSize: CGSize
  let size: CGSize
  
  private let gap: CGFloat = 1.4
  
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
  
  private lazy var color = {
    return NumberCellNoteSprite.color(for: self.value)
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
    self.draw()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func toggleVisibility(visible: Bool, animated: Bool = true) async {
    if visible {
      if animated {
        await self.animateAppearance()
      } else {
        self.instantApperance()
      }
    } else {
      if animated {
        await self.animateDisappearance()
      } else {
        self.instantDisappearance()
      }
    }
  }
  
  static func color(for value: Int) -> SKColor {
    switch value {
    case 1:
      return Theme.Cell.Number.Note.one
    case 2:
      return Theme.Cell.Number.Note.two
    case 3:
      return Theme.Cell.Number.Note.three
    case 4:
      return Theme.Cell.Number.Note.four
    case 5:
      return Theme.Cell.Number.Note.five
    case 6:
      return Theme.Cell.Number.Note.six
    case 7:
      return Theme.Cell.Number.Note.seven
    case 8:
      return Theme.Cell.Number.Note.eight
    case 9:
      return Theme.Cell.Number.Note.nine
    default:
      return .clear
    }
  }

  private func draw() {
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
    self.position = position(from: location)
    self.fillColor = self.color
    self.isAntialiased = true
    
    // Initially rendered hidden. Must call #toggleVisiblity to make it appear manually.
    self.instantDisappearance()
  }
  
  private func instantApperance() {
    self.alpha = 1
    self.setScale(1.0)
  }
  
  private func animateAppearance() async {
    let fadeIn = SKAction.fadeIn(withDuration: 0.2)
    let scale = SKAction.scale(to: 1.0, duration: 0.2)
    
    let animation = SKAction.group([
      fadeIn,
      scale
    ])
    animation.timingMode = .easeInEaseOut
    
    await self.run(animation)
  }
  
  private func animateDisappearance() async {
    let fadeOut = SKAction.fadeOut(withDuration: 0.2)
    let scale = SKAction.scale(to: 0, duration: 0.2)
    
    let animation = SKAction.group([
      fadeOut,
      scale
    ])
    animation.timingMode = .easeInEaseOut

    await self.run(animation)
  }
  
  private func instantDisappearance() {
    self.alpha = 0
    self.setScale(0.5)
  }
  
  private func position(from location: Location) -> CGPoint {
    let topLeft = CGPoint(
      x: -self.size.width,
      y: self.size.height
    )
    let x = topLeft.x - (topLeft.x * location.col.toCGFloat())
    let y = topLeft.y - (topLeft.y * location.row.toCGFloat())
    
    return CGPoint(x: x, y: y)
  }
}
