//
//  Truth.swift
//  Setv2
//
//  Created by Vladyslav Pryl on 05.09.2024.
//

import Foundation

struct SET {
    private(set) var drawDeck: [Card] = []
    private(set) var visible: [Card] = []
    private(set) var PNselected: [Int] = []
    private let fullDeck: [Card]
    
    init() {
        var i = 0
        for x in 0..<Global.sMax {
            for c in 0..<Global.sMax {
                for s in 0..<Global.sMax {
                    for a in 0..<Global.sMax {
                        drawDeck.append(Card(id: i, body: .init(
                            copies: x,
                            color: OneOfThree.fromInt(c),
                            shading: OneOfThree.fromInt(a),
                            shape: OneOfThree.fromInt(s)
                        )))
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
        PNselected.removeAll()
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
                if !PNselected.contains(where: {$0 == cardIndex }) {
                    PNselected.append(cardIndex)
                }
                if PNselected.count == Global.sMax {
                    ifWrongVisual()
                }
            }
        } else if PNselected.count < Global.sMax {
            deselect(card.id)
        }
    }
    
    mutating func selectedAreFullAfter(itWasButton b: Bool) {
        // FIXME: 13.09.2024 GPT-1o - Goodbye, World!
        if isSet() {
            removeSelectedCards(swap: b)
        } else {
            PNselected.forEach({ index in visible[index].isWrong = false })
        }
        PNselected.removeAll()
    }
    
    mutating private func removeSelectedCards(swap: Bool) {
        var diff = 0
        PNselected.sort(by: {(a, b) in a<b })
        PNselected.forEach( {index in
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
        let index = PNselected.firstIndex(where: {visible[$0].id == cardId })
        if let index {
            visible[PNselected[index]].isSelected = false
            PNselected.remove(at: index)
        }
    }
    
    mutating func deselectAll() {
        PNselected.forEach( {visible[$0].isSelected = false })
    }
        
    mutating private func ifWrongVisual() {
        if !isSet() {
            PNselected.forEach( {index in
                visible[index].isSelected = false
                visible[index].isWrong = true })
        }
    }
    
    func isSet() -> Bool {
        let comp = oneTrait(index: PNselected[0], index: PNselected[1])
        if comp != -1 {
            return comp == oneTrait(index: PNselected[1], index: PNselected[2])
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
        let body: Content
 
        static func == (lhs: SET.Card, rhs: SET.Card) -> Bool {
            lhs.id == rhs.id
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        struct Content: Hashable, Equatable {
            let copies: Int
            let color: OneOfThree
            let shading: OneOfThree
            let shape: OneOfThree
        }
    }
}
