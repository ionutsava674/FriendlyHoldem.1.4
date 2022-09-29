//
//  GameCtlExt_Showdown.swift
//  CardPlay
//
//  Created by Ionut on 10.08.2022.
//

import Foundation
import GameKit

extension GameController {
    
    @MainActor func actionInactiveAcknowledge( in game: HoldemGame, and match: GKTurnBasedMatch, by player: PokerPlayer) async -> Void {
        guard canShowInactiveAcknowledge(for: player, of: game, in: match),
              let curPart = match.currentParticipant,
              let exchangeData = (try? JSONEncoder().encode( game.lastShowdownStatus.id))
        else {
            return
        }
        do {
            try await match.sendExchange( to: [curPart], data: exchangeData, localizableMessageKey: "%@ is ready to continue", arguments: [ GameLocalizer.playerAlias(of: player, in: match, preferredDefault: nil, unknownIndexDefault: String(localized: "Player")) ], timeout: GKExchangeTimeoutNone)
            game.objectWillChange.send()
        } catch {
            debugMsg_("exchange send error")
        } //do
    } //func
    func canShowInactiveAcknowledge( for player: PokerPlayer, of game: HoldemGame, in match: GKTurnBasedMatch) -> Bool {
        guard game.gameState == .presentingShowdown
              , !game.lastShowdownStatus.acknowledgedBy( player.matchParticipantIndex)
        else {
            return false
        }
        guard !match.isLocalPlayersTurn(),
           match.findExchange( from: player.matchParticipantIndex, with: game.lastShowdownStatus.id) == nil else {
            return false
        }
        return true
    } //func
    @MainActor func actionActiveAcknowledge( in game: HoldemGame, and match: GKTurnBasedMatch, by player: PokerPlayer) async -> Void {
        guard game.gameState == .presentingShowdown
                , match.isLocalPlayersTurn()
                , let localIdx = match.localParticipantIndex()
                , !game.lastShowdownStatus.acknowledgedBy( localIdx)
        else {
            return
        }
        busy = 3
        defer { busy = 0 }
        game.lastShowdownStatus.acknowledge( by: localIdx)
        if game.allJoiningAcknowledged( in: game.lastShowdownStatus) {
            await game.exitPresentingShowdown()
            _ = await giveTurnBackAsync(gameModel: game, in: match, with: nil, players: game.actingOrder)
        }
        else {
            _ = await giveTurnBackAsync(gameModel: game, in: match, with: nil, players: [])
        }
    } //func
    func canShowActiveAcknowledge( for player: PokerPlayer, of game: HoldemGame, in match: GKTurnBasedMatch) -> Bool {
        guard game.gameState == .presentingShowdown
              , !game.lastShowdownStatus.acknowledgedBy( player.matchParticipantIndex)
        else {
            return false
        }
        guard match.isLocalPlayersTurn() else {
            return false
        }
        return true
    } //func
    @MainActor private func setQuittersToNonJoiners(in game: HoldemGame, and match: GKTurnBasedMatch) -> Int {
        let whoLeft = game.joiningPlayers.filter({
            let isInMatch = match.participants.get( index: $0.matchParticipantIndex)?.status.meansStillInGame( includingWaiting: true) ?? false
            return !isInMatch
        }) //filt
        for player in whoLeft {
            player.setNotJoining( reason: .quit)
            match.participants.get( index: player.matchParticipantIndex)?.matchOutcome = .quit
            //game.playerJustQuit( player: player)
        } //for
        return whoLeft.count
    } //func
    private func setLosersToParticipantOutcome(in game: HoldemGame, and match: GKTurnBasedMatch) -> Void {
        let outOfGame = game.allPlayers.filter({
            !$0.joiningGame
        }).mapToParticipants( in: match)
            .filter({
                $0.status.meansStillInGame( includingWaiting: true)
                || $0.matchOutcome == .none
            }) //filt
        debugMsg_("setting outcome for \(outOfGame.count) players " + match.printOutcomes())
        for loser in outOfGame {
            loser.matchOutcome = .lost
            //loser.status = .done
        } //for
        debugMsg_(match.printOutcomes())
    } //func
    @MainActor func replyToActiveExchanges( in match: GKTurnBasedMatch, and game: HoldemGame) async -> Void {
        guard game.gameState == .presentingShowdown,
              match.isLocalPlayersTurn() else {
            return
        } //gua
        for exchange in match.findActiveExchanges(with: nil) {
            try? await exchange.reply(withLocalizableMessageKey: "beginning new deal", arguments: [], data: Data())
        }
        debugMsg_("3 " + match.printOutcomes())
    } //func
} //ext
