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
    var gl:CAGradientLayer!
    var startColor = UIColor(red: 0, green: 0 , blue: 0, alpha: 1.0)
    var endColor = UIColor(red: 0, green: 0 , blue: 0, alpha: 1.0)
    
    var skyColor:[UIColor:UIColor] = [UIColor(red: 0, green: 0 , blue: 0, alpha: 1.0):
                                      UIColor(red: 67/255, green: 67 / 255, blue: 67/255, alpha: 1.0)]
    
    init() {
        self.gl = CAGradientLayer()
        self.gl.colors = [startColor, endColor]
        self.gl.locations = [0.0, 1.0]
    }
}
