//
//  GameCtlExt_newAsync.swift
//  CardPlay
//
//  Created by Ionut on 13.08.2022.
//

import Foundation
import GameKit
extension GameController {
    static let noJoinToOutcome: [PokerPlayer.NoJoinReason: GKTurnBasedMatch.Outcome] = [
        .won: .won,
        .quit: .quit,
        .timeOut: .timeExpired,
        .first: .first,
        .tied: .tied
    ]
    @MainActor private func gracefullyWrapUpAsync( in game: HoldemGame, and match: GKTurnBasedMatch) async -> Bool {
        guard match.isLocalPlayersTurn(),
              game.gameState == .finalShow else {
            return false
        }
        debugMsg_("wrapping up")
        for (index, part) in Array(match.participants.enumerated()) {
            guard part.matchOutcome == .none else {
                continue
            }
            guard let player = game.allPlayers.get( by: index) else {
                part.matchOutcome = .lost
                continue
            }
            part.matchOutcome = Self.noJoinToOutcome[player.notJoiningReason] ?? .lost
            /*
            switch player.notJoiningReason {
            case .won:
                part.matchOutcome = .won
            case .quit:
                part.matchOutcome = .quit
            case .timeOut:
                part.matchOutcome = .timeExpired
            default:
                part.matchOutcome = .lost
            } //swi
             */
        } //for
        guard let dataToSend = GameTransition.gameToSourcelessTransitionData(game) else {
            return false
        }
        do {
            try await match.endMatchInTurn(withMatch: dataToSend)
            game.objectWillChange.send()
            match.objectWillChange.send()
        } catch {
            return false
        }
        return true
    } //func
    @MainActor internal func giveTurnBackAsync ( gameModel: HoldemGame, in match: GKTurnBasedMatch, with previousState: GameTransition?, players: [PokerPlayer.IndexType]) async -> Bool {
        guard gameModel.gameState != .finalShow else {
            return await gracefullyWrapUpAsync( in: gameModel, and: match)
        }
        guard match.isLocalPlayersTurn(),
              let newGameData = gameModel.toJSON()
        else {
            return false
        }
        let transition = previousState ?? .newEmptyTransition()
        transition.toState = newGameData
        //debugMsg_("dst players " + players.map({ "\($0)" }).joined(separator: " "))
        if await GCHelper.helper.sendGameTransitionBackAsync( transition, matchCheck: match, to: players, timeOut: GKTurnTimeoutNone) {
            match.objectWillChange.send()
            return true
        }
        return false
    } //func
    @MainActor func resolveCompletedExchanges( in match: GKTurnBasedMatch, and game: HoldemGame) async -> Void {
        guard let completed = match.completedExchanges else {
            return
        }
        guard let newData = GameTransition.gameToSourcelessTransitionData( game) else {
            return
        }
        try? await match.saveMergedMatch( newData, withResolvedExchanges: completed)
    } //func
    func createGameSnapshot( from gameModel: HoldemGame, with action: GameTransitionAction) -> GameTransition? {
        guard let gameData = gameModel.toJSON() else {
            return nil
        }
        return GameTransition(actionTaken: action, reEnact: true, fromState: gameData)
    } //func
} //ext
