//
//  Wall.swift
//  Setv2
//
//  Created by Vladyslav Pryl on 05.09.2024.
//

import SwiftUI

class SetGame: ObservableObject {
    typealias Card = SetRules<Content>.Card
    
    @Published private var setGame = createGame()
    
    var cards: [Card] { setGame.visible }
    var drawDeck: [Card] { setGame.drawDeck }
    var isSet: Bool { setGame.isSet() }
    var SCsize: Int { setGame.sInd.count }
    var SCindices: [Int] {
        setGame.sInd.sorted(by: {(a, b) in a<b })
    }
    var isGameOver: Bool {
        if setGame.drawDeck.isEmpty {
            if setGame.visible.count == Global.size {
                if setGame.sInd.count == Global.size {
                    return true
                }
            }
        }
        return false
    }
    var flipCount: Double = 0
    var zIndexSwapID: [Card.ID] = [-1,-1,-1]
    var isFirstDrawDone = false
    var isDiscardShuffleActive = false
    
    struct Content: View, FourFeatures {
        let copies: Int
        let color: ThreeVar
        let shading: ThreeVar
        let shape: ThreeVar

        var body: some View {
            let shape = makeViewOf(shape, shading)
            VStack {
                shape
                if copies >= 1 {
                    shape
                }
                if copies >= 2 {
                    shape
                }
            }
            .foregroundStyle(colorSelect(color))
        }
    }
    
    func zIndexTop(_ cards: [Card]) {
        for index in cards.indices {
            zIndexSwapID[index] = cards[index].id
        }
    }
    
    func findCardsFrom(_ indices: [Int]) -> [Card] {
        var a: [Card] = []
        indices.forEach( {a.append(setGame.visible[$0]) })
        return a
    }
    
    func selectedFull(fromButton b: Bool) {
        setGame.selectedAreFullAfter(itWasButton: b)
    }
    
    func deselect() {
        setGame.deselectAll()
    }
    
    func flipIncrease() {
        if isFirstDrawDone {
            if flipCount < Double(Global.size) {
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
        if SCsize == 0 {
            if zIndexSwapID.contains(where: {
                $0 == card.id }) {
                return 2
            }
        }
        return 0
    } //FIXME: needs efficient way to not cycle through stable cards

    static private func createGame() -> SetRules<Content> {
        SetRules<Content>( {(x,c,sd,sp) in
            Content(copies: x, color: ThreeVar.fromInt(c),
                    shading: ThreeVar.fromInt(sd),
                    shape: ThreeVar.fromInt(sp)) })
    }
    
    static private func colorSelect(_ from: ThreeVar) -> Color{
        switch from {
        case .one:
                .purple
        case .two:
                .green
        default:
                .blue
        }
    }
    
    @ViewBuilder
    static private func applyModifier(_ shading: ThreeVar,
                                      to s: some Shape & InsettableShape)
    -> some View {
        switch shading {
        case .one:
            s.opacity(0.4)
        case .two:
            s.stroke(lineWidth: 6)
        default:
            s
        }
    }
    
    @ViewBuilder
    static private func makeViewOf(_ shape: ThreeVar, _ shading: ThreeVar)
    -> some View {
        switch shape {
        case .one:
            applyModifier(shading, to: Diamond())
        case .two:
            applyModifier(shading, to: AlmostSquiggle())
        default:
            applyModifier(shading, to: Capsule())
        }
    }
    
    // MARK: - Intent(s)
    
    func choose(_ card: Card) {
        setGame.selectCard(card)
    }
    
    func drawThree() {
        setGame.drawCard(Global.size)
    }
    
    func newGame() {
        isFirstDrawDone = false
        flipCount = 0
        setGame.prepare()
    }
}
