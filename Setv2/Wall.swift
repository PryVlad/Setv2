//
//  Wall.swift
//  Setv2
//
//  Created by Vladyslav Pryl on 05.09.2024.
//

import SwiftUI

class GameSET: ObservableObject {
    typealias Card = SET.Card
    
    @Published private var gameSET = SET()
    
    var cards: [Card] { gameSET.visible }
    var drawDeck: [Card] { gameSET.drawDeck }
    var isSet: Bool { gameSET.isSet() }
    var SCpointers: [Int] {
        gameSET.PNselected.sorted(by: { (a, b) in a<b })
    }
    var isGameOver: Bool {
        if gameSET.drawDeck.isEmpty {
            if gameSET.visible.count == Global.sMax {
                if gameSET.PNselected.count == Global.sMax {
                    return true
                }
            }
        }
        return false
    }
    var flipCount: Double = 0
    var zIndexNowSwapID = Set<Card.ID>()
    var isFirstDrawDone = false
    var isDiscardShuffleActive = false
    var isSelectedFull: Bool {
        gameSET.PNselected.count == Global.sMax
    }
    
    func zIndexTop(_ cards: [Card]) {
        zIndexNowSwapID.removeAll()
        cards.forEach( {zIndexNowSwapID.insert($0.id) })
    }
    
    func findCardsFrom(_ indices: [Int]) -> [Card] {
        var a: [Card] = []
        indices.forEach( {a.append(gameSET.visible[$0]) })
        return a
    }
    
    func selectedFull(fromButton b: Bool) {
        gameSET.selectedAreFullAfter(itWasButton: b)
    }
    
    func deselect() {
        gameSET.deselectAll()
    }
    
    func flipIncrease() {
        if isFirstDrawDone {
            if flipCount < Double(Global.sMax) {
                flipCount += 1
            } else {
                flipCount = 1
            }
        }
        if !isFirstDrawDone {
            if flipCount < Double(Global.firstDraw-1) {
                flipCount += 1
            } else {
                isFirstDrawDone = true
                flipCount = 1
            }
        }
    }
    
    func zIndexUpdate(_ card: Card) -> Double {
        if gameSET.PNselected.count == 0 {
            if zIndexNowSwapID.contains(card.id) {
                return 2
            }
        }
        return 0
    } //FIXME: horizontal orientation different
    
    func flipDelay(_ dealInterval: TimeInterval) -> TimeInterval {
        isFirstDrawDone
        ? dealInterval*(flipCount+dealInterval)
        : dealInterval*flipCount+dealInterval
    }
    
    func zIndex(_ card: Card) -> Double {
        if !isFirstDrawDone {
            return 0
        }
        return zIndexUpdate(card)
    }
    
    static func arrayFalseFilledFull() -> [Bool] {
        Array(repeating: false, count: Global.fullDeckCount)
    }
    
    // MARK: - Intent(s)
    
    func choose(_ card: Card) {
        gameSET.selectCard(card)
    }
    
    func drawThree() {
        gameSET.drawCard(Global.sMax)
    }
    
    func newGame() {
        isFirstDrawDone = false
        isDiscardShuffleActive = false
        flipCount = 0
        gameSET.prepare()
    }
}
