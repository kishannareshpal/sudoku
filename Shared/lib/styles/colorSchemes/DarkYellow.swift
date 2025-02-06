//
//  DarkYellowColorScheme.swift
//  sudoku
//
//  Created by Kishan Jadav on 05/02/2025.
//

import Foundation
import UIKit.UIColor
import UIColorHexSwift

extension ColorScheme {
  static let darkYellow = ColorScheme(
    name: .darkYellow,
    board: .init(
      background: UIColor("#000000"),
      stroke: .init(
        inner: UIColor("#3D2E00"),
        outer: UIColor("#3D2E00")
      ),
      cell: .init(
        background: .init(
          number: .init(
            normal: UIColor("#000000"),
            highlighted: UIColor("#221A00")
          ),
          cursor: UIColor("#221A00"),
          note: .init(
            highlighted: UIColor("#FFD147")
          )
        ),
        stroke: .init(
          cursor: UIColor("#F0B719")
        ),
        text: .init(
          given: UIColor("#FFFFFF"),
          player: .init(
            valid: UIColor("#FFD147"),
            invalid: UIColor("#FF7070")
          ),
          note: .init(
            normal: UIColor("#FFFFFF"),
            highlighted: UIColor("#000000")
          )
        )
      )
    ),
    ui: .init(
      game: .init(
        background: UIColor("#000000"),
        nav: .init(
          text: UIColor("#FFFFFF")
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
                background: UIColor("#FFD147"),
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
                background: UIColor("#FFD147"),
                text: UIColor("#000000")
              )
            )
          )
        )
      )
    )
  )
}
