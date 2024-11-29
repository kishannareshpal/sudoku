//
//  Theme.swift
//  sudoku
//
//  Created by Kishan Jadav on 24/08/2024.
//

import SwiftUICore
import UIKit.UIColor
import UIColorHexSwift

struct Theme {
  struct Colors {
    static let primary = UIColor("#F0B719")
    static let primaryDark = UIColor("#604806")
  }
  
  struct Fonts {
    static let emphasis: String = "SF Compact Rounded Bold"
    static let mono: String = "Spline Sans Mono Bold"
    static let minuscule: String = "Bell Centennial"
  }
  
  struct Difficulty {
    static let easy = Theme.Colors.primary
    static let medium = Theme.Colors.primary
    static let hard = Theme.Colors.primary
    static let veryHard = Theme.Colors.primary
    static let extreme = Theme.Colors.primary
    static let unknown = Theme.Colors.primary
  }
  
  struct Game {
    static let cancelText = UIColor("#F42B03")
  }
  
  struct Board {
    static let bg = UIColor.clear
    static let innerLines = UIColor("#352800")
    static let outerLines = UIColor("#3D2E00")
  }
  
  struct Cell {
    struct Number {
      static let bg = UIColor.clear
      
      struct Static {
        static let text = UIColor.white
      }
      
      struct Dynamic {
        static let text = UIColor("#FFD147")
        static let invalidText = UIColor("#FF7070")
      }
      
      struct Highlight {
        static let bg = UIColor("#221A00")
      }
      
      struct Note {
        static let toolbar = UIColor("#FFD147")
        
        static let one = UIColor("#ffe548")
        static let two = UIColor("#DF00FF")
        static let three = UIColor("#00f6ed")
        static let four = UIColor("#ef3054")
        static let five = UIColor("#fae7c2")
        static let six = UIColor("#f05d23")
        static let seven = UIColor("#2454FF")
        static let eight = UIColor("#0CF574")
        static let nine = UIColor("#FCF75E")
      }
    }
    
    struct Cursor {
      static let outline = Theme.Colors.primary
      static let outlineWidth = 2.0
      static let bg = UIColor.clear
    }
  }
}
