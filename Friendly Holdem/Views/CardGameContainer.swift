//
//  GameContainer.swift
//  CardPlay
//
//  Created by Ionut on 03.12.2021.
//

import SwiftUI
import GameKit

struct CardGameContainerView: View {
    //@EnvironmentObject var gch: GCHelper
    @ObservedObject var gameModel: HoldemGame
    @ObservedObject var viewedBy: PokerPlayer
    @ObservedObject var match: GKTurnBasedMatch
    @Namespace var ns_cgcviewid
    
    @State private var gameTabSelection = 0
    
    private let animationSlideWidth: CGFloat = 280
    private let animationRotationAngle: Double = 90

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    func isLandscape(_ geo: GeometryProxy) -> Bool {
        geo.size.width > geo.size.height
    } //func
    
    var body: some View {
        GeometryReader { geo in
            if isLandscape( geo)
                && horizontalSizeClass == .regular {
                HStack{
                    PokerTableView(game: gameModel, viewedBy: viewedBy, match: match)
                        .matchedGeometryEffect(id: "cgclsvid\( match.matchID)", in: self.ns_cgcviewid)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    RadialGradient( colors: [
                        Color(red: 0.1, green: 0.2, blue: 0.45),
                        Color(red: 0.1, green: 0.45, blue: 0.2)
                    ], center: UnitPoint(x: 0.3, y: 0.8), startRadius: 0.2 * 1000.0, endRadius: 0.6 * 1000.0)
                        .brightness(0.15)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } //hhs
            }
            else {
        VStack {
            if gameTabSelection == 0 {
                    PokerTableView(game: gameModel, viewedBy: viewedBy, match: match)
                    .matchedGeometryEffect(id: "cgcpvid\( match.matchID)", in: self.ns_cgcviewid)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .transition(.modifier(
                        active: SlideAnd3DRotateModifier(slideBy: CGSize(width: -animationSlideWidth, height: 0), rotateBy: animationRotationAngle),
                        identity: SlideAnd3DRotateModifier(slideBy: .zero, rotateBy: 0)))
            }
                if gameTabSelection == 1 {
                    RadialGradient( colors: [
                        Color(red: 0.1, green: 0.2, blue: 0.45),
                        Color(red: 0.1, green: 0.45, blue: 0.2)
                    ], center: UnitPoint(x: 0.3, y: 0.8), startRadius: 0.2 * 1000.0, endRadius: 0.6 * 1000.0)
                        .brightness(0.15)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .transition(.modifier(
                        active: SlideAnd3DRotateModifier(slideBy: CGSize(width: animationSlideWidth, height: 0), rotateBy: -animationRotationAngle),
                        identity: SlideAnd3DRotateModifier(slideBy: .zero, rotateBy: 0)))
            } //swi
            HStack {
                Button("cards") {
                    //withAnimation(.linear(duration: self.dur)) {
                    //withAnimation(.spring()) {
                        self.gameTabSelection = 0
                    //}
                }
                Button("details") {
                    //withAnimation(.linear(duration: self.dur)) {
                    //withAnimation(.spring()) {
                        self.gameTabSelection = 1
                    //} //wa
                } //btn
            } //hs
        } //vs
        .animation(.spring(), value: gameTabSelection)
            } //split with tabs
        } //geo
    } //body
} //str
struct SlideAnd3DRotateModifier: ViewModifier {
    let slideBy: CGSize
    let rotateBy: CGFloat
    
    func body(content: Content) -> some View {
        content
            .rotation3DEffect( Angle.degrees( rotateBy), axis: (x: 0, y: 1, z: 0))
            .offset( slideBy)
            .clipped()
    } //body
} //modif str
