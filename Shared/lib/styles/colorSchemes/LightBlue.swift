//
//  LightBlueColorScheme.swift
//  sudoku
//
//  Created by Kishan Jadav on 05/02/2025.
//

import Foundation
import UIKit.UIColor
import UIColorHexSwift

extension ColorScheme {
  static let lightBlue = ColorScheme(
    mode: .light,
    name: .lightBlue,
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
            highlighted: UIColor("#c0fbff")
          ),
          cursor: UIColor("#41d3ff"),
          note: .init(
            highlighted: UIColor("#002fff")
          )
        ),
        stroke: .init(
          cursor: UIColor("#000000")
        ),
        text: .init(
          given: UIColor("#000000"),
          player: .init(
            valid: UIColor("#002bea"),
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
                background: UIColor("#002FFF"),
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
                background: UIColor("#002fff"),
                text: UIColor("#ffffff")
              )
            )
          )
        )
      )
    )
  )
}
