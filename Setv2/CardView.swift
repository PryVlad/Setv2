//
//  CardView.swift
//  Setv2
//
//  Created by Vladyslav Pryl on 08.09.2024.
//

import SwiftUI

struct CardView: View {
    private let shakeCount: CGFloat = 3
    let card: SetRules<SetGame.Content>.Card
    let isFaceUp: Bool
    
    init (_ c: SetRules<SetGame.Content>.Card, isFaceUp: Bool) {
        card = c
        self.isFaceUp = isFaceUp
    }
    
    var body: some View {
        card.body
            .cardify(isWrong: card.isWrong,
                     isSelected: card.isSelected,
                     isFaceUp: isFaceUp)
            .shake(card.isWrong ? shakeCount : 0)
    }
}

struct Cardify: ViewModifier, Animatable {
    init(isWrong: Bool, isSelected: Bool, isFaceUp: Bool) {
        self.isWrong = isWrong
        self.isSelected = isSelected
        self.isFaceUp = isFaceUp
        rotation = isFaceUp ? 0 : 180
    }
    
    let isWrong: Bool
    let isSelected: Bool
    let isFaceUp: Bool
    
    var middleOfFlip: Bool {
        rotation < 90
    }
    var rotation: Double
    var animatableData: Double {
        get { rotation }
        set { rotation = newValue }
    }
    
    func body(content: Content) -> some View {
        let base = RoundedRectangle(cornerRadius: Constants.radius)
        base.stroke(isWrong ? .red : .gray,
                    lineWidth: Constants.strokeWidth)
        .background(base.fill(isSelected ? .gray : .white))
        .overlay(alignment: Alignment.center) {
            content.padding(Constants.padding)
                .opacity(middleOfFlip ? 1 : 0)
        }
        .rotation3DEffect(Angle.degrees(rotation),
                          axis: (0, 1, 0))
    }
    
    private struct Constants {
        static let radius: CGFloat = 15
        static let strokeWidth: CGFloat = 6
        static let padding: CGFloat = 10
    }
}

//Copypaste
struct Shake: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

extension View {
    func cardify(isWrong: Bool, isSelected: Bool, isFaceUp: Bool) 
    -> some View {
        modifier(Cardify(isWrong: isWrong,isSelected: isSelected,isFaceUp: isFaceUp))
    }
    
    func shake(_ CGfloat: CGFloat) -> some View {
        modifier(Shake(animatableData: CGfloat))
    }
}



#Preview {
    CardView(SetRules.Card(id: 7, isSelected: false, isWrong: false, 
                      body: SetGame.Content(copies: 0,
                                            color: ThreeVar.fromInt(0),
                                            shading: ThreeVar.fromInt(0),
                                            shape: ThreeVar.fromInt(0) )), 
             isFaceUp: true)
        .aspectRatio(1, contentMode: .fit)
        .padding()
}
