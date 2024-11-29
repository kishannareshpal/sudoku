//
//  ButtonSprite.swift
//  sudoku
//
//  Created by Kishan Jadav on 25/08/2024.
//

import WatchKit
import SpriteKit

@available(*, deprecated, message: "No longer needed. Superseeded by watchOS native controls instead.")
class IconSprite: SKSpriteNode {
  convenience init(
    position: CGPoint,
    symbolName: String,
    size: CGFloat,
    color: SKColor = .white
  ) {
    let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: size)
    let symbol = UIImage(systemName: symbolName)!.applyingSymbolConfiguration(
      symbolConfiguration
    )!
    
    let rect = CGRect(
      origin: .zero,
      size: symbol.size
    )
    
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
    
    color.setFill()
    UIRectFill(rect)
    
    let ctx = UIGraphicsGetCurrentContext()
    ctx?.setBlendMode(.destinationIn)
    ctx?.draw(symbol.cgImage!, in: rect)
    
    let image = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    let texture = SKTexture(image: image)
    self.init(texture: texture)
    
    self.position = CGPoint(x: position.x + size, y: position.y)
    self.zPosition = 100.0
  }
  
  func toggleVisibility(hidden: Bool) {
    self.isHidden = hidden
  }
}
