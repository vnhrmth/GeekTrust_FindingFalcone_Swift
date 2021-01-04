//
//  ColorHelper.swift
//  FindingFalcone
//
//  Created by Vinay Hiremath on 03/01/21.
//

import Foundation
import UIKit
import QuartzCore

struct ColorHelper {
    let colorTop = UIColor(red: 192.0/255.0, green: 38.0/255.0, blue: 42.0/255.0, alpha: 1.0)
    let colorBottom = UIColor(red: 35.0/255.0, green: 2.0/255.0, blue: 2.0/255.0, alpha: 1.0)

    let gl: CAGradientLayer

    init() {
      gl = CAGradientLayer()
      gl.colors = [ colorTop, colorBottom]
      gl.locations = [ 0.0, 1.0]
    }
}
