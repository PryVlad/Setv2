//
//  ContentView.swift
//  Setv2
//
//  Created by Vladyslav Pryl on 04.09.2024.
//

import SwiftUI

struct ContentView: View {
    typealias Card = SetRules<SetGame.Content>.Card

    @ObservedObject var SetView: SetGame
    
    @State private var refresh = false
    
    var body: some View {
        topScreen
        botPanel
    }
    
    @ViewBuilder
    var topScreen: some View {
        if !refresh {
            cards
                .onDisappear {
                    newGame()
                }
        } else {
            VStack {
                Rectangle()
                    .foregroundStyle(.clear)
            }
        }
    }
    
    var botPanel: some View {
        HStack { // FIXME: vstack if horizontal orientation
            HStack {
                Spacer()
                sysButton(askNewGame, "arrow.clockwise.square.fill")
                Spacer()
                deck
            }
            HStack {
                Spacer()
                discardDeck
                    .padding(Constants.discardPadding)
            }
        }
        .font(.largeTitle)
    }
    
    private func askNewGame() {
        SetView.deselect()
        takeBack()
        withAnimation {
            refresh = true
        }
    }
    
    private func newGame() {
        discardedCards.removeAll()
        flipState = Array(repeating: false,
                          count: Global.fullDeckCount+1)
        SetView.newGame()
        refresh = false
        deal(SetView.cards, delay: false)
    }
    
    @State private var flipState =
        Array(repeating: false, count: Global.fullDeckCount+1)
    
    private func flipIncrease() {
        let firstDrawDone = flipState.last
        if let firstDrawDone {
            if firstDrawDone {
                if SetView.flipCount < Double(Global.size) {
                    SetView.flipCount += 1
                } else {
                    SetView.flipCount = 1
                }
            }
            if !firstDrawDone {
                if SetView.flipCount < Double(Global.firstDraw-1) {
                    SetView.flipCount += 1
                } else {
                    flipState[flipState.endIndex-1] = true
                    SetView.flipCount = 1
                }
            }
        }
    }

    var cards: some View {
        AspectVGrid(SetView.cards, aspectRatio:
                        Constants.ratioCard) { card in
            if isDealt(card) {
                CardView(card, isFaceUp: flipState[card.id])
                    .matchedGeometryEffect(id: card.id,
                                           in: card.isSelected
                                           ? discardNamespace
                                           : dealingNamespace)
                    .transition(.asymmetric(insertion: .identity,
                                            removal: .identity))
                    .padding(Constants.paddingCard)
                    .onTapGesture {
                        tapCard(card)
                    }
                    .onAppear {
                        flipper(card.id)
                    }
                    .zIndex(flipState[flipState.count-1]
                            ? zIndexUpdate(card)
                            : 0)
            }
        }
    }
    
    private func tapCard(_ card: Card) {
        ifDiscard()
        if SetView.SCsize == Global.size {
            SetView.selectedFull(fromButton: false)
        }
        withAnimation {
            SetView.choose(card)
        }
        if SetView.isGameOver {
            askNewGame()
        }
    }
    
    private func zIndexUpdate(_ card: Card) -> Double {
        if SetView.SCsize == 0 {
            if SetView.zIndexSwapID.contains(where: {
                $0 == card.id }) {
                return 2
            }
        }
        return 0
    } //FIXME: make efficient way to not cycle through stable cards
    
    private func flipper(_ cardID: Int) {
        withAnimation(Constants.dealAnimation.delay(flipDelay())) {
            flipIncrease()
            flipState[cardID] = true
        }
    }
    
    private func flipDelay() -> TimeInterval {
        flipState[flipState.count-1]
        ? Constants.dealInterval*(SetView.flipCount
                                + Constants.dealInterval)
        : Constants.dealInterval*SetView.flipCount
                                + Constants.dealInterval+0.02
    }
    
    private func ifDiscard() {
        if SetView.SCsize == Global.size {
            if SetView.isSet {
                var delay: TimeInterval = 0
                for card in SetView.findCardsFrom(SetView.SCindices) {
                    withAnimation(Constants.dealAnimation.delay(delay)) {
                        dealt.remove(card.id)
                        discardedCards.append(card)
                    }
                    delay += Constants.dealInterval
                }
            }
        }
    }
    
    @State private var dealt = Set<Card.ID>()
    @State private var discardedCards: [Card] = []
    
    private func isDealt(_ card: Card) -> Bool {
        dealt.contains(card.id)
    }
    
    private var undealtCards: [Card] {
        SetView.cards.filter{ !isDealt($0) }
    }
    
    @Namespace private var dealingNamespace
    @Namespace private var discardNamespace
    
    private var discardDeck: some View {
        ZStack { //FIXME: newgame -> back into draw pile animation
            if !refresh {
                ForEach(discardedCards) { card in
                    let index = discardedCards.firstIndex(of: card)
                    if let index {
                        card.body
                            .cardify(isWrong: index%2==0,
                                     isSelected: false,
                                     isFaceUp: true)
                            .offset(x: offsetDiscardCard(index))
                            .matchedGeometryEffect(id: card.id,
                                                   in: discardNamespace)
                            .transition(.identity)
                    }
                }
            }
        }
        .frame(width: Constants.deckWidth,
               height: Constants.deckWidth/Constants.ratioCard)
    }
    
    private func offsetDiscardCard(_ index: Int) -> CGFloat {
        CGFloat(-Double(index) * Constants.discardOffset)
    }
        
    private var deck: some View {
        ZStack (alignment: .bottom) {
            ForEach(undealtCards+SetView.drawDeck) { card in
                Image(systemName: "plus.square.fill")
                    .imageScale(Image.Scale.medium)
                    .foregroundStyle(.blue)
                    .cardify(isWrong: false,
                             isSelected: false,
                             isFaceUp: dealt.isEmpty ? false : true)
                    .matchedGeometryEffect(id: card.id,
                                           in: dealingNamespace)
                    .transition(.asymmetric(insertion: .identity,
                                            removal: .identity))
            }
        }
        .frame(width: Constants.deckWidth,
               height: Constants.deckWidth/Constants.ratioCard)
        .onTapGesture {
            tapDeck()
        }
        .onAppear {
            deal(SetView.cards, delay: false)
        }
    }
    
    private func tapDeck() {
        ifDiscard()
        if SetView.SCsize == Global.size {
            if !SetView.isSet {
                SetView.selectedFull(fromButton: true)
                drawTop()
            } else {
                let indices = SetView.SCindices
                SetView.selectedFull(fromButton: true)
                let swapCards = SetView.findCardsFrom(indices)
                SetView.zIndexTop(swapCards)
                deal(swapCards, delay: true)
            }
        } else {
            drawTop()
        }
    }
    
    private func drawTop() {
        SetView.drawThree()
        deal(Array(SetView.cards.suffix(from:
             SetView.cards.count-Global.size)), delay: false)
    }
    
    private func deal(_ array: [Card], delay: Bool) {
        var delayTime: TimeInterval = delay
            ? Constants.dealInterval*Double(Global.size) : 0
        for card in array {
            withAnimation(Constants.dealAnimation.delay(delayTime)) {
                _ = dealt.insert(card.id)
            }
            delayTime += Constants.dealInterval
        }
    }
    
    private func takeBack() {
        for card in SetView.cards {
            withAnimation {
                _ = dealt.remove(card.id)
            }
        }
    }
    
    func sysButton(_ act: @escaping () -> Void, _ name: String) 
    -> some View {
        Button(action: act, label: {
            Image(systemName: name)
        })
    }
    
    private struct Constants {
        static let ratioCard: CGFloat = 1.02
        static let paddingCard: CGFloat = 6
        static let dealAnimation: Animation = .snappy(duration: 0.2)
        static let dealInterval: TimeInterval = 0.1
        static let deckWidth: CGFloat = 50
        static let discardPadding: CGFloat = 8
        static let discardOffset = 1.6
    }
}














#Preview {
    ContentView(SetView: SetGame())
}
