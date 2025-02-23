//
//  Theme.swift
//  sudoku
//
//  Created by Kishan Jadav on 05/02/2025.
//

import Foundation
import UIKit

struct ColorScheme {
  var mode: ColorSchemeMode
  var name: ColorSchemeName
  var board: Board
  var ui: Ui
  
  struct Board {
    var background: UIColor
    var stroke: Stroke
    var cell: Cell
    
    struct Stroke {
      var inner: UIColor
      var outer: UIColor
    }
    
    struct Cell {
      var background: Background
      var stroke: Stroke
      var text: Text
      
      struct Background {
        var number: Number
        var cursor: UIColor
        var note: Note
        
        struct Number {
          var normal: UIColor
          var highlighted: UIColor
        }
        
        struct Note {
          var highlighted: UIColor
        }
      }
      
      struct Stroke {
        var cursor: UIColor
      }
      
      struct Text {
        var given: UIColor
        var player: Player
        var note: Note
        
        struct Player {
          var valid: UIColor
          var invalid: UIColor
        }
        
        struct Note {
          var normal: UIColor
          var highlighted: UIColor
        }
      }
    }
  }
  
  struct Ui {
    var game: Game
    
    struct Game {
      var background: UIColor
      var nav: Nav
      var pauseText: UIColor
      var control: Control
      
      struct Nav {
        var text: UIColor
      }
      
      struct Control {
        var numpad: Numpad
        var mode: Mode
        
        struct Numpad {
          var button: Button
          
          struct Button {
            var normal: Normal
            var selected: Selected
            
            struct Normal {
              var background: UIColor
              var text: UIColor
            }
            
            struct Selected {
              var background: UIColor
              var text: UIColor
            }
          }
        }
        
        struct Mode {
          var background: UIColor
          var option: Option
          
          struct Option {
            var normal: Normal
            var selected: Selected
            
            struct Normal {
              var background: UIColor
              var text: UIColor
            }
            
            struct Selected {
              var background: UIColor
              var text: UIColor
            }
          }
        }
      }
    }
  }
}

extension ColorScheme {
  static func with(name: ColorSchemeName) -> ColorScheme {
    switch (name) {
    case .darkYellow:
      return ColorScheme.darkYellow
    case .darkBlue:
      return ColorScheme.darkBlue
    case .darkGreen:
      return ColorScheme.darkGreen
    case .darkGrey:
      return ColorScheme.darkGrey
    case .lightYellow:
      return ColorScheme.lightYellow
    case .lightBlue:
      return ColorScheme.lightBlue
    case .lightGreen:
      return ColorScheme.lightGreen
    case .lightGrey:
      return ColorScheme.lightGrey
    }
  }
}
