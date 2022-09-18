//
//  CardView.swift
//  CardPlay
//
//  Created by Ionut on 05.08.2021.
//

import SwiftUI

struct CardView: View {
    @ObservedObject var card: Card
    let cardWidth: CGFloat
    private var cardHeight: CGFloat { cardWidth * RawCard.cardSizeRatio }
    var faceDown: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var backFacingText: String?

    var body: some View {
        ZStack {
            if faceDown {
            Image("blue", label: Text(backFacingText ?? "card facing down"))
                .resizable()
                .scaledToFit()
                // .transition(.cardFlipTransition)
                .transition(.modifier(
                    active: CardFlipModifier(angleX: .degrees(-180), opaque: 0.0),
                    identity: CardFlipModifier(angleX: .zero, opaque: 1.0)))
                .accessibilityRemoveTraits(.isImage)
            }
            if !faceDown {
                Image(card.id, label: Text(card.readableName))
                .resizable()
                .scaledToFit()
                // .transition(.cardFlipTransition)
                .transition(.modifier(
                    active: CardFlipModifier(angleX: .degrees(180), opaque: 0.0),
                    identity: CardFlipModifier(angleX: .zero, opaque: 1.0)))
                .accessibilityRemoveTraits(.isImage)
                .accessibilityValue(Text(card.readableName))
                .accessibilityLabel(Text(""))
            }
        } //zs
        .shadow(radius: 5)
        // .animation(transitionAnimation, value: pfd)
        .frame(maxWidth: cardWidth, maxHeight: cardHeight, alignment: .center)
        //.animation(rotationAnimation, value: pfd)
        // .transition(.midOpacityTransfer)
    } //body
} //str
extension AnyTransition {
    static var midOpacityTransfer: AnyTransition {
        .asymmetric(
        insertion: .modifier(
            active: OpModifier( opaque: 0.0),
            identity: OpModifier( opaque: 1.0)),
        removal: .modifier(
            active: OpModifier( opaque: 0.0),
            identity: OpModifier( opaque: 1.0)))
    } //cv
} //ext
struct OpModifier: ViewModifier {
    let opaque: Double
    
    func body(content: Content) -> some View {
        content
            .opacity(opaque > 0.5 ? 1.0 : 0.0)
    } //body
} //modif str

struct CardFlipModifier: ViewModifier {
    let angleX: Angle
    let opaque: Double
    
    func body(content: Content) -> some View {
        content
            //.clipped()
            .rotation3DEffect( angleX, axis: (x: 1.0, y: 0.0, z: 0.0))
            .opacity(opaque > 0.5 ? 1.0 : 0.0)
            //.clipped()
    } //body
} //modif str

