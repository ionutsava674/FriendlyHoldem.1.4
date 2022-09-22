//
//  PotInfoView.swift
//  CardPlay
//
//  Created by Ionut on 28.08.2022.
//

import SwiftUI
import GameKit

struct PotInfoView: View {
    @Binding var isPresented: Bool
    //@Environment(\.dismiss) private var dism
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
                //dism()
                //withAnimation {
                    self.isPresented = false
                //}
            } label: {
                Text("OK")
                    .font(.title.bold())
                    .padding(.horizontal)
                    .padding()
                    .accessibilityElement(children: .combine)
            }
            .padding(.bottom)

        } //vs
        .foregroundColor(.white)
        .doubleBorder(.white, lineWidth: 2, withBackground: .clear)
        .padding(2)
        .background(.cyan.bright( amount: 0.8))
    } //body
} //str

