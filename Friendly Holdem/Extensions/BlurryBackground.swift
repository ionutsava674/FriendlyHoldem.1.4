//
//  BlurView.swift
//  CardPlay
//
//  Created by Ionut on 24.06.2022.
//

import SwiftUI

extension View {
    @ViewBuilder
    func blurryBackground( enabled: Bool, color: Color) -> some View {
        if enabled {
            self
                .background(
                             RoundedRectangle( cornerRadius: 4)
                                .fill( color)
                                .blur( radius: 4)
                                .opacity(0.7)
                             ) //back
        } else {
            self
        }
    } //func
} //ext
