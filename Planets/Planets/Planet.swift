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
    case Mercury, Venus, Earth, Mars, Jupiter, Saturn, Uranus, Neptune, Sun

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
        case .Sun:
            return "Sun"
        }
    }

    func image() -> UIImage? {
        return UIImage.init(named: imagename())
    }

    // https://solarsystemscope.com/textures
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
        case .Sun:
            return "2k_sun.jpg"
        }
    }

    func scaledRadius() -> CGFloat {
        return radius() * 0.1
    }

    // https://www.universetoday.com/36649/planets-in-order-of-size/
    private func radius() -> CGFloat {
        switch self {
        case .Mercury:
            return 0.38
        case .Venus:
            return 0.95
        case .Earth:
            return 1.0
        case .Mars:
            return 0.53
        case .Jupiter:
            return 11.2
        case .Saturn:
            return 9.45
        case .Uranus:
            return 4.0
        case .Neptune:
            return 3.88
        case .Sun:
            return 110.0
        }
    }

    func scaledDistanceFromSun() -> CGFloat {
        return distanceFromSun() * 2.0
    }

    // Not accurate
    private func distanceFromSun() -> CGFloat {
        switch self {
        case .Sun:
            return 0
        case .Mercury:
            return 13
        case .Venus:
            return 14
        case .Earth:
            return 15
        case .Mars:
            return 16
        case .Jupiter:
            return 17
        case .Saturn:
            return 19
        case .Uranus:
            return 20
        case .Neptune:
            return 21
        }
    }
}

