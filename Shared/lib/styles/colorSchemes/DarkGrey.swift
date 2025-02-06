//
//  DarkGreyColorScheme.swift
//  sudoku
//
//  Created by Kishan Jadav on 05/02/2025.
//

import Foundation
import UIKit.UIColor
import UIColorHexSwift

extension ColorScheme {
  static let darkGrey = ColorScheme(
    name: .darkGrey,
    board: .init(
      background: UIColor("#000000"),
      stroke: .init(
        inner: UIColor("#656565"),
        outer: UIColor("#656565")
      ),
      cell: .init(
        background: .init(
          number: .init(
            normal: UIColor("#000000"),
            highlighted: UIColor("#393939")
          ),
          cursor: UIColor("#2e2e2e"),
          note: .init(
            highlighted: UIColor("#ffffff")
          )
        ),
        stroke: .init(
          cursor: UIColor("#d7d7d7")
        ),
        text: .init(
          given: UIColor("#ffffff"),
          player: .init(
            valid: UIColor("#828282"),
            invalid: UIColor("#ff3d3d")
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
                background: UIColor("#FFFFFF"),
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
                background: UIColor("#ffffff"),
                text: UIColor("#000000")
              )
            )
          )
        )
      )
    )
  )
}
