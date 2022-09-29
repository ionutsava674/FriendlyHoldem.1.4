//
//  GameLocalizer.swift
//  CardPlay
//
//  Created by Ionut on 30.06.2022.
//

import Foundation
import GameKit
import SwiftUI

enum GameLocalizer {
    static func localizedInGameStatus( for player: PokerPlayer, in match: GKTurnBasedMatch, isLocal: Bool) -> String {
        guard player.joiningGame else {
            var res = LocalizednoJoinReason( for: player, in: match, withName: true, isLocal: isLocal)
            if player.placedInBet > 0 {
                res += isLocal
                ? String(localized: ", had \( player.placedInBet ) chips in the pot")
                : String(localized: ", you had \( player.placedInBet ) chips in the pot")
            }
            return res
        } //gua
        guard !player.dropped else {
            return isLocal
            ? String(localized: "you threw the hand, with \(player.placedInBet) chips in the pot")
            : String(localized: "\( playerAlias(of: player, in: match) ) threw the hand, with \( player.placedInBet ) chips in the pot")
        }
        return isLocal
        ? String(localized: "you bet \(player.placedInBet) chips")
        : String(localized: "\( playerAlias(of: player, in: match) ) bet \( player.placedInBet ) chips")
    } //func
    static func LocalizedShowdownStatus( for player: PokerPlayer, in match: GKTurnBasedMatch?, withName: Bool, isLocal: Bool) -> String {
        guard player.joiningGame else {
            return LocalizednoJoinReason( for: player, in: match, withName: withName, isLocal: isLocal)
        } //gua
        if player.dropped {
            return withName ?
            ( isLocal ?
            NSLocalizedString("you threw the hand", comment: "")
              : String.localizedStringWithFormat(NSLocalizedString("%@ threw the hand", comment: ""), playerAlias(of: player, in: match)) )
            : NSLocalizedString("threw the hand", comment: "")
        } //if
        return withName ?
        ( isLocal ?
        NSLocalizedString("", comment: "")
          : String.localizedStringWithFormat(NSLocalizedString("%@", comment: ""), playerAlias(of: player, in: match)) )
        : NSLocalizedString("", comment: "")
    } //func
    static func LocalizednoJoinReason( for player: PokerPlayer, in match: GKTurnBasedMatch?, withName: Bool, isLocal: Bool) -> String {
        switch player.notJoiningReason {
        case .none:
            return withName ?
            ( isLocal ?
            NSLocalizedString("", comment: "")
              : String.localizedStringWithFormat(NSLocalizedString("%@", comment: ""), playerAlias(of: player, in: match)) )
            : NSLocalizedString("", comment: "")
        case .quit:
            return withName ?
            ( isLocal ?
            NSLocalizedString("you quit", comment: "")
              : String.localizedStringWithFormat(NSLocalizedString("%@ quit", comment: ""), playerAlias(of: player, in: match)) )
            : NSLocalizedString("quit", comment: "")
        case .lost:
            return withName ?
            ( isLocal ?
            NSLocalizedString("you lost", comment: "")
              : String.localizedStringWithFormat(NSLocalizedString("%@ lost", comment: ""), playerAlias(of: player, in: match)) )
            : NSLocalizedString("lost", comment: "")
        case .timeOut:
            return withName ?
            ( isLocal ?
            NSLocalizedString("you timed out", comment: "")
              : String.localizedStringWithFormat(NSLocalizedString("%@ timed out", comment: ""), playerAlias(of: player, in: match)) )
            : NSLocalizedString("timed out", comment: "")
        case .tied:
            return withName ?
            ( isLocal ?
            NSLocalizedString("you tied", comment: "")
              : String.localizedStringWithFormat(NSLocalizedString("%@ tied", comment: ""), playerAlias(of: player, in: match)) )
            : NSLocalizedString("tied", comment: "")
        case .first:
            return withName ?
            ( isLocal ?
            NSLocalizedString("you finished first", comment: "")
              : String.localizedStringWithFormat(NSLocalizedString("%@ finished first", comment: ""), playerAlias(of: player, in: match)) )
            : NSLocalizedString("finished first", comment: "")
        case .won:
            return withName ?
            ( isLocal ?
            NSLocalizedString("you won", comment: "")
              : String.localizedStringWithFormat(NSLocalizedString("%@ won", comment: ""), playerAlias(of: player, in: match)) )
            : NSLocalizedString("won", comment: "")
        } //swi
    } //func
    static func listAliases( of playerList: [PokerPlayer], in match: GKTurnBasedMatch?) -> String {
        let names = playerList.map({
            playerAlias( of: $0, in: match)
        })
        return ListFormatter.localizedString( byJoining: names)
    } //func
    static func playerAlias( of playerIdx: PokerPlayer.IndexType?, in match: GKTurnBasedMatch?, preferredDefault: String? = nil, unknownIndexDefault: String = "unknown") -> String {
        guard let idx = playerIdx else {
            return preferredDefault ?? unknownIndexDefault
        }
        let defaultValue = preferredDefault ?? "player \(idx + 1)"
        guard let match = match else {
            return defaultValue
        }
        return match.participants.get( index: idx)?.player?.alias ?? defaultValue
    } //func
    static func playerAlias( of player: PokerPlayer, in match: GKTurnBasedMatch?, preferredDefault: String? = nil, unknownIndexDefault: String = "unknown") -> String {
        return playerAlias( of: player.matchParticipantIndex, in: match, preferredDefault: preferredDefault, unknownIndexDefault: unknownIndexDefault)
    } //func
    static func playerAlias( of participant: GKTurnBasedParticipant?, in match: GKTurnBasedMatch?, preferredDefault: String? = nil, unknownIndexDefault: String = "unknown") -> String {
        let idxOpt = match?.participants.firstIndex( where: {
            $0 == participant
        })
        return playerAlias( of: idxOpt, in: match, preferredDefault: preferredDefault, unknownIndexDefault: unknownIndexDefault)
    } //func
    static func whenItsYourTurn(in game: HoldemGame, and match: GKTurnBasedMatch) -> String {
        guard let mcp = match.currentParticipant,
              let mci = match.participants.firstIndex(where: {
                  $0.player == mcp.player
              }),
              let mciPlaceInGameOrder = game.actingOrder.firstIndex(of: mci),
              let yourIdx = match.localParticipantIndex()
        else {
            return ""
        }
        
        guard let reOrderedGameOrder = game.actingOrder.cycleFrom(arrayIdx: mciPlaceInGameOrder),
              let yourPlaceInReOrdered = reOrderedGameOrder.firstIndex(of: yourIdx)
        else {
            return "You are no longer active in the game"
        }
        
        switch yourPlaceInReOrdered {
        case 0:
            return "now it is your turn"
        case 1:
            let beforeYou = playerAlias( of: reOrderedGameOrder[ yourPlaceInReOrdered - 1 ], in: match)
            return String.localizedStringWithFormat(NSLocalizedString("you are next, after %@", comment: ""), beforeYou)
        default:
            let beforeYou = playerAlias( of: reOrderedGameOrder[ yourPlaceInReOrdered - 1 ], in: match)
            return String.localizedStringWithFormat(NSLocalizedString("In %lld turns after %@, it'll be your turn", comment: ""), yourPlaceInReOrdered, beforeYou)
        } //swi
    } //func
    static func nowItsWhosReallyTurn( in game: HoldemGame, and match: GKTurnBasedMatch) -> String? {
        guard let mcp = match.currentParticipant,
              let mci = match.participants.firstIndex(where: {
                  $0.player == mcp.player
              })
        else {
            return nil
        }
        let gci = game.actingOrder.first ?? mci
        if gci == mci {
            return nowItsWhosGameTurn(in: game, and: match)
        }
        let oldName = playerAlias( of: gci, in: match)
        let newName = playerAlias( of: mci, in: match)
        if mci == match.localParticipantIndex() {
            return String.localizedStringWithFormat(NSLocalizedString("it was %@'s turn, now it's your turn", comment: ""), oldName)
        }
        if gci == match.localParticipantIndex() {
            return String.localizedStringWithFormat(NSLocalizedString("it was your turn, now it's %@'s turn", comment: ""), newName)
        }
        return String.localizedStringWithFormat(NSLocalizedString("it was %1$@'s turn, now it's %2$@'s turn", comment: ""), oldName, newName)
    } //func
            static func nowItsWhosGameTurn( in game: HoldemGame, and match: GKTurnBasedMatch) -> String? {
                guard let mcp = match.currentParticipant,
                      let mci = match.participants.firstIndex(where: {
                          $0.player == mcp.player
                      })
                else {
                    return nil
                }
                let gci = game.actingOrder.first ?? mci
        if match.localParticipantIndex() == gci {
            return String(localized: "now it's your turn")
        }
        guard let name = mcp.player?.alias else {
            return nil
        }
        return String.localizedStringWithFormat(NSLocalizedString("Now it's %@'s turn", comment: ""), name)
    } //func
    static func whoIsCurrentDealer( in game: HoldemGame, and match: GKTurnBasedMatch) -> String {
        if game.actAsDealer == match.localParticipantIndex() {
            return "You're the current dealer"
        }
        return "\( playerAlias(of: game.allPlayers[ game.actAsDealer], in: match) ) is the current dealer"
    } //func
    static func dealerStatus( of player: PokerPlayer, in game: HoldemGame) -> String {
        game.actAsDealer == player.matchParticipantIndex
        ? "current dealer"
        : ""
    } //func
    static func itsHisTurn( of player: PokerPlayer, in game: HoldemGame, and match: GKTurnBasedMatch) -> String {
        guard let mcp = match.currentParticipant,
              let mci = match.participants.firstIndex(where: {
                  $0.player == mcp.player
              })
        else {
            return ""
        }
        let gcio = game.actingOrder.first
        guard player.matchParticipantIndex == mci else {
            if player.matchParticipantIndex == gcio {
                return player.matchParticipantIndex == match.localParticipantIndex()
                ? String(localized: "it was your turn")
                : String(localized: "it was their turn")
            }
            return ""
        } //gua
        return player.matchParticipantIndex == match.localParticipantIndex()
        ? String(localized: "it's your turn")
        : String(localized: "it's their turn")
    } //func
} //ext
