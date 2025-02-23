//
//  DarkBlueColorScheme.swift
//  sudoku
//
//  Created by Kishan Jadav on 05/02/2025.
//

import Foundation
import UIKit.UIColor
import UIColorHexSwift

extension ColorScheme {
  static let darkBlue = ColorScheme(
    mode: .dark,
    name: .darkBlue,
    board: .init(
      background: UIColor("#000000"),
      stroke: .init(
        inner: UIColor("#003346"),
        outer: UIColor("#003346")
      ),
      cell: .init(
        background: .init(
          number: .init(
            normal: UIColor("#000000"),
            highlighted: UIColor("#00173a")
          ),
          cursor: UIColor("#00173a"),
          note: .init(
            highlighted: UIColor("#43b4ff")
          )
        ),
        stroke: .init(
          cursor: UIColor("#00b7ff")
        ),
        text: .init(
          given: UIColor("#ffffff"),
          player: .init(
            valid: UIColor("#43b4ff"),
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
                background: UIColor("#43b4ff"),
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
                background: UIColor("#43b4ff"),
                text: UIColor("#000000")
              )
            )
          )
        )
      )
    )
  )
}
