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
    
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    
    var body: some View {
        HStack {
            if verticalSizeClass == .compact {
                vUserButtons
            }
            visibleCards
        }
        if verticalSizeClass == .regular {
            hUserButtons
        }
    }
    
    @ViewBuilder
    var visibleCards: some View {
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
    
    var hUserButtons: some View {
        HStack(spacing: 0) {
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
    
    var vUserButtons: some View {
        VStack(spacing: 0){
            deck
                .padding(.vertical)
            Spacer()
            discardDeck
            sysButton(askNewGame, "arrow.clockwise.square.fill")
                .padding(.vertical)
        }
        .font(.largeTitle)
    }
    
    private func askNewGame() {
        SetView.isDiscardShuffleActive = true
        SetView.deselect()
        takeBackActive()
        takeBackDiscarded()
        withAnimation {
            refresh = true
        }
    }
    
    private func newGame() {
        SetView.newGame()
        shuffledInDeck.removeAll()
        discardedCards.removeAll()
        flipState = Array(repeating: false,
                          count: Global.fullDeckCount)
        refresh = false
        deal(SetView.cards, delay: false)
    }
    
    @State private var flipState =
        Array(repeating: false, count: Global.fullDeckCount)
    
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
                    .zIndex(zIndex(card))
            }
        }
    }
    
    private func zIndex(_ card: Card) -> Double {
        if !SetView.isFirstDrawDone {
            return 0
        }
        return SetView.zIndexUpdate(card)
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
    
    private func flipper(_ cardID: Int) {
        withAnimation(Constants.dealAnimation.delay(flipDelay())) {
            SetView.flipIncrease()
            flipState[cardID] = true
        }
    }
    
    private func flipDelay() -> TimeInterval {
        SetView.isFirstDrawDone
        ? Constants.dealInterval*(SetView.flipCount
                                + Constants.dealInterval)
        : Constants.dealInterval*SetView.flipCount
                                + Constants.dealInterval
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
    @State private var shuffledInDeck = Set<Card.ID>()
    
    private func isDealt(_ card: Card) -> Bool {
        dealt.contains(card.id)
    }
    
    private var undealtCards: [Card] {
        SetView.cards.filter{ !isDealt($0) }
    }
    
    private func isShuffledInDeck(_ card: Card) -> Bool {
        shuffledInDeck.contains(card.id)
    }
    
    private var discardedAndShuffled: [Card] {
        if dealt.isEmpty {
            return discardedCards.filter{ isShuffledInDeck($0) }
        }
        return []
    }
    
    @Namespace private var dealingNamespace
    @Namespace private var discardNamespace
    
    private var discardDeck: some View {
        ZStack {
            ForEach(discardedCards) { card in
                if !isShuffledInDeck(card) {
                    let index = discardedCards.firstIndex(of: card)
                    if let index {
                        card.body
                            .cardify(isWrong: index%2==0,
                                     isSelected: false,
                                     isFaceUp: true)
                            .offset(x: offsetDiscardCard(index, x: true),
                                    y: offsetDiscardCard(index, x: false) )
                            .matchedGeometryEffect(id: card.id,
                                                   in: SetView.isDiscardShuffleActive
                                                   ? dealingNamespace
                                                   : discardNamespace)
                            .transition(.asymmetric(insertion: .identity,
                                                    removal: .identity))
                    }
                }
            }
        }
        .frame(width: Constants.deckWidth,
               height: Constants.deckWidth/Constants.ratioCard)
    }
    
    private func offsetDiscardCard(_ index: Int, x: Bool) -> CGFloat {
        let v = verticalSizeClass == .regular && x
        let h = verticalSizeClass == .compact && !x
        
        if v || h {
           return CGFloat(-Double(index) * Constants.discardOffset)
        }
        return 0
    }
        
    private var deck: some View {
        ZStack (alignment: .bottom) {
            ForEach(undealtCards+SetView.drawDeck+discardedAndShuffled)
            { card in
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
    
    private func takeBackActive() {
        for card in SetView.cards {
            withAnimation {
                _ = dealt.remove(card.id)
            }
        }
    }
    
    private func takeBackDiscarded() {
        for card in discardedCards {
            withAnimation {
                _ = shuffledInDeck.insert(card.id)
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
        static let dealAnimation: Animation = .snappy(duration: 0.3)
        static let dealInterval: TimeInterval = 0.1
        static let deckWidth: CGFloat = 50
        static let discardPadding: CGFloat = 8
        static let discardOffset = 1.6
    }
}














#Preview {
    ContentView(SetView: SetGame())
}
