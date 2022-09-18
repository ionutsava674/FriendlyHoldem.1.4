//
//  CardStackIDlessView.swift
//  CardPlay
//
//  Created by Ionut on 04.07.2022.
//

import SwiftUI

struct CardStackIDlessView: View {
    //struct CardStackView: View {
        @ObservedObject var stack: CardStack
        
        let anim_ns: Namespace.ID
        let desiredCardWidth: CGFloat
        let desiredXSpacing, desiredYSpacing: CGFloat
        let fitInRect: Bool
        let holdAtAngle: Angle
        var onlyLastAccessible: Bool = false
        var asSeenBy: PokerPlayer.IndexType
        var backFacingText: String?
        var onlyShow: Int?
        
        func startAngle() -> Angle {
            stack.cards.count > 1 ?
                holdAtAngle : .zero
        }
        func incrementAngle() -> Angle {
            stack.cards.count <= 1 ?
                .zero : (-holdAtAngle * 2) / Double(stack.cards.count - 1)
        }
        func computeOffset( rectSize: CGSize) -> CGPoint {
            let willUseSize = willFitInRectSize(width: desiredCardWidth, rectSize: rectSize)
            let x_offset = desiredXSpacing / desiredCardWidth * willUseSize.width
            let y_offset = desiredYSpacing / desiredCardWidth * willUseSize.width
            guard fitInRect else {
                return CGPoint(x: x_offset, y: y_offset)
            }
            let fitSize = willFitInRectSize( width: desiredCardWidth, rectSize: rectSize)
            let limit_xo = maxCardOffset(availableRectLength: rectSize.width, usingCardLength: fitSize.width)
            var min_xo = min( limit_xo, abs( x_offset))
            if x_offset < 0 {
                min_xo = -min_xo
            }
            let limit_yo = maxCardOffset(availableRectLength: rectSize.height, usingCardLength: fitSize.height)
            var min_yo = min( limit_yo, abs( y_offset))
            if y_offset < 0 {
                min_yo = -min_yo
            }
            return CGPoint(x: min_xo, y: min_yo)
        }
        func maxCardOffset( availableRectLength: CGFloat, usingCardLength: CGFloat) -> CGFloat {
            stack.cards.count <= 1 ? 0.0
                : ((availableRectLength - usingCardLength) / CGFloat(stack.cards.count - 1))
        }
        func cardStart(_ offset: CGFloat) -> CGFloat {
            -offset * CGFloat(stack.cards.count - 1) / 2
        }
        func willFitInRectSize( width: CGFloat, rectSize: CGSize) -> CGSize {
            guard rectSize.width > 0 && rectSize.height > 0 else {
                return .zero
            }
            let retWi = min( width, rectSize.width)
            let retHe = retWi * RawCard.cardSizeRatio
            return retHe <= rectSize.height ?
                CGSize(width: retWi, height: retHe)
                : CGSize(width: retWi / retHe * rectSize.height, height: rectSize.height)
        } //func
        var body: some View {
            //VStack {
            GeometryReader { geo in
                let offsetPoint = computeOffset(rectSize: geo.size)
                let startX = cardStart(offsetPoint.x)
                let startY = cardStart(offsetPoint.y)
                
                let stAng = startAngle()
                let incAng = incrementAngle()
                
                let toShowCards = stack.cards.suffix(onlyShow ?? stack.cards.count)
                let toShowCardsCount = toShowCards.count
            ZStack {
                ForEach( Array( toShowCards.enumerated()), id: \.element.id) { (index, card) in
                    CardView(card: card, cardWidth: willFitInRectSize(width: desiredCardWidth, rectSize: geo.size).width,
                             faceDown: !stack.canBeSeen( by: asSeenBy),
                             backFacingText: backFacingText )
                        //.matchedGeometryEffect( id: card.id, in: anim_ns)
                        .rotationEffect( stAng + incAng * Double( index))
                        .accessibilityHidden(onlyLastAccessible && index != (toShowCardsCount - 1))
                        .allowsHitTesting(!onlyLastAccessible || index == (toShowCardsCount - 1))
                        .offset( x: startX + offsetPoint.x * CGFloat( index),
                                y: startY + offsetPoint.y * CGFloat( index))
            } //fe
            } //zs
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
            } //geo
            //} //vs
        } //body
    } //stk
