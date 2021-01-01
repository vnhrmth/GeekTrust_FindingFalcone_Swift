//
//  TimeCalculator.swift
//  FindingFalcone
//
//  Created by Vinay Hiremath on 01/01/21.
//

import Foundation

struct TimeCalculator{
    func calculateTime(dict:[Planet:Vehicle])->Int{
        var time:Int = 0
        for val in dict{
            let planet = val.key
            let vehicle = val.value
            
            let distance = planet.distance
            let speed = vehicle.speed
            time += distance/speed
        }
        return time
    }
}
