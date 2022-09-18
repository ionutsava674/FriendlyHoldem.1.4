//
//  blurYourself.swift
//  CardPlay
//
//  Created by Ionut on 17.12.2021.
//

import SwiftUI

extension View {
    //@ViewBuilder
    func blurYourself<ShapeType: InsettableShape>(radius: CGFloat, shape: ShapeType, highContrast: Bool = false) -> some View {
        let modRad = highContrast ? 0 : radius
        return ZStack {
            self
                .blur(radius: modRad)
            if !highContrast {
            self
                .clipShape( shape.inset( by: modRad) )
                // .clipShape(shape.inset( by: radius))
                // .clipShape(Circle().inset(by: radius))
            }
        } //zs
    } //func
} //ext
