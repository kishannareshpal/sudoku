//
//  StyleManager.swift
//  sudoku
//
//  Created by Kishan Jadav on 26/01/2025.
//

import Foundation
import UIKit.UIColor
import UIColorHexSwift


class StyleManager: ObservableObject {
  @Published var shapeStyle: ShapeStyle
  @Published var colorScheme: ColorScheme
  
  static var current = StyleManager()
  
  private init() {
    // Load current color scheme, or use a default value
    let rememberedColorSchemeName = UserDefaults.standard.string(
      forKey: UserDefaultKey.colorSchemeName.rawValue
    )
    let colorSchemeName = ColorSchemeName(
      rawValue: rememberedColorSchemeName ?? ColorSchemeName.darkYellow.rawValue
    )!
    self.colorScheme = ColorScheme.with(name: colorSchemeName)

    // Load current shape style, or use a default value
    let rememberedShapeStyle = UserDefaults.standard.data(
      forKey: UserDefaultKey.shapeStyle.rawValue
    )
    if let rememberedShapeStyle {
      self.shapeStyle = (
        try? JSONDecoder().decode(
          ShapeStyle.self,
          from: rememberedShapeStyle
        )
      ) ?? ShapeStyle()
    } else {
      self.shapeStyle = ShapeStyle()
    }
  }
  
  func switchColorScheme(to colorSchemeName: ColorSchemeName) {
    self.colorScheme = ColorScheme.with(name: colorSchemeName)
    
    UserDefaults.standard.set(
      colorSchemeName.rawValue,
      forKey: UserDefaultKey.colorSchemeName.rawValue
    )
  }
  
  func update() {
    
  }
}
