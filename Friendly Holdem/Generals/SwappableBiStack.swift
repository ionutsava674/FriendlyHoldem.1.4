//
//  SwappableBiStack.swift
//  Friendly Holdem
//
//  Created by Ionut on 22.09.2022.
//

import SwiftUI

struct SwappableBiStack<FirstContentType: View, SecondContentType: View>: View {
    let vertical: Bool
    let swapped: Bool
    var hAlignment: HorizontalAlignment = .center
    var vAlignment: VerticalAlignment = .center
    let spacing: CGFloat?
    let firstContent: () -> FirstContentType
    let secondContent: () -> SecondContentType
    
    var innerGroup: some View {
        Group {
            if swapped {
                secondContent()
                firstContent()
            } else {
                firstContent()
                secondContent()
            }
        } //gr
    } //cv
    
    var body: some View {
        if vertical {
            VStack(alignment: hAlignment, spacing: spacing) {
                innerGroup
            } //vs
        } else {
            HStack(alignment: vAlignment, spacing: spacing) {
                innerGroup
            }
        } //else
    } //body
} //str
