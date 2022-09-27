//
//  FinalShowView.swift
//  CardPlay
//
//  Created by Ionut on 09.07.2022.
//

import SwiftUI
import GameKit

struct FinalShowView: View {
    @EnvironmentObject var gch: GCHelper
    @ObservedObject var game: HoldemGame
    @ObservedObject var viewedBy: PokerPlayer
    @ObservedObject var match: GKTurnBasedMatch
    
    let topRatio: CGFloat = 2/10
    //let midRatio: CGFloat = 4/10
    let lowRatio: CGFloat = 4/10
    var winColor: Color { Color.cyan.bright( amount: 0.8) }
    var loseColor: Color { Color.red.bright( amount: 0.55) }
    var borderColor: Color {
        (self.game.endStatus.finishOrder.first ?? [PokerPlayer]()).contains(where: {
            $0.matchParticipantIndex == viewedBy.matchParticipantIndex
        }) ? winColor : loseColor
    } //cv
    
    func listAliases( of playerList: [PokerPlayer]) -> String {
        GameLocalizer.listAliases( of: playerList, in: match)
    } //func
    var body: some View {
        ZStack {
            Color.black
            GeometryReader { geo in
                VStack {
                    borderColor
                        .mask( LinearGradient( colors: [.black, .black, .clear], startPoint: .top, endPoint: .bottom))
                        .frame( height: geo.size.height * topRatio, alignment: .bottom)
                    VStack {
                    Text("Game over")
                        .font(.largeTitle.bold())
                        .padding(.bottom)
                    //ScrollView([.vertical], showsIndicators: true) {
                        ForEach( Array( game.endStatus.finishOrder.enumerated()), id: \.element.computedId) { (rowIndex, eachRow) in
                            FinalShowRow(row: eachRow, rowIndex: rowIndex, game: game, viewedBy: viewedBy, match: match)
                        } //fe
                    //} //sv
                    //.frame(width: .infinity, alignment: .center)
                } //mid vs
                    .frame(maxHeight: .infinity, alignment: .center)
                    //LinearGradient( colors: [.black, borderColor, borderColor, borderColor], startPoint: .top, endPoint: .bottom)
                    borderColor
                        .mask( LinearGradient( colors: [.clear, .clear, .black, .black, .black], startPoint: .top, endPoint: .bottom))
                        .frame( height: geo.size.height * lowRatio, alignment: .top)
                } //geo vs
            } //geo
            .foregroundColor(.white)
        } //zs
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .transition( .opacity )
    } //body
} //str

struct FinalShowRow: View {
    let row: [PokerPlayer]
    let rowIndex: Int
    @ObservedObject var game: HoldemGame
    @ObservedObject var viewedBy: PokerPlayer
    @ObservedObject var match: GKTurnBasedMatch
    var body: some View {
        VStack {
            if row.count == 1 {
                if let first = row.first {
                    switch first.notJoiningReason {
                    case .won:
                        Text("The winner is \( GameLocalizer.playerAlias(of: first, in: match) ) with \( first.chips ) chips")
                    case .first:
                        Text("\( GameLocalizer.playerAlias(of: first, in: match) ), \( first.chips ) chips left")
                    case .lost:
                        Text("\( GameLocalizer.playerAlias(of: first, in: match) ) lost, with \( first.chips ) chips left")
                    case .timeOut:
                        Text("\( GameLocalizer.playerAlias(of: first, in: match) ) did not act in time and was kicked out. \( first.chips ) chips left")
                    case .quit:
                        Text("\( GameLocalizer.playerAlias(of: first, in: match) ) quit, with \( first.chips ) chips left")
                    default:
                        Text("\( GameLocalizer.playerAlias(of: first, in: match) ), \( first.chips ) chips")
                    } //swi
                }//
            } //single
            else {
                Text("\(NumberFormatter.ordinalString(rowIndex + 1) ?? "") place, \( GameLocalizer.listAliases( of: row, in: match) ), with \( row.first?.chips ?? 0 )")
            } //more
        } //vs
        .padding(4)
    } //body
} //str

extension Color {
    func bright( amount: CGFloat) -> Self {
        let u: UIColor = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, o: CGFloat = 0
        if u.getHue(&h, saturation: &s, brightness: &b, alpha: &o) {
            let db = Swift.min(1.0, Swift.max(0.0, b * amount))
            return Color( hue: h, saturation: s, brightness: db, opacity: o)
        }
        return self
    } //func
} //ext
