//
//  DarkGreenColorScheme.swift
//  sudoku
//
//  Created by Kishan Jadav on 05/02/2025.
//

import Foundation
import UIKit.UIColor
import UIColorHexSwift

extension ColorScheme {
  static let darkGreen = ColorScheme(
    mode: .dark,
    name: .darkGreen,
    board: .init(
      background: UIColor("#000000"),
      stroke: .init(
        inner: UIColor("#0e4600"),
        outer: UIColor("#0e4600")
      ),
      cell: .init(
        background: .init(
          number: .init(
            normal: UIColor("#000000"),
            highlighted: UIColor("#002c09")
          ),
          cursor: UIColor("#043b0f"),
          note: .init(
            highlighted: UIColor("#43ff69")
          )
        ),
        stroke: .init(
          cursor: UIColor("#43ff69")
        ),
        text: .init(
          given: UIColor("#ffffff"),
          player: .init(
            valid: UIColor("#43ff69"),
            invalid: UIColor("#ff0000")
          ),
          note: .init(
            normal: UIColor("#ffffff"),
            highlighted: UIColor("#000000")
          )
        )
      )
    ),
    ui: .init(
      game: .init(
        background: UIColor("#000000"),
        nav: .init(
          text: UIColor("#ffffff")
        ),
        pauseText: UIColor("#FFFFFF"),
        control: .init(
          numpad: .init(
            button: .init(
              normal: .init(
                background: UIColor("#222222"),
                text: UIColor("#FFFFFF")
              ),
              selected: .init(
                background: UIColor("#43FF69"),
                text: UIColor("#000000")
              )
            )
          ),
          mode: .init(
            background: UIColor("#222222"),
            option: .init(
              normal: .init(
                background: UIColor("#222222"),
                text: UIColor("#FFFFFF")
              ),
              selected: .init(
                background: UIColor("#43ff69"),
                text: UIColor("#000000")
              )
            )
          )
        )
      )
    )
  )
}
