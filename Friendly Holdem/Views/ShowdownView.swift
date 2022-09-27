//
//  ShowdownView.swift
//  CardPlay
//
//  Created by Ionut on 03.07.2022.
//

import SwiftUI
import GameKit

struct ShowdownView: View {
    @EnvironmentObject var gch: GCHelper
    @ObservedObject var game: HoldemGame
    @ObservedObject var viewedBy: PokerPlayer
    @ObservedObject var match: GKTurnBasedMatch
    
    private var restOfPlayers: [PokerPlayer] {
        self.game.allPlayers.filter({ player in
            !self.game.lastShowdownStatus.winners.joined().contains(where: {
                $0.matchParticipantIndex == player.matchParticipantIndex
            })
            /*
            !self.game.lastShowdownStatus.winners.contains(where: { row in
                row.contains(where: { finisher in
                    finisher.matchParticipantIndex == player.matchParticipantIndex
                })
            })
             */
        }) //filt
    } //cv
    
    func listAliases( of playerList: [PokerPlayer]) -> String {
        GameLocalizer.listAliases(of: playerList, in: match)
    } //func
    var body: some View {
        ZStack {
            RadialGradient( colors: [
                Color( red: 0.1, green: 0.2, blue: 0.45),
                Color( red: 0.1, green: 0.45, blue: 0.2)
            ], center: UnitPoint(x: 0.3, y: 0.8), startRadius: 0.2 * 1000.0, endRadius: 0.6 * 1000.0)
                .brightness(0.09)
            VStack(alignment: .center, spacing: 0) { //main vs //others and tokens
                /*
                HStack {
                Button("test 1") {
                    Tester1.getInstance.testShowdown1()
                } //btn
                } //hs
                */
                List() {
                    ForEach( Array( game.self.lastShowdownStatus.winners.enumerated()), id: \.element.computedId) { (rankIndex, eachRank) in
                        ShowdownItem( resultPlace: eachRank, placeIndex: rankIndex, match: match)
                    } //fe
                    ForEach( restOfPlayers, id: \.matchParticipantIndex) { remainingPlayer in
                        Text( GameLocalizer.LocalizedShowdownStatus( for: remainingPlayer, in: match, withName: true, isLocal: false))
                    } //fe2
                    Section {
                        let multiPots = game.lastShowdownStatus.pots.count > 1
                        if multiPots {
                            Text("The total amount of \( game.lastShowdownStatus.pots.totalAmount() ) chips is made of \( game.lastShowdownStatus.pots.count ) pots:")
                        }
                        ForEach(game.lastShowdownStatus.pots, id: \.cutPoint) { eachPot in
                            Text("\(eachPot.shouldAccumulate) chips pot, \(eachPot.contributers.count) x \(eachPot.actualSize) chips bet by \(listAliases( of: eachPot.contributers)).")
                            Text("won by \(listAliases( of: eachPot.recipients ?? []))." +
                                 (((eachPot.recipients?.count ?? 0) > 1) ? " Each gets \(eachPot.shouldDistributeEach)." : "") )
                            Divider()
                        }
                    } header: {
                        Text("Chip recipients")
                    } //sect
                } //ls
                Text(game.lastShowdownStatus.printack())
                if viewedBy.joiningGame {
                    HStack {
                        //if let mt = match {
                            if match.isLocalPlayersTurn() {
                                Button {
                                    Task { await gch.gameCtl.actionActiveAcknowledge(in: game, and: match, by: viewedBy) }
                                } label: {
                                    Text("Alright, we can continue")
                                    .font(.largeTitle)
                                    .padding()
                                } //btn
                                .disabled( !self.gch.gameCtl.canShowActiveAcknowledge(for: viewedBy, of: game, in: match))
                            } else {
                                Button {
                                    Task { await gch.gameCtl.actionInactiveAcknowledge(in: game, and: match, by: viewedBy) }
                                } label: {
                                    Text("ok, we can continue")
                                    .font(.largeTitle)
                                    .padding()
                                } //btn
                                .disabled( !self.gch.gameCtl.canShowInactiveAcknowledge(for: viewedBy, of: game, in: match))
                            } //inactive
                        //} //good match
                    } //hs
                } //if joining
            } //vs
            .foregroundColor(.white)
        } //zs
    } //body
} //str

