//
//  Truth.swift
//  Setv2
//
//  Created by Vladyslav Pryl on 05.09.2024.
//

import Foundation

struct SetRules<Content: FourFeatures> {
    private(set) var drawDeck: [Card] = []
    private(set) var visible: [Card] = []
    private(set) var sInd: [Int] = []
    private let fullDeck: [Card]
    
    init(_ f: (_: Int, _: Int, _: Int, _: Int) -> Content) {
        let size = Global.size
        var i = 0
        for x in 0..<size {
            for c in 0..<size {
                for s in 0..<size {
                    for a in 0..<size {
                        drawDeck.append(Card(id: i, body: f(x, c, a, s) ))
                        i+=1
                    }
                }
            }
        }
        fullDeck = drawDeck
        prepare()
    }
    
    mutating func prepare() {
        drawDeck = fullDeck
        visible.removeAll()
        sInd.removeAll()
        drawDeck.shuffle()
        drawCard(Global.firstDraw)
    }
    
    mutating func drawCard(_ amount: Int) {
        for _ in 0..<amount {
            let temp = drawDeck.popLast()
            if let temp {
                visible.append(temp)
            }
        }
    }
    
    mutating func selectCard(_ card: Card) {
        if !card.isSelected {
            let cardIndex = visible.firstIndex(where: {$0.id == card.id })
            if let cardIndex {
                visible[cardIndex].isSelected = true
                if !sInd.contains(where: {$0 == cardIndex }) {
                    sInd.append(cardIndex)
                }
                if sInd.count == Global.size {
                    ifWrongVisual()
                }
            }
        } else if sInd.count < Global.size {
            deselect(card.id)
        }
    }
    
    mutating func selectedAreFullAfter(itWasButton b: Bool) {
        // FIXME: 13.09.2024 GPT-1o - Goodbye, World!
        if isSet() {
            removeSelectedCards(swap: b)
        } else {
            sInd.forEach({ index in visible[index].isWrong = false })
        }
        sInd.removeAll()
    }
    
    mutating private func removeSelectedCards(swap: Bool) {
        var diff = 0
        sInd.sort(by: {(a, b) in a<b })
        sInd.forEach( {index in
            if swap {
                let temp = drawDeck.popLast()
                if let temp {
                    visible[index] = temp
                }
            } else {
                visible.remove(at: index-diff)
                diff+=1
            }
        })
    }
    
    mutating private func deselect(_ cardId: Int) {
        let index = sInd.firstIndex(where: {visible[$0].id == cardId })
        if let index {
            visible[sInd[index]].isSelected = false
            sInd.remove(at: index)
        }
    }
    
    mutating func deselectAll() {
        sInd.forEach( {visible[$0].isSelected = false })
    }
        
    mutating private func ifWrongVisual() {
        if !isSet() {
            sInd.forEach( {index in
                visible[index].isSelected = false
                visible[index].isWrong = true })
        }
    }
    
    func isSet() -> Bool {
        let comp = oneTrait(index: sInd[0], index: sInd[1])
        if comp != -1 {
            return comp == oneTrait(index: sInd[1], index: sInd[2])
        }
        return false
    }
    
    private func oneTrait(index i: Int, index u: Int) -> Int {
        var oneFound = false
        var same: Int = -1
        let c1 = visible[u].body
        let c2 = visible[i].body
        
        if (c1.copies == c2.copies) {
            oneFound = true
            same = 0
        }
        if (c1.color == c2.color) {
            if oneFound { return -1 }
            oneFound = true
            same = 1
        }
        if (c1.shape == c2.shape) {
            if oneFound { return -1 }
            oneFound = true
            same = 2
        }
        if (c1.shading == c2.shading) {
            if oneFound { return -1 }
            oneFound = true
            same = 3
        }
        return same
    }
    
    struct Card: Identifiable, Hashable, Equatable {
        let id: Int
        var isSelected = false
        var isWrong = false
        var body: Content
 
        static func == (lhs: SetRules<Content>.Card, 
                        rhs: SetRules<Content>.Card) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
}
