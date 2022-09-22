//
//  ViewBorder.swift
//  Friendly Holdem
//
//  Created by Ionut on 21.09.2022.
//

import SwiftUI

extension View {
    @ViewBuilder
    func doubleBorder<T1: ShapeStyle, T2: ShapeStyle>(_ shapeStyle: T1, lineWidth: CGFloat = 1, withBackground: T2 = .clear) -> some View {
        self
            .border( shapeStyle, width: lineWidth)
            .padding(2 * lineWidth)
            .border( shapeStyle, width: lineWidth)
            .background( withBackground)
    } //func
    func roundedDoubleBorder<T1: ShapeStyle, T2: ShapeStyle>(_ shapeStyle: T1, radius: CGFloat, lineWidth: CGFloat = 1.0, withBackground: T2) -> some View {
        self
            .overlay(content: {
                RoundedRectangle(cornerRadius: radius, style: .circular)
                    .stroke( shapeStyle, lineWidth: lineWidth)
            })
            .padding(2 * lineWidth)
            .overlay(content: {
                RoundedRectangle(cornerRadius: radius + (2 * lineWidth), style: .circular)
                    .stroke( shapeStyle, lineWidth: lineWidth)
            })
            .background( withBackground, in: RoundedRectangle(cornerRadius: radius + (2 * lineWidth), style: .circular) )
            .clipShape(RoundedRectangle(cornerRadius: radius + (2 * lineWidth), style: .circular) )
    } //func
} //ext
