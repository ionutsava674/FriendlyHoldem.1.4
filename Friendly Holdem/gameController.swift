//
//  gameController.swift
//  CardPlay
//
//  Created by Ionut on 17.08.2021.
//

import Foundation
import GameKit
import SwiftUI

typealias GameMatch = (gameModel: HoldemGame, match: GKTurnBasedMatch)
class GameController: ObservableObject {
    typealias CompletionCallback = () -> Void
    
    var busy: Int = 0 {
        didSet {
            if busy == 0 {
                if wasBusyWhile != 0 {
                    //debugMsg_("was busy")
                    //check changes
                    Task {
                        await GCHelper.helper.refreshCurrentMatch()
                    } //tk
                    wasBusyWhile = 0
                } //if
            } //if
        } //ds
    } //busy
    var wasBusyWhile: Int = 0
    
    @MainActor func actionAction3( for game: HoldemGame, and match: GKTurnBasedMatch, action: PokerPlayerAction, by playerIdx: PokerPlayer.IndexType, to amount: ChipsCountType?) async -> Void {
        debugMsg_(" As Acting for \(playerIdx)")
        guard busy == 0,
              let checkGame = GCHelper.helper.currentGame,
              let checkMatch = GCHelper.helper.currentMatch,
              checkGame === game,
checkMatch === match,
              game.ActingPlayaMenu.contains( where: {
                  $0.id == action.id
              }),
              match.isLocalPlayersTurn(),
              let firstActing = game.actingOrder.first,
              firstActing == playerIdx,
              let playerPart = match.participants.get( index: playerIdx),
              playerPart.player == GKLocalPlayer.local,
              let player = game.joiningPlayers.get( by: playerIdx),
              (player.joiningGame && !player.dropped)
        else {
                    debugMsg_("no action condition")
            return
        } //gua
        busy = 2
        defer { busy = 0 }

        guard let transition = createGameSnapshot( from: game, with: .none) else {
            return
        }
        try? await Task.sleep(seconds: 0.3)
        switch action.type {
        case .drop:
            game.drop3( for: player)
        case .check:
            guard game.check3( for: player) else {
                GCHelper.helper.displayError(msg: "Unable to perform action.")
                return
            }
        case .call:
            guard game.call3( for: player) else {
                GCHelper.helper.displayError(msg: "Unable to perform action.")
                return
            }
        case .stay:
            guard game.stay3( for: player) else {
                GCHelper.helper.displayError(msg: "Unable to perform action.")
                return
            }
        case .allInBet:
            guard game.allInBet3( for: player) else {
                GCHelper.helper.displayError(msg: "Unable to bet all in")
                return
            }
        case .bet, .raise:
            guard let amount = amount else {
                GCHelper.helper.displayError(msg: "Invalid amount")
                return
            }
            guard game.raise3( by: player, to: amount) else {
                GCHelper.helper.displayError(msg: "Could not raise to \(amount) chips.")
                //debugMsg_("Could not raise to \(amount) chips.")
                return
            } //gua
        } //swi
        _ = await game.afterActionCheck3(actedBy: playerIdx, advanceActingOrderIfInRound: true)
        _ = await giveTurnBackAsync(gameModel: game, in: match, with: transition, players: game.actingOrder)
    } //func
    @MainActor func checkAndSetAcknowledgeExchangesAsync2( in match: GKTurnBasedMatch, and game: HoldemGame) -> Bool {
        guard game.gameState == .presentingShowdown
              //, let localIdx = match.localParticipantIndex()
        else {
            return false
        }
        var found = false
        for player in game.allPlayers {
            guard !game.lastShowdownStatus.acknowledgedBy( player.matchParticipantIndex),
                    let _ = match.findExchange( from: player.matchParticipantIndex, with: game.lastShowdownStatus.id) else {
                continue
            }
            //debugMsg_("found ex")
            found = true
            game.lastShowdownStatus.acknowledge( by: player.matchParticipantIndex)
        } //for
        return found
    } //func
    @MainActor func checkAndSetWhoLeft( in game: HoldemGame, and match: GKTurnBasedMatch) -> Bool {
        let whoLeft = game.joiningPlayers.filter({
            !(match.participants.get( index: $0.matchParticipantIndex)?.status.meansStillInGame( includingWaiting: true) ?? false)
        }) //filt
        guard !whoLeft.isEmpty else {
            return false
        }
        for player in whoLeft {
            player.setNotJoining( reason: .quit)
            match.participants.get( index: player.matchParticipantIndex)?.matchOutcome = .quit
            game.playerJustQuit( player: player)
            debugMsg_("unjoined \(player.matchParticipantIndex), \(ParticipantLocalization.didOutcomeString(for: match.participants[player.matchParticipantIndex], isLocal: false) )")
        } //for
        return true
    } //func
    @MainActor func checkAndSetTimeouts( in game: HoldemGame, and match: GKTurnBasedMatch) -> Bool {
        let timeOuts = game.allPlayers.filter({
            match.participants.get( index: $0.matchParticipantIndex)?.matchOutcome == .timeExpired
        }) //filt
        guard !timeOuts.isEmpty else {
            return false
        }
        for player in timeOuts {
            //player.setNotJoining( reason: .quit)
            //match.participants.get( index: player.matchParticipantIndex)?.matchOutcome = .quit
            //game.playerJustQuit( player: player)
            debugMsg_("found timeout \(player.matchParticipantIndex), \(ParticipantLocalization.didOutcomeString(for: match.participants[player.matchParticipantIndex], isLocal: false) )")
            debugMsg_("joining \(String.init(describing: player.joiningGame))")
            debugMsg_("in match: \( String(describing: match.participants.get( index: player.matchParticipantIndex)?.status.meansStillInGame(includingWaiting: true)) )")
        } //for
        return true
    } //func
    @MainActor func actionEvaluateGame( _ game: HoldemGame, and match: GKTurnBasedMatch) async -> Void {
        busy = 1
        defer { busy = 0 }
        guard let localGamePlayer = game.allPlayers.get( by: match.localParticipantIndex() ?? -1) else {
            return
        }
        var changed = checkAndSetWhoLeft( in: game, and: match)
        if checkAndSetTimeouts( in: game, and: match) {
            changed = true
        }
        if checkAndSetAcknowledgeExchangesAsync2( in: match, and: game) {
            changed = true
        }
        if await game.evaluateGame( by: localGamePlayer) {
            //clear active exc
            changed = true
            await replyToActiveExchanges( in: match, and: game)
        }
        if changed
            || ( game.gameState == .finalShow && match.isOpenOrMatching() ) {
            _ = await giveTurnBackAsync( gameModel: game, in: match, with: nil, players: game.actingOrder)
        }
    } //func
    
} //class gc
