//
//  Truth.swift
//  Setv2
//
//  Created by Vladyslav Pryl on 05.09.2024.
//

import Foundation

struct Set<Content:IntOfFeatures> {
    private(set) var fullDeck: [Card] = []
    private(set) var deck: [Card] = []
    private(set) var sInd: [Int] = []
    
    init(_ f: (_: Int, _: Int, _: Int, _: Int) -> Content) {
        let size = 3
        var i = 0
        for x in 0..<size {
            for c in 0..<size {
                for s in 0..<size {
                    for a in 0..<size {
                        fullDeck.append(Card(id: i, body: f(x, c, a, s) ))
                        i+=1
                    }
                }
            }
        }        
        fullDeck.shuffle()
        drawCardsN(12)
    }
    
    mutating func drawCardsN(_ n: Int) {
        for _ in 0..<n {
            let temp = fullDeck.popLast()
            if let temp {
                deck.append(temp)
            }
        }
    }
    
    mutating func selectCard(_ card: Card) {
        ifAlready3Cards()
        if !card.isSelected {
            let cardIndex = indexOfID(card.id)
            if let cardIndex {
                deck[cardIndex].isSelected = true
                if !sInd.contains(where: {$0 == cardIndex}) {
                    sInd.append(cardIndex)
                }
                if sInd.count == 3 {
                    ifWrongVisual()
                }
            }
        } else if sInd.count < 3 {
            deselect(card.id)
        }
    }
    
    mutating private func ifAlready3Cards() {
        if sInd.count == 3 {
            if isSet() {
                threeCardsBye()
            } else {
                sInd.forEach( {index in deck[index].isWrong = false} )
            }
            sInd.removeAll()
        }
    }
    
    mutating func threeCardsBye() {
        var diff = 0
        sInd.sort(by: {(a, b) in a<b})
        sInd.forEach( {index in
            let temp = fullDeck.popLast()
            if let temp {
                deck[index] = temp
            } else {
                deck.remove(at: index-diff)
                diff+=1
            }
        } )
    }
    
    mutating private func deselect(_ cardId: Int) {
        let index = sInd.firstIndex(where: {deck[$0].id == cardId})
        if let index {
            deck[sInd[index]].isSelected = false
            sInd.remove(at: index)
        }
    }
        
    mutating private func ifWrongVisual() {
        if !isSet() {
            sInd.forEach( {index in
                deck[index].isSelected = false
                deck[index].isWrong = true} )
        }
    }
    
    mutating func isSet() -> Bool {
        let comp = oneTrait(ndx: sInd[0], ndx: sInd[1])
        if comp != -1 {
            return comp == oneTrait(ndx: sInd[1], ndx: sInd[2])
        }
        return false
    }
         
    private func indexOfID(_ id: Int) -> Int? {
        deck.firstIndex(where: {$0.id == id})
    }
    
    private func oneTrait(ndx i: Int, ndx u: Int) -> Int {
        var countSame = 0
        var same: Int = -1
        
        if (deck[u].body.x == deck[i].body.x) {
            countSame+=1
            same = 0
        }
        if (deck[u].body.c == deck[i].body.c) {
            countSame+=1
            if countSame > 1 {
                return -1
            }
            same = 1
        }
        if (deck[u].body.sp == deck[i].body.sp) {
            countSame+=1
            if countSame > 1 {
                return -1
            }
            same = 2
        }
        if (deck[u].body.sd == deck[i].body.sd) {
            countSame+=1
            if countSame > 1 {
                return -1
            }
            same = 3
        }
        return same
    }
    
    struct Card: Identifiable {
        let id: Int
        var isSelected = false
        var isWrong = false
        var body: Content
        
        func gs() -> Int {
            body.sp
        }
    }
}

protocol IntOfFeatures {
    var x: Int {get}
    var c: Int {get}
    //var sd: Int {get}
    var sd: Shading {get}
    var sp: Int {get}
}

enum Shading {
    case solid
    case striped
    case open
    
    static func fromInt(_ i: Int) -> Shading {
        var temp: Shading
        switch i {
        case 0:
            temp = Shading.striped
        case 1:
            temp = Shading.open
        default:
            temp = Shading.solid
        }
        return temp
    }
}
