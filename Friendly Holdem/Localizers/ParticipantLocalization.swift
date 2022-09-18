//
//  ParticipantLocalization.swift
//  CardPlay
//
//  Created by Ionut on 24.06.2022.
//

import Foundation
import GameKit

enum ParticipantLocalizationOld {
    static func didOutcomeString( for participant: GKTurnBasedParticipant, isLocal isl: Bool) -> String {
        //let isl = participant.player == GKLocalPlayer.local
        switch participant.matchOutcome {
        case .lost:
            return isl ? NSLocalizedString("lost", comment: "you lost") : NSLocalizedString("lost", comment: "has lost")
        case .none:
            return isl ? NSLocalizedString("playing", comment: "you are playing") : NSLocalizedString("playing", comment: "is playing")
        case .quit:
            return isl ? NSLocalizedString("quit", comment: "you quit") : NSLocalizedString("quit", comment: "he quit")
        case .tied:
            return isl ? NSLocalizedString("tied", comment: "you tied") : NSLocalizedString("tied", comment: "he tied")
        case .timeExpired:
            return isl ? NSLocalizedString("timed out", comment: "you timed out") : NSLocalizedString("timed out", comment: "he timed out")
        case .won:
            return isl ? NSLocalizedString("won", comment: "you won") : NSLocalizedString("won", comment: "he won")
        default:
            return ""
        } //swi
    } //func
    static func Statusstring( forOptional participant: GKTurnBasedParticipant?, isLocal isl: Bool, isCurrent isc: Bool, showOutcome: Bool = false, nilValue: String = "") -> String {
        guard let part = participant else {
            return nilValue
        }
        return Statusstring(for: part, isLocal: isl, isCurrent: isc, showOutcome: showOutcome)
    } //func
    static func Statusstring( for participant: GKTurnBasedParticipant, isLocal isl: Bool, isCurrent isc: Bool, showOutcome: Bool = false) -> String {
        switch participant.status {
        case .active:
            if isc {
                return isl ? "it's your turn" : "it's their turn"
            } else {
                return "in the game"
            }
        case .done:
            return showOutcome
            ? didOutcomeString( for: participant, isLocal: isl)
            : isl ? "you left the game" : "left the game"
        case .declined:
            return isl ? "you declined the invitation" : "declined the invitation"
        case .matching:
            return isc
            ? "waiting to join the game, \(isl ? "it's your turn" : "it's their turn")"
            : "not joined yet"
        case .invited:
            if isc {
                return isl ? "you are invited to play" : "waiting to accept"
            } else {
                return isl ? "you are invited to play" : "has been invited"
            }
        default:
            return "server error"
        } //swi
    } //func
} //enum
