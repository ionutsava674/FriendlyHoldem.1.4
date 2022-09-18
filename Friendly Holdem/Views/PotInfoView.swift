//
//  PotInfoView.swift
//  CardPlay
//
//  Created by Ionut on 28.08.2022.
//

import SwiftUI
import GameKit

struct PotInfoView: View {
    @Environment(\.dismiss) private var dism
    @ObservedObject var game: HoldemGame
    @ObservedObject var match: GKTurnBasedMatch
    
    var quittersWhoBet: [PokerPlayer] {
        game.allPlayers.filter({
            !$0.joiningGame
            && $0.placedInBet > 0
        }) //filt
    } //cv
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text("The bet is now \(game.currentBetSize) chips.")
                .font(.title.bold())
                .padding()
            VStack(alignment: .leading, spacing: 4) {
                ForEach(game.joiningPlayers, id: \.matchParticipantIndex) { player in
                    VStack {
                        if player.dropped {
                            Text("\( GameController.playerAlias(of: player, in: match) ) threw the hand. Had bet \(player.placedInBet) chips.")
                        } else {
                            VStack {
                                Text("\( GameController.playerAlias(of: player, in: match) ) bet \(player.placedInBet) chips.")
                                VStack {
                                    if player.isAllIn {
                                        Text("all in")
                                    }
                                    if game.stillNeedsToBet( player) {
                                        Text("still needs to bet")
                                    }
                                } //sub vs
                                    .offset(x: 10, y: 0)
                            } //evs
                        } //else
                    } //fe vs
                    .padding(3)
                } //fe
                ForEach(quittersWhoBet, id: \.matchParticipantIndex) { quitter in
                    Text(  GameController.LocalizednoJoinReason( for: quitter, in: match, withName: true, isLocal: false) )
                    Text("had bet \(quitter.placedInBet) chips.")
                .offset(x: 10, y: 0)
                } //fe 2
            } //vs
            Text("The total pot is \(game.totalPotSize) chips.")
                .font(.title.bold())
                .padding()
            Button {
                dism()
            } label: {
                Text("OK")
            }
            .padding(.bottom)

        } //vs
        .foregroundColor(.black)
        .doubelBorder(.white)
        .padding(1)
        .background(.cyan)
    } //body
} //str

extension View {
    @ViewBuilder
    func doubelBorder<T: ShapeStyle>(_ style: T) -> some View {
        self
            .border( style, width: 1)
            .padding(2)
            .border( style, width: 1)
    } //func
    func roundedDoubelBorder<T: ShapeStyle>(_ style: T, radius: CGFloat, lineWidth: CGFloat = 1.0) -> some View {
        self
            .overlay(content: {
                RoundedRectangle(cornerRadius: radius, style: .circular)
                    .stroke( style, lineWidth: lineWidth)
            })
            .padding(2 * lineWidth)
            .overlay(content: {
                RoundedRectangle(cornerRadius: radius + (2 * lineWidth), style: .circular)
                    .stroke( style, lineWidth: lineWidth)
            })
            .clipShape(RoundedRectangle(cornerRadius: radius + (2 * lineWidth), style: .circular) )
    } //func
    func insetRoundedDoubelBorder<T: ShapeStyle>(_ style: T, radius: CGFloat) -> some View {
        self
            .overlay(content: {
                RoundedRectangle(cornerRadius: radius - 2, style: .circular)
                    .stroke( style, lineWidth: 1)
                    .padding(2)
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: radius, style: .circular)
                            .stroke( style, lineWidth: 1)
                    }) //o2
            }) //o1
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .circular) )
    } //func
} //ext
