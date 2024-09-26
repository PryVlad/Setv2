//
//  Globals.swift
//  Setv2
//
//  Created by Vladyslav Pryl on 09.09.2024.
//

import Foundation

struct Global {
    static let sMax: Int = 3
    static let features: Int = 4
    static let firstDraw: Int = sMax * features
    static let fullDeckCount = countFullDeck()
    
    static func countFullDeck() -> Int {
        var temp = sMax
        for _ in 2..<features {
            temp *= temp
        }
        return temp
    }
}

enum OneOfThree {
    case one, two, three
    
    static func fromInt(_ i: Int) -> OneOfThree {
        var temp: OneOfThree
        switch i {
        case 0:
            temp = OneOfThree.one
        case 1:
            temp = OneOfThree.two
        default:
            temp = OneOfThree.three
        }
        return temp
    }
}
