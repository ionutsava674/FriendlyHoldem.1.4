//
//  NeedToAcknowledgeView.swift
//  Friendly Holdem
//
//  Created by Ionut on 29.09.2022.
//

import SwiftUI
import GameKit

struct NeedToAcknowledgeView: View {
    @ObservedObject var game: HoldemGame
    @ObservedObject var viewedBy: PokerPlayer
    @ObservedObject var match: GKTurnBasedMatch
    
    func patchedAcknowledged( by playerIdx: PokerPlayer.IndexType) -> Bool {
        game.lastShowdownStatus.acknowledgedBy(playerIdx)
        || (match.findExchange( from: playerIdx, with: game.lastShowdownStatus.id) != nil)
    } //func
    var sortedPlayers: [PokerPlayer] {
        game.whoNeedsToAcknowledge().sorted(by: {
            let p1a = patchedAcknowledged( by: $0.matchParticipantIndex)
            let p2a = patchedAcknowledged( by: $1.matchParticipantIndex)
            if p1a != p2a {
                return p2a
            } //if
            return true
        }) //sort
    } //cv
    
    var body: some View {
        VStack(alignment: .leading) {
            Divider()
            ForEach(sortedPlayers, id: \.matchParticipantIndex) {eachPlayer in
                HStack(alignment: .center) {
                    Text(GameLocalizer.playerAlias( of: eachPlayer, in: match))
                        .padding(.horizontal)
                    Text(patchedAcknowledged( by: eachPlayer.matchParticipantIndex)
                         ? "ready to continue"
                         : "not ready yet"
                    )
                } //hs
                .accessibilityElement(children: .combine)
            } //fe
        } //vs
    } //body
} //str
