//
//  CardView.swift
//  Setv2
//
//  Created by Vladyslav Pryl on 08.09.2024.
//

import SwiftUI

struct CardView: View {
    typealias Card = SET.Card
    
    static private let shakeCount: CGFloat = 3
    let card: Card
    let isFaceUp: Bool
    
    init (_ c: Card, isFaceUp: Bool) {
        card = c
        self.isFaceUp = isFaceUp
    }
    
    var body: some View {
        Self.decode(card)
            .cardify(isWrong: card.isWrong,
                     isSelected: card.isSelected,
                     isFaceUp: isFaceUp)
            .shake(card.isWrong ? Self.shakeCount : 0)
    }
    
    @ViewBuilder
    static func decode(_ c: Card) -> some View {
        let shape = makeViewOf(c.body.shape, c.body.shading)
        VStack {
            shape
            if c.body.copies >= 1 {
                shape
            }
            if c.body.copies >= 2 {
                shape
            }
        }
        .foregroundStyle(colorSelect(c.body.color))
    }
    
    static private func colorSelect(_ from: OneOfThree) -> Color {
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
    static private func applyModifier(
        _ shading: OneOfThree, to s: some Shape & InsettableShape
    ) -> some View {
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
    static private func makeViewOf(
        _ shape: OneOfThree, _ shading: OneOfThree
    ) -> some View {
        switch shape {
        case .one:
            applyModifier(shading, to: Diamond())
        case .two:
            applyModifier(shading, to: AlmostSquiggle())
        default:
            applyModifier(shading, to: Capsule())
        }
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



/*#Preview {
    CardView(SET.Card(id: 7, isSelected: false, isWrong: false,
                      body: GameSET.Content(copies: 0,
                                            color: OneOfThree.fromInt(0),
                                            shading: OneOfThree.fromInt(0),
                                            shape: OneOfThree.fromInt(0) )), 
             isFaceUp: true)
        .aspectRatio(1, contentMode: .fit)
        .padding()
}*/
