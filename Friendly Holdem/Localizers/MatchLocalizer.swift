//
//  MatchLocalizer.swift
//  CardPlay
//
//  Created by Ionut on 22.12.2021.
//

import SwiftUI
import GameKit

enum MatchLocalizer {
    static func title( of match: GKTurnBasedMatch, justTheList: Bool = false) -> String {
        if match.isOpenOrMatching() {
            return gameWithWhom( of: match, justTheList: justTheList)
        }
        return doneGameWithWhom( of: match, justTheList: justTheList)
    } //func
    static private func doneGameWithWhom( of match: GKTurnBasedMatch, justTheList: Bool = false) -> String {
        guard let allOthers = match.participants.nextOthers(ofPlayer: GKLocalPlayer.local, includeAtEnd: false) else {
            return String.localizedStringWithFormat(NSLocalizedString("game #%@", comment: ""), match.matchID)
        }
        let othersNames = allOthers.map({
            $0.name( in: match)
        })
        let out = ListFormatter.localizedString( byJoining: othersNames)
        return justTheList
        ? out
        : String.localizedStringWithFormat(NSLocalizedString("game with %@", comment: ""), out)
    } //func
    static private func gameWithWhom( of match: GKTurnBasedMatch, justTheList: Bool = false) -> String {
        let localJoining = match.localJoining()
        guard let allOthers = match.participants.nextOthers(ofPlayer: GKLocalPlayer.local, includeAtEnd: false) else {
            return String.localizedStringWithFormat(NSLocalizedString("game #%@", comment: ""), match.matchID)
        }
        let stillOthers = allOthers.filter({
            $0.status.meansStillInGame( includingWaiting: true)
        }) //filt
        let knownStillOthers = stillOthers.filter({
            [GKTurnBasedParticipant.Status.active, GKTurnBasedParticipant.Status.invited]
                .contains($0.status)
        }) //filt
        let stillUnknownCount = stillOthers.count - knownStillOthers.count
        let playersDropped = stillOthers.count < allOthers.count
        let withWhom = match.withWhomCondition()
        var stillOthersWithTrailNames = knownStillOthers.map({ $0.name( in: match) })
        
        switch stillUnknownCount {
        case 0:
            break
        case 1:
            stillOthersWithTrailNames.append(playersDropped
                                             ? NSLocalizedString("one remaining auto selected player", comment: "")
                                             : NSLocalizedString("an auto selected player", comment: ""))
        default:
            stillOthersWithTrailNames.append(playersDropped
                                             ? String.localizedStringWithFormat(NSLocalizedString("%lld remaining auto selected players", comment: ""), stillUnknownCount)
                                             : String.localizedStringWithFormat(NSLocalizedString("%lld auto selected players", comment: ""), stillUnknownCount))
        } //swi
        let stillOthersWithTrailListed = stillOthersWithTrailNames.isEmpty
        ? NSLocalizedString("no opponents", comment: "")
        : ListFormatter.localizedString( byJoining: stillOthersWithTrailNames)
        if justTheList {
            return stillOthersWithTrailListed
        }
        if localJoining {
            switch withWhom {
            case .onePlayerGame:
                return NSLocalizedString("game with no opponents.", comment: "")
            case .with0KnownAbandoners:
                return String.localizedStringWithFormat(NSLocalizedString("game with no more opponents. %lld initial players", comment: ""), match.participants.count)
            case .with0KnownUnknown,
                    .with1Known,
             .with1KnownUnknown,
             .withManyKnown,
             .withManyKnownUnknown:
                return String.localizedStringWithFormat(NSLocalizedString("game with %@", comment: ""), stillOthersWithTrailListed)
            case .with0KnownUnknownAbandoners,
             .with1KnownAbandoners,
             .with1KnownUnknownAbandoners,
             .withManyKnownAbandoners,
             .withManyKnownUnknownAbandoners:
                return String.localizedStringWithFormat(NSLocalizedString("game with %1$@. %2$lld initial players", comment: ""), stillOthersWithTrailListed, match.participants.count)
            } //swi
        } else {
            switch withWhom {
            case .onePlayerGame:
                return NSLocalizedString("game without active players.", comment: "")
            case .with0KnownAbandoners:
                return String.localizedStringWithFormat(NSLocalizedString("game with no more active players. %lld initial players", comment: ""), match.participants.count)
            case .with0KnownUnknown,
             .with1Known,
             .with1KnownUnknown,
             .withManyKnown,
             .withManyKnownUnknown:
                if stillOthers.count > 1 {
                    return String.localizedStringWithFormat(NSLocalizedString("game between %@", comment: ""), stillOthersWithTrailListed)
                }
                return String.localizedStringWithFormat(NSLocalizedString("game with 1 remaining player: %@", comment: ""), stillOthersWithTrailListed)
            case .with0KnownUnknownAbandoners,
             .with1KnownAbandoners,
             .with1KnownUnknownAbandoners,
             .withManyKnownAbandoners,
             .withManyKnownUnknownAbandoners:
                if stillOthers.count > 1 {
                    return String.localizedStringWithFormat(NSLocalizedString("game between %1$@. %2$lld initial players", comment: ""), stillOthersWithTrailListed, match.participants.count)
                }
                return String.localizedStringWithFormat(NSLocalizedString("game with 1 remaining player: %1$@. %2$lld initial players", comment: ""), stillOthersWithTrailListed, match.participants.count)
            } //swi
    } //else
    } //func
    static func itsWhoosTurnText( of match: GKTurnBasedMatch) -> String? {
        guard match.isOpenOrMatching() else {
            return nil
        }
        guard let mcp = match.currentParticipant else {
            return nil
        }
        guard let cpp = mcp.player else {
            let forWhom = GameController.playerAlias(of: mcp, in: match, preferredDefault: nil, unknownIndexDefault: NSLocalizedString("auto selected player", comment: ""))
            return String.localizedStringWithFormat(NSLocalizedString("waiting for %@", comment: ""), forWhom)
        }
        if cpp == GKLocalPlayer.local {
            return NSLocalizedString("It's your turn", comment: "")
        }
        if mcp.status == .invited {
            let forWhom = GameController.playerAlias(of: mcp, in: match, preferredDefault: nil, unknownIndexDefault: NSLocalizedString("auto selected player", comment: ""))
            return String.localizedStringWithFormat(NSLocalizedString("waiting for %@ to accept", comment: ""), forWhom)
        }
        let forWhom = GameController.playerAlias(of: mcp, in: match, preferredDefault: nil, unknownIndexDefault: NSLocalizedString("auto selected player", comment: ""))
        return String.localizedStringWithFormat(NSLocalizedString("It's %@'s turn", comment: ""), forWhom)
    } //func
} //enum

extension GKTurnBasedMatch {
    func localJoining() -> Bool {
        localParticipant()?.status.meansStillInGame( includingWaiting: false) ?? false
    } //func
    func allOthers() -> [GKTurnBasedParticipant] {
        participants.nextOthers( ofPlayer: GKLocalPlayer.local, includeAtEnd: false) ?? []
    } //func
    func othersStillJoining( includingWaiting: Bool) -> [GKTurnBasedParticipant] {
        allOthers().filter({
            $0.status.meansStillInGame( includingWaiting: includingWaiting)
        }) //filt
    } //func
    func knownOthersStillJoining( includingWaiting: Bool = true) -> [GKTurnBasedParticipant] {
        othersStillJoining( includingWaiting: includingWaiting).filter({
            [GKTurnBasedParticipant.Status.active, GKTurnBasedParticipant.Status.invited]
                .contains($0.status)
        }) //filt
    } //func
    func withWhomCondition() -> MatchPlayingWithWhom {
        let allOtr = allOthers()
        let stillOthers = othersStillJoining(includingWaiting: true)
        let stillKnown = knownOthersStillJoining()
        
        let abandoners = allOtr.count - stillOthers.count
        let unknown = stillOthers.count - stillKnown.count
        
        if stillKnown.isEmpty {
            if abandoners < 1 {
                return unknown < 1
                ? .onePlayerGame
                : .with0KnownUnknown
            }
            return unknown < 1
            ? .with0KnownAbandoners
            : .with0KnownUnknownAbandoners
        } //0
        if stillKnown.count == 1 {
            if abandoners < 1 {
                return unknown < 1
                ? .with1Known
                : .with1KnownUnknown
            }
            return unknown < 1
            ? .with1KnownAbandoners
            : .with1KnownUnknownAbandoners
        } //1
        if abandoners < 1 {
            return unknown < 1
            ? .withManyKnown
            : .withManyKnownUnknown
        }
        return unknown < 1
        ? .withManyKnownAbandoners
        : .withManyKnownUnknownAbandoners
    } //func
} //ext
enum MatchPlayingWithWhom {
case onePlayerGame, //000
     with0KnownUnknown, //010
     with0KnownAbandoners, //001
     with0KnownUnknownAbandoners, //011
    with1Known, //100
    with1KnownUnknown, //110
    with1KnownAbandoners, //101
    with1KnownUnknownAbandoners, //111
    withManyKnown, //200
    withManyKnownUnknown, //210
    withManyKnownAbandoners, //201
    withManyKnownUnknownAbandoners //211
} //enum
