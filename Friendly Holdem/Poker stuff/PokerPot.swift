//
//  PokerPot.swift
//  CardPlay
//
//  Created by Ionut on 26.09.2021.
//

import Foundation

class PokerPot: Codable {
    var fromPoint: ChipsCountType = 0
    var cutPoint: ChipsCountType = 0
    var actualSize: ChipsCountType {
        cutPoint - fromPoint
    }
    var contributers: [PokerPlayer] = []
    
    private(set) var didAccumulate: Bool = false
    private(set) var accumulatedAmount: ChipsCountType = 0
    var shouldAccumulate: ChipsCountType {
        actualSize * contributers.count
    } //cv
    var shouldDistributeEach: ChipsCountType {
        (recipients?.isEmpty ?? true)
        ? 0
        : shouldAccumulate / (recipients?.count ?? 1)
    }
    private(set) var didDistribute: Bool = false
    private(set) var recipients: [PokerPlayer]? = nil
    
    func destructiveDistribute( to recipients: [PokerPlayer], with playerTransfers: inout [PokerPlayer.IndexType: ChipsCountType]) -> Bool {
        guard !recipients.isEmpty && didAccumulate else {
            return false
        }
        guard recipients.filter({
            $0.lastFinishingResult == nil
        }).isEmpty else {
            return false
        }
        guard !didDistribute else {
            return false
        }
        didDistribute = true
        //print("distributing \(accumulatedAmount) to \(recipients.count) recipients")
        self.recipients = recipients
        let eachAmount = accumulatedAmount / recipients.count
        for recipient in recipients {
            // recipient.lastFinishingResult?.toTransfer += eachAmount
            playerTransfers[ recipient.matchParticipantIndex] = (playerTransfers[ recipient.matchParticipantIndex] ?? 0) + eachAmount
            accumulatedAmount -= eachAmount
        }
        return true
    } //func
    func destructiveAccumulate( with playerTransfers: inout [PokerPlayer.IndexType: ChipsCountType]) -> Bool {
        //needtovisit verify finishing and ret bool
        guard contributers.filter({
            $0.lastFinishingResult == nil
        }).isEmpty else {
            return false
        }
        //run once
        guard !didAccumulate else {
            return false
        }
        didAccumulate = true
        
        for contributer in contributers {
            //contributer.lastFinishingResult?.toTransfer -= actualSize
            playerTransfers[contributer.matchParticipantIndex] = (playerTransfers[contributer.matchParticipantIndex] ?? 0) - actualSize
            accumulatedAmount += actualSize
        }
        return true
    } //func
} //pot

extension Array where Element == PokerPot {
    func totalAmount() -> ChipsCountType {
        reduce(0, { partial, pot in
            return partial + pot.shouldAccumulate
        })
    }
}
