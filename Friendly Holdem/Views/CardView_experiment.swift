//
//  CardView.swift
//  CardPlay
//
//  Created by Ionut on 05.08.2021.
//

import SwiftUI

struct BCardView: View {
    static var c = 1
    static func getc() -> Int {
        c += 1
        return c
    }
    @ObservedObject var card: Card
    let cardWidth: CGFloat
    private var cardHeight: CGFloat { cardWidth * RawCard.cardSizeRatio }
    var faceDown: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        //print("fd \(self.idd) \(self.sid) \(faceDown)")
        return ZStack {
            Image("blue", label: Text("card"))
                .resizable()
                .scaledToFit()
                //Image(card.id, label: Text(card.readableName))
                //.resizable()
                //.scaledToFit()
        } //zs
        //.shadow(radius: 5)
        .frame(maxWidth: cardWidth, maxHeight: cardHeight, alignment: .center)
        .modifier( faceDown ? GeoFlip( angleDegrees: 180, axis: (x: 1.0, y: 0.0)) : GeoFlip( angleDegrees: 0, axis: (x: 1.0, y: 0.0)) )
        .animation(.default, value: self.card.viewChangeTrigger)
        .onReceive(self.card.$viewChangeTrigger) { po in
        }
        //.frame(maxWidth: cardWidth, maxHeight: cardHeight, alignment: .center)
        .transition(.modifier(
            active: HalfVisibleModifier(opaque: 0.0),
            identity: HalfVisibleModifier(opaque: 1.0)))
    } //body
} //str
struct InnerFlipModifier: ViewModifier {
    let angleX: Angle
    let opaque: Double
    
    func body(content: Content) -> some View {
        return content
            .rotation3DEffect( angleX, axis: (x: 1.0, y: 0.0, z: 0.0))
            .opacity(opaque > 0.5 ? 1.0 : 0.0)
            //.clipped()
    } //body
} //modif str
struct HalfVisibleModifier: ViewModifier {
    let opaque: Double
    
    func body(content: Content) -> some View {
        return content
            .opacity(opaque > 0.5 ? 1.0 : 0.0)
            //.clipped()
    } //body
} //modif str
struct GeoFlip: GeometryEffect {
    var animatableData: Double {
        get { angleDegrees }
        set { angleDegrees = newValue }
    } //ad
    var angleDegrees: Double
    let axis: (x: CGFloat, y: CGFloat)
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let a = CGFloat(Angle(degrees: angleDegrees).radians)
        var transform3d = CATransform3DIdentity
        transform3d.m34 = -1 / max(size.width, size.height)
        
        transform3d = CATransform3DRotate(transform3d, a, axis.x, axis.y, 0)
        transform3d = CATransform3DTranslate(transform3d, -size.width / 2.0, -size.height / 2.0, 0)
        
        let affineTransform = ProjectionTransform(CGAffineTransform(translationX: size.width / 2.0, y: size.height / 2.0))
        
        return ProjectionTransform(transform3d).concatenating(affineTransform)
    }
} //geo str
