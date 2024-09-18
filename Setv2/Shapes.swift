//
//  Shapes.swift
//  Setv2
//
//  Created by Vladyslav Pryl on 08.09.2024.
//

import SwiftUI
//import CoreGraphics

struct Diamond: Shape, InsettableShape {
    var insetAmount = 0.0
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var s = self
        s.insetAmount += amount
        return s
    }
    
    func path(in rect: CGRect) -> Path {
        let yOffset: CGFloat = rect.maxX-2 <= rect.maxY+1 ? rect.maxY/6 : rect.minY
        //let itJustWorks = rect.midX / (rect.midY/6)
        //let horizontalOffset: CGFloat = rect.maxX <= rect.maxY ? 0 : itJustWorks
        let forSureWorks = rect.midX - (rect.maxY+rect.maxY) * (0.26)
        let xOffset = forSureWorks - (rect.midX - rect.midY)/3
        let start = CGPoint(x: rect.midX, y: yOffset+insetAmount)
        var p = Path()
        p.move(to: start)
        p.addLine(to: CGPoint(x: rect.minX + xOffset+insetAmount, y: rect.midY))
        p.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - yOffset-insetAmount))
        p.addLine(to: CGPoint(x: rect.maxX - xOffset-insetAmount, y: rect.midY))
        p.addLine(to: start)
        return p
    }
}

struct AlmostSquiggle: Shape, InsettableShape {
    var insetAmount = 0.0
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var s = self
        s.insetAmount += amount
        return s
    }
    
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let offset = (rect.midX - rect.midY)/6
        let vertical = rect.midY*0.8
        p.addRect(CGRect(origin: CGPoint(x: rect.minX+offset,
                                         y: rect.midY),
                         size: CGSize(width: rect.midX-offset,
                                      height: vertical+offset)))
        p.addRect(CGRect(origin: CGPoint(x: rect.midX,
                                         y: rect.midY-vertical-offset),
                         size: CGSize(width: rect.midX-offset,
                                      height: vertical+offset)))
        return p
    }
}

/*
struct Pie: Shape {
    var startAngle: Angle = .zero - .degrees(90)
    let endAngle: Angle
    var clockwise = true
    
    func path(in rect: CGRect) -> Path {
        let endAngle = endAngle - .degrees(90)
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let start = CGPoint(
            x: center.x + radius * cos(startAngle.radians),
            y: center.y + radius * sin(startAngle.radians)
        )
        
        var p = Path()
        p.move(to: center)
        p.addLine(to: start)
        p.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: !clockwise)
        p.addLine(to: center)
        
        return p
    }
} */
