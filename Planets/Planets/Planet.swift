//
//  Planets.swift
//  Planets
//
//  Created by Matthew Harding on 1/22/18.
//  Copyright © 2018 Matt Harding. All rights reserved.
//

import Foundation
import UIKit

enum Planet {
    case Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptune

    func name() -> String {
        switch self {
        case .Mercury:
            return "Mercury"
        case .Venus:
            return "Venus"
        case .Earth:
            return "Earth"
        case .Mars:
            return "Mars"
        case .Jupiter:
            return "Jupiter"
        case .Saturn:
            return "Saturn"
        case .Uranus:
            return "Uranus"
        case .Neptune:
            return "Neptune"
        }
    }

    func image() -> UIImage? {
        return UIImage.init(named: imagename())
    }

    func imagename() -> String {
        switch self {
        case .Mercury:
            return "2k_mercury.jpg"
        case .Venus:
            return "2k_venus_atmosphere.jpg"
        case .Earth:
            return "2k_earth_daymap.jpg"
        case .Mars:
            return "2k_mars.jpg"
        case .Jupiter:
            return "2k_jupiter.jpg"
        case .Saturn:
            return "2k_saturn.jpg"
        case .Uranus:
            return "2k_uranus.jpg"
        case .Neptune:
            return "2k_neptune.jpg"
        }
    }
}

