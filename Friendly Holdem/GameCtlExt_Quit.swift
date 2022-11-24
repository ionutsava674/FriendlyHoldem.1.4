//
//  GameCtlExt_Quit.swift
//  CardPlay
//
//  Created by Ionut on 11.08.2022.
//

import Foundation
import GameKit

extension GameController {
    @MainActor func quit(_ match: GKTurnBasedMatch, with game: HoldemGame?) async -> Bool {
        //get latest version
        let toUseMatch = (try? await GKTurnBasedMatch.load( withID: match.matchID)) ?? match
        guard toUseMatch.isLocalPlayersTurn() else {
            return await quitOutOfTurn(in: toUseMatch)
        } //gua
        var tuGame = game
        if tuGame == nil {
            tuGame = GameTransition.getFinalGameFromTransition(toUseMatch.matchData)
        }
        return await QuitInTurn(in: toUseMatch, having: tuGame)
    } //func
    @MainActor private func forceEnd(_ match: GKTurnBasedMatch, with endData: Data) async -> Void {
        debugMsg_("ending")
        for participant in match.participants {
            if participant.matchOutcome == .none {
                participant.matchOutcome = .quit
            } //if
        } //for
        _ = try? await match.endMatchInTurn(withMatch: endData)
        debugMsg_("after")
    } //func
    @MainActor private func rawQuitInTurn( in match: GKTurnBasedMatch) async -> Bool {
        debugMsg_("raw quit")
        guard match.isLocalPlayersTurn()
              //let localIdx = match.localParticipantIndex()
        else {
            debugMsg_("no quit cond")
            return false
        }
        let nextParts = (match.participants.nextOthers( ofPlayer: GKLocalPlayer.local, includeAtEnd: false) ?? match.participants)
            .stillInMatch( includingWaiting: true)
    guard !nextParts.isEmpty else {
        await forceEnd(match, with: match.matchData ?? Data())
        return false
    }
    do {
        try await match.participantQuitInTurn(with: .quit, nextParticipants: nextParts, turnTimeout: GKTurnTimeoutNone, match: match.matchData ?? Data())
        debugMsg_("didq")
    } catch {
        debugMsg_(String(describing: error))
        return false
    }
    return true
    } //func
        @MainActor private func QuitInTurn( in match: GKTurnBasedMatch, having game: HoldemGame?) async -> Bool {
            debugMsg_("quitting in turn")
            guard match.isLocalPlayersTurn(),
                  let localIdx = match.localParticipantIndex()
            else {
                return false
            }
            guard let ugame = game
                  //let localPlayer = ugame.allPlayers.get( by: localIdx)
            else {
                return await rawQuitInTurn(in: match)
            } //gua
            var nextParts = ugame.generalNextPlayers( after: localIdx).stillJoiningGame
                .mapToParticipants( in: match)
                .stillInMatch( includingWaiting: true)
            if nextParts.isEmpty {
                nextParts = (match.participants.nextOthers( ofPlayer: GKLocalPlayer.local, includeAtEnd: false) ?? match.participants)
                    .stillInMatch( includingWaiting: true)
            }
            let newData = GameTransition.gameToSourcelessTransitionData( ugame) ?? (match.matchData ?? Data())
        guard !nextParts.isEmpty else {
            await forceEnd(match, with: newData)
            return false
        }
            do {
                try await match.participantQuitInTurn(with: .quit, nextParticipants: nextParts, turnTimeout: GKTurnTimeoutNone, match: newData)
                debugMsg_("didq")
            } catch {
                debugMsg_(String(describing: error))
                return false
            }
            return true
    } //func
    @MainActor private func quitOutOfTurn( in match: GKTurnBasedMatch) async -> Bool {
        debugMsg_("q oot")
        do {
            try await match.participantQuitOutOfTurn(with: .quit)
            debugMsg_("didq")
        } catch {
            debugMsg_("error quitting")
            debugMsg_(String(describing: error))
            return false
        }
        return true
    } //func
} //ext
