//
//  GameLogEntry.swift
//  CardPlay
//
//  Created by Ionut on 26.11.2021.
//

import Foundation
import GameKit

class GameLogEntry: Codable {
    let action: GameTransitionAction
    let actors: [PokerPlayer.IndexType]?
    let amount: ChipsCountType?
    
    init(gameAction: GameTransitionAction, actors: [PokerPlayer.IndexType]? = nil, amount: ChipsCountType? = nil) {
        self.action = gameAction
        self.actors = actors
        self.amount = amount
    } //init
    
    func print( for gameModel: HoldemGame, and match: GKTurnBasedMatch) -> String {
        let names: [String] = actors?.map({
            GameLocalizer.playerAlias( of: $0, in: match, unknownIndexDefault: "unknown player")
        }) ?? []
        let combined = ListFormatter.localizedString( byJoining: names)
        switch action {
        case .none:
            return NSLocalizedString("no action", comment: "")
        case .startedGame:
            return NSLocalizedString("new game began", comment: "")
        case .dealtFlop:
            return NSLocalizedString("dealt flop cards", comment: "")
        case .dealtTurn:
            return NSLocalizedString("dealt turn card", comment: "")
        case .dealtRiver:
            return NSLocalizedString("dealt river card", comment: "")
        case .wentToShowdown:
            return NSLocalizedString("showdown", comment: "")
        case .gameEnded:
            return NSLocalizedString("game over", comment: "")
        case .smallBlind:
            let howMuch = amount.toStringOptional ?? NSLocalizedString("unknown", comment: "")
            return String.localizedStringWithFormat(NSLocalizedString("%@ placed small blind bet, %@", comment: ""), combined, howMuch)
        case .bigBlind:
            let howMuch = amount.toStringOptional ?? NSLocalizedString("unknown", comment: "")
            return String.localizedStringWithFormat(NSLocalizedString("%@ placed big blind bet, %@", comment: ""), combined, howMuch)
        case .raised:
            let howMuch = amount.toStringOptional ?? NSLocalizedString("unknown", comment: "")
            return String.localizedStringWithFormat(NSLocalizedString("%@ raised bet to %@", comment: ""), combined, howMuch)
        case .bet:
            let howMuch = amount.toStringOptional ?? NSLocalizedString("unknown", comment: "")
            return String.localizedStringWithFormat(NSLocalizedString("%@ bet %@", comment: ""), combined, howMuch)
        case .called:
            let howMuch = amount.toStringOptional ?? NSLocalizedString("unknown", comment: "")
            return String.localizedStringWithFormat(NSLocalizedString("%@ called at %@", comment: ""), combined, howMuch)
        case .stayed:
            let howMuch = amount.toStringOptional ?? NSLocalizedString("unknown", comment: "")
            return String.localizedStringWithFormat(NSLocalizedString("%@ stays all in with %@", comment: ""), combined, howMuch)
        case .dropped:
            let howMuch = amount.toStringOptional ?? NSLocalizedString("unknown", comment: "")
            return String.localizedStringWithFormat(NSLocalizedString("%@ threw the hand, with %@ chips in the pot", comment: ""), combined, howMuch)
        case .checked:
            //let howMuch = amount.toStringOptional ?? NSLocalizedString("unknown", comment: "")
            return String.localizedStringWithFormat(NSLocalizedString("%@ checked", comment: ""), combined)
        case .wentAllIn:
            let howMuch = amount.toStringOptional ?? NSLocalizedString("unknown", comment: "")
            return String.localizedStringWithFormat(NSLocalizedString("%@ went all in with %@", comment: ""), combined, howMuch)
        } //swi
    } //func
} //log ent
