//
//  test4Outcomes.swift
//  CardPlay
//
//  Created by Ionut on 17.08.2022.
//

import Foundation

class test4Outcomes {
    @MainActor func testOutcomes( numberOfPlayers nop: Int) -> Void {
        var variant = 0
        var initialAmounts = [ChipsCountType].init( repeating: 0, count: nop)
        for i in initialAmounts.indices {
            initialAmounts[ i] = 100 * (i + 1)
        }
        let game = HoldemGame( numberOfPlayers: nop)
        
            runThroughDoubles(through: game.allPlayers, initialAmounts: initialAmounts) {
                runThroughReasons(for: game.allPlayers, reasons: [.none, .quit], curIndex: 0) {
                    variant += 1
                debugMsg_("variant \(variant)")
                printPlayers(in: game.allPlayers)
                    //printPlayers(in: game.allPlayers.sortedByChipsAndOuted())
                game.endStatus = game.updateEndStatus()
                game.endStatus.setOutcomes()
                printPlayers(in: game.endStatus.finishOrder)
            } //through doubling
        } //run through quit
    } //func
    func reasonString(of reason: PokerPlayer.NoJoinReason) -> String {
        let table: [PokerPlayer.NoJoinReason: String] = [
            .none: "none",
            .quit: "quit",
            .timeOut: "timeout",
            .first: "first",
            .won: "won",
            .lost: "lost",
            .tied: "tied"
    ]
            return table[reason] ?? "unknown"
    } //func
    @MainActor func printPlayers( in rows: [[PokerPlayer]]) -> Void {
        for row in rows.indices {
            debugMsg_("place \(row + 1):")
            printPlayers(in: rows[ row])
        }
    }
    @MainActor func printPlayers(in list: [PokerPlayer]) -> Void {
        for player in list {
            //debugMsg_("player\(player.matchParticipantIndex + 1), \( reasonString(of: player.notJoiningReason)), \(player.chips)")
            debugMsg_("player\(player.matchParticipantIndex + 1) \(player.chips) \( reasonString(of: player.notJoiningReason)) ")
        }
    } //func
    func runThroughDoubles( through players: [PokerPlayer], initialAmounts: [ChipsCountType], onfinish: () -> Void) -> Void {
        for i in initialAmounts.indices {
            players[ i].chips = initialAmounts[ i]
        }
        for player in players {
            let backup = player.chips
            let others = players.nextOthersOf(mpIndex: player.matchParticipantIndex, includeAtEnd: false) ?? []
            for other in others {
                player.chips = other.chips
                onfinish()
            } //for others
            player.chips = backup
        } //for players
    } //func
    func runThroughReasons( for players: [PokerPlayer], reasons: [PokerPlayer.NoJoinReason], curIndex: Int, onFinish: () -> Void) -> Void {
        guard players.indices.contains(curIndex) else {
            return
        }
        for reason in reasons {
            players[ curIndex].notJoiningReason = reason
            let lastIdx = players.endIndex - 1
            if curIndex < lastIdx {
                runThroughReasons( for: players, reasons: reasons, curIndex: curIndex + 1, onFinish: onFinish)
            }
            if curIndex == lastIdx {
                onFinish()
            }
        } //for
    } //func
} //class
