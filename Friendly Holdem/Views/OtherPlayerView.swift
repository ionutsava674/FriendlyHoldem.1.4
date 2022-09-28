//
//  OtherPlayerView.swift
//  CardPlay
//
//  Created by Ionut on 27.08.2022.
//

import SwiftUI
import GameKit

struct OtherPlayerView: View {
    @ObservedObject var otherPlayer: PokerPlayer
    @ObservedObject var game: HoldemGame
    @ObservedObject var viewedBy: PokerPlayer
    @ObservedObject var match: GKTurnBasedMatch
    let anim_ns: Namespace.ID
    let desiredCardWidth: CGFloat

    var body: some View {
        let otherAlias = GameLocalizer.playerAlias( of: otherPlayer, in: match)
        VStack(alignment: .center, spacing: 0) {
            Text(otherAlias.capitalizingFirst())
                //.accessibilityHidden(true)
        CardStackView( stack: otherPlayer.hand, anim_ns: anim_ns,
                       desiredCardWidth: desiredCardWidth, desiredXSpacing: desiredCardWidth * 0.8, desiredYSpacing: 0,
                       fitInRect: true, holdAtAngle: .degrees(-5),
                       asSeenBy: viewedBy.matchParticipantIndex)
        .rotation3DEffect(otherPlayer.dropped ? .degrees(70) : .zero, axis: (x: 1, y: 0, z: 0), anchor: .bottom, anchorZ: 0, perspective: 1)
                //.modifier(StackGlowFlasher2(activeState: game.actingOrder.first == otherPlayer.matchParticipantIndex, radius: 27, color: .white) )
            
            DealerToken( forPlayer: otherPlayer, game: game, tokenSize: 17)
            
            if otherPlayer.joiningGame {
                JumpingText( text: "🪙 \(otherPlayer.placedInBet)", uniqueId: "\(match.matchID)BetFrom\(otherAlias)")
                    .font( otherPlayer.dropped ? .subheadline : .subheadline.italic())
            } else {
                Text(  GameLocalizer.LocalizednoJoinReason( for: otherPlayer, in: match, withName: false, isLocal: false).capitalizingFirst() )
            } //chips or info
        } //vs
        .accessibilityElement(children: .ignore)
        .accessibilityLabel( GameLocalizer.localizedInGameStatus( for: otherPlayer, in: match, isLocal: false) )
        .conditionalAxValue( otherPlayer.joiningGame, valueDescription: Text(" \( GameLocalizer.itsHisTurn( of: otherPlayer, in: game, and: match) ) " ))
        //.conditionalAxAction( condition:  game.actAsDealer == otherPlayer.matchParticipantIndex,
                             //named: Text( "\( GameLocalizer.dealerStatus( of: otherPlayer, in: game) )" ), { })
    } //body
} //str
