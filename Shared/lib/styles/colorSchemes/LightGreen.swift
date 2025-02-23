//
//  LightGreenColorScheme.swift
//  sudoku
//
//  Created by Kishan Jadav on 05/02/2025.
//

import Foundation
import UIKit.UIColor
import UIColorHexSwift

extension ColorScheme {
  static let lightGreen = ColorScheme(
    mode: .light,
    name: .lightGreen,
    board: .init(
      background: UIColor("#ffffff"),
      stroke: .init(
        inner: UIColor("#000000"),
        outer: UIColor("#000000")
      ),
      cell: .init(
        background: .init(
          number: .init(
            normal: UIColor("#ffffff"),
            highlighted: UIColor("#c0ffc0")
          ),
          cursor: UIColor("#4dff4d"),
          note: .init(
            highlighted: UIColor("#03a700")
          )
        ),
        stroke: .init(
          cursor: UIColor("#000000")
        ),
        text: .init(
          given: UIColor("#000000"),
          player: .init(
            valid: UIColor("#028700"),
            invalid: UIColor("#ff0000")
          ),
          note: .init(
            normal: UIColor("#000000"),
            highlighted: UIColor("#ffffff")
          )
        )
      )
    ),
    ui: .init(
      game: .init(
        background: UIColor("#f3f3f6"),
        nav: .init(
          text: UIColor("#000000")
        ),
        pauseText: UIColor("#000000"),
        control: .init(
          numpad: .init(
            button: .init(
              normal: .init(
                background: UIColor("#222222"),
                text: UIColor("#FFFFFF")
              ),
              selected: .init(
                background: UIColor("#03A700"),
                text: UIColor("#FFFFFF")
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
                background: UIColor("#03a700"),
                text: UIColor("#ffffff")
              )
            )
          )
        )
      )
    )
  )
}
