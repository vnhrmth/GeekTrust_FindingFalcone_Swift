//
//  Vehicles.swift
//  FindingFalcone
//
//  Created by Vinay Hiremath on 29/12/20.
//

import Foundation

struct Api {
    let getPlanetsUrl = "https://findfalcone.herokuapp.com/planets"
    let getVehiclesUrl = "https://findfalcone.herokuapp.com/vehicles"
    let findFalconeUrl = "https://findfalcone.herokuapp.com/find"
    let getTokenUrl = "https://findfalcone.herokuapp.com/token"
}

struct Planet: Codable,Hashable {
    let name: String
    let distance: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

typealias Planets = [Planet]

class Vehicle: Codable {
    var name: String
    var totalNo : Int
    var maxDistance, speed: Int

    enum CodingKeys: String, CodingKey {
        case name
        case totalNo = "total_no"
        case maxDistance = "max_distance"
        case speed
    }
}

typealias Vehicles = [Vehicle]

struct PathFinder: Codable {
    let token: String
    let planetNames, vehicleNames: [String]

    enum CodingKeys: String, CodingKey {
        case token
        case planetNames = "planet_names"
        case vehicleNames = "vehicle_names"
    }
}

struct TokenModel: Codable {
    let token: String
}

struct FindFalconeStatus: Codable {
    let planetName, status: String

    enum CodingKeys: String, CodingKey {
        case planetName = "planet_name"
        case status
    }
}

struct Status: Codable {
    let status: String
}


