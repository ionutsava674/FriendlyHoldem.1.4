//
//  DealShowdownStatus.swift
//  CardPlay
//
//  Created by Ionut on 06.07.2022.
//

import Foundation

struct DealShowdownStatus: Codable {
    var id: UUID
var winners: [[PokerPlayer]] = []
    var pots: [PokerPot] = []
    private var acknowledged: [Bool]
    func printack() -> String {
        acknowledged.map({
            $0 ? "1" : "0"
        }).joined(separator: " ")
    }
    @MainActor mutating func test_resetAck() -> Void {
        self.acknowledged = [Bool].init( repeating: false, count: acknowledged.count)
        self.id = UUID()
    }
    mutating func acknowledge( by playerIdx: PokerPlayer.IndexType) -> Void {
        guard acknowledged.indices.contains(playerIdx) else {
            return
        }
        acknowledged[ playerIdx] = true
    } //func
    func acknowledgedBy( _ playerIdx: PokerPlayer.IndexType) -> Bool {
        guard acknowledged.indices.contains(playerIdx) else {
            return false
        }
        return acknowledged[playerIdx]
    } //func
    init(winners: [[PokerPlayer]], pots: [PokerPot], numberOfPlayers: Int) {
        id = UUID()
        self.winners = winners
        self.pots = pots
        self.acknowledged = [Bool].init(repeating: false, count: numberOfPlayers)
    }
} //str
