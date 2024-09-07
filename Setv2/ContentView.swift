//
//  ContentView.swift
//  Setv2
//
//  Created by Vladyslav Pryl on 04.09.2024.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: SetGame
    
    private let aspectRatio: CGFloat = 1
    
    var body: some View {
        cards
        HStack {
            Spacer()
            sysButton(viewModel.newGame, "arrow.clockwise.square.fill")
            Spacer()
            sysButton(viewModel.drawThree, "plus.square.fill")
                .disabled(viewModel.isDeckEmpty())
            Spacer()
        }.font(.largeTitle)
    }
    
    var cards: some View {
        AspectVGrid(viewModel.cards, aspectRatio: aspectRatio) { card in
            CardView(card)
                .padding(6)
                .onTapGesture {
                    viewModel.choose(card)
                }
        }
        /*
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 0)], spacing: 0) {
            ForEach(viewModel.cards.indices, id: \.self) { index in
                CardView(viewModel.cards[index])
                    .padding(8)
                    .onTapGesture {
                        viewModel.choose(viewModel.cards[index])
                    }
            }
        } */
    }
    
    func sysButton(_ act: @escaping () -> Void, _ name: String) -> some View {
        Button(action: act, label: {
            Image(systemName: name)
        })
    }
    
}


struct CardView: View {
    let card: Set<SetGame.Content>.Card
    
    init (_ c: Set<SetGame.Content>.Card) {
        card = c
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .stroke(card.isWrong ? .red : .gray, lineWidth: 10)
                .fill(card.isSelected ? .gray : .white)
            card.body
                .aspectRatio(card.gs() == 2 ? 4/3:1, contentMode: .fit)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}













#Preview {
    ContentView(viewModel: SetGame())
}
