//
//  ParticipantArrayExtension.swift
//  CardPlay
//
//  Created by Ionut on 10.11.2021.
//

import Foundation
import GameKit

extension GKTurnBasedParticipant {
    func name( in match: GKTurnBasedMatch, preferredDefaultValue: String? = nil) -> String {
        if let alias = player?.alias {
            return alias
        }
        if let def = preferredDefaultValue {
            return def
        }
        if let index = match.participants.firstIndex( of: self) {
            return String.localizedStringWithFormat("player %d", index + 1)
        }
        return NSLocalizedString("unknown player", comment: "unknown player alias")
    } //func
} //ext
extension GKTurnBasedParticipant.Status {
    func meansStillInGame( includingWaiting: Bool) -> Bool {
        if includingWaiting {
            return [Self.active, Self.matching, Self.invited]
                .contains(self)
        }
        return self == .active
    } //func
    var description: String {
        switch self {
        case .matching:
            return "waiting to join"
        case .done:
            return "left the game"
        case .active:
            return "joined"
        case .declined:
            return "declined the invitation"
        case .invited:
            return "invited"
        //case .unknown:
        default:
            return "unknown"
        } //swi
    } //cv
} //ext
typealias ParticipantIndex = Array<GKTurnBasedParticipant>.Index

extension Array where Element == GKTurnBasedParticipant {
    func mapFromIndices( _ idxs: [ParticipantIndex]) -> Self {
        idxs.compactMap({
            self.get( index: $0)
        })
    } //func
    func stillInMatch( includingWaiting: Bool) -> Self {
        filter({
            $0.status.meansStillInGame( includingWaiting: includingWaiting)
        })
    }
    func thatCanJoin ( includingWaiting: Bool) -> [GKTurnBasedParticipant] {
        filter({
            $0.status.meansStillInGame( includingWaiting: includingWaiting)
        })
    } //func
    func get( index: Array<GKTurnBasedParticipant>.Index?) -> GKTurnBasedParticipant? {
        guard let idx = index else {
            return nil
        }
        guard indices.contains(idx) else {
            return nil
        }
        return self[idx]
    }
    func nextOthers( ofPlayer player: GKPlayer, includeAtEnd: Bool) -> [Element]? {
        nextOthers(ofFirst: {
            $0.player == player
        }, includeAtEnd: includeAtEnd)
    } //func
} //ext
