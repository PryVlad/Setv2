//
//  Globals.swift
//  Setv2
//
//  Created by Vladyslav Pryl on 09.09.2024.
//

import Foundation

struct Global {
    static let size: Int = 3
    static let firstDraw: Int = 12
    static let fullDeckCount = countFullDeck()
    
    static func countFullDeck() -> Int {
        var temp = size
        let features = 4
        for _ in 2..<features {
            temp *= temp
        }
        return temp
    }
}

protocol FourFeatures {
    var copies: Int {get}
    var color: ThreeVar {get}
    var shading: ThreeVar {get}
    var shape: ThreeVar {get}
}

enum ThreeVar {
    case one, two, three
    
    static func fromInt(_ i: Int) -> ThreeVar {
        var temp: ThreeVar
        switch i {
        case 0:
            temp = ThreeVar.one
        case 1:
            temp = ThreeVar.two
        default:
            temp = ThreeVar.three
        }
        return temp
    }
}
