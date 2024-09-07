//
//  Wall.swift
//  Setv2
//
//  Created by Vladyslav Pryl on 05.09.2024.
//

import SwiftUI

class SetGame: ObservableObject {
    static let shapes: [AnyShape] = [AnyShape(Circle()), AnyShape(Rectangle()), AnyShape(Ellipse())]
    static let colorful: [Color] = [.purple,.blue,.green]
    
    @Published private var model = createGame()
    
    var cards: [Set<Content>.Card] {
        model.deck
    }
    
    static func createGame() -> Set<Content> {
        Set<Content>( {(x: Int,c: Int,sd: Int, sp: Int) in
            Content(x: 1, c: c, sd: Shading.fromInt(sd), sp: sp)} )
    }
    
    struct Content: View, IntOfFeatures {
        var x: Int
        var c: Int
        //var sd: Int
        var sd: Shading
        var sp: Int
        
        var body: some View {  // somehow create only visible when game starts?
            let shape = shady(shapes[sp], sd)
            VStack {
                shape
                if x >= 1 {
                    shape
                }
                if x >= 2 {
                    shape
                }
            }
            .padding(9)
            .foregroundStyle(colorful[c])
        }
    }
    
    @ViewBuilder
    static private func shady(_ AS: AnyShape, _ s: Shading) -> some View {
        switch s {
        case .striped:
            AS.opacity(0.4)
        case .open:
            AS.stroke(lineWidth: 6)
        default:
            AS
        }
    }
        
    func isDeckEmpty() -> Bool {
        model.fullDeck.isEmpty
    }
    
    // MARK: - USER_FUNC
    
    func choose(_ card: Set<Content>.Card) {
        model.selectCard(card)
        if model.fullDeck.isEmpty {
            if model.deck.count == 3 {
                if model.sInd.count == 3 {
                    newGame()
                }
            }
        }
    }
    
    func drawThree() {
        if model.sInd.count == 3 && model.isSet() {
            model.threeCardsBye()
        } else {
            model.drawCardsN(3)
        }
    }
    
    func newGame() {
        model = Set<Content>( {(x: Int,c: Int,sd: Int, sp: Int) in
            Content(x: x, c: c, sd: Shading.fromInt(sd), sp: sp)} )
    }
}
