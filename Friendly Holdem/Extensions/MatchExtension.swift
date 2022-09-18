//
//  TurnBasedMatchExtension.swift
//  CardPlay
//
//  Created by Ionut on 10.11.2021.
//

import Foundation
import GameKit

extension GKTurnBasedMatch: Identifiable {
    func lastActionDate() -> Date {
        
        return participants.reduce( creationDate) { partialResult, eachPart in
            var toReturn = Swift.max(partialResult, eachPart.timeoutDate ?? partialResult)
            toReturn = Swift.max(toReturn, eachPart.lastTurnDate ?? toReturn)
            return toReturn
        } //red
    } //func
    //var id: String { self.matchID }
    func stillNeedParticipants() -> Bool {
        participants.contains(where: {
            [GKTurnBasedParticipant.Status.matching, GKTurnBasedParticipant.Status.invited]
                .contains($0.status)
        })
    } //var
    func isNewlyCreatedMatch() -> Bool {
        self.localIsOnlyActiveParticipant()
        && self.isLocalPlayersTurn()
        && (self.matchData?.isEmpty ?? true)
        && !hasDoneParticipants()
    } //func
    func hasDoneParticipants() -> Bool {
        participants.contains(where: {
            [GKTurnBasedParticipant.Status.declined, GKTurnBasedParticipant.Status.done]
                .contains($0.status)
        })
    } //func
    func hasUnknownMatchingParticipants() -> Bool {
        participants.contains(where: {
            [GKTurnBasedParticipant.Status.matching]
                .contains($0.status)
        })
    } //func
    func localIsOnlyActiveParticipant() -> Bool {
        let present = participants.filter({
            $0.status == .active
        })
        return present.count == 1
        && present.first?.player == GKLocalPlayer.local
    } //var
    func isOpenOrMatching() -> Bool {
        [GKTurnBasedMatch.Status.open, .matching].contains( status)
    }
    func isLocalPlayersTurn() -> Bool {
        guard isOpenOrMatching() else {
            return false
        }
        return currentParticipant?.player == GKLocalPlayer.local
    } //var
    func localParticipantIndex() -> Array<GKTurnBasedParticipant>.Index? {
        participants.firstIndex(where: {
            $0.player == GKLocalPlayer.local
        }) //clo
    } //func
    func localParticipant() -> GKTurnBasedParticipant? {
        participants.first(where: {
            $0.player == GKLocalPlayer.local
        }) //clo
    } //func
} //ext
