//
//  PokerGameShowdown.swift
//  CardPlay
//
//  Created by Ionut on 03.07.2022.
//

import Foundation

extension HoldemGame {
    
    func distributeChips ( orderedWinners: [[PokerPlayer]]) -> Bool {
        guard allPlayers.filter({
            $0.lastFinishingResult == nil
        }).isEmpty else {
            return false
        }
        let KeepPots = computePots()
        var pots = KeepPots
        var toTransferAmounts: [PokerPlayer.IndexType: ChipsCountType] = [:]
        for player in allPlayers {
            toTransferAmounts[player.matchParticipantIndex] = 0
            player.lastFinishingResult?.didPlaceInBet = player.placedInBet
        }
        print("total pots \(pots.count)")
        for pot in pots {
            if !pot.destructiveAccumulate( with: &toTransferAmounts) {
                return false
            }
            print("pot with \(pot.contributers.count) contributers, from \(pot.fromPoint) to \(pot.cutPoint)")
            print(" accumulated \(pot.accumulatedAmount), actual \(pot.actualSize)")
        } //for pots
        print("winners \(orderedWinners.count)")
        for winnerPlace in orderedWinners.indices {
            for winner in orderedWinners[winnerPlace] {
                let eachWinnerPots = pots.filter({
                    $0.contributers.contains(where: { contributer in
                        contributer.matchParticipantIndex == winner.matchParticipantIndex
                    })
                }) //pots filter
                print("found \(eachWinnerPots.count) pots for player \(winner.matchParticipantIndex+1)")
                for eachWinnerPot in eachWinnerPots {
                    let recipients = eachWinnerPot.contributers.intersection( with: orderedWinners[ winnerPlace])
                    print("pot with \(eachWinnerPot.contributers.count) contributers and \(recipients.count) recipients")
                    if !eachWinnerPot.destructiveDistribute( to: recipients, with: &toTransferAmounts) {
                        return false
                    }
                    pots.removeAll(where: {
                        $0.cutPoint == eachWinnerPot.cutPoint
                    })
                } //each pot of winner
            } //each winner on level
        } //each level
        print(" done initial distrib")
        for eachLeftPot in pots {
            let rec = orderedWinners.first ?? eachLeftPot.contributers
            if !eachLeftPot.destructiveDistribute( to: rec, with: &toTransferAmounts) {
                return false
            }
        } //for left pots
        for player in allPlayers {
            player.applyTransfer( from: &toTransferAmounts)
        }
        self.lastShowdownStatus.pots = KeepPots
        return true
    } //func
    typealias StackHandTuple = (stack: CardStack, hand: InterpretationHand)
    typealias GetBestHandResult = Result<StackHandTuple, GetHandError>
    internal func orderPlayersByHand ( onFinishCallBack: @escaping () -> Void) -> Void {
        DispatchQueue.global( qos: .userInitiated).async {
            let finishingPlayers = self.joiningNotDropped
            for player in self.allPlayers {
                switch self.getBestHandBack(playerIndex: player.matchParticipantIndex) {
                case .success(let sh):
                    player.lastFinishingResult = FinishingSituation( stack: sh.stack) //, hand: sh.hand)
                default:
                    //player.lastFinishingResult = nil
                    player.lastFinishingResult = FinishingSituation( stack: CardStack.emptyStackForViewing)
                } //swi
            }  //for
            let sortedFinished = finishingPlayers.sorted( by: {
                // ($0.lastBestHand?.hand ?? InterpretationHand()) > ($1.lastBestHand?.hand ?? InterpretationHand())
                PokerHandRank.compareHands( hand1: $0.lastFinishingResult?.comboBestHand, hand2: $1.lastFinishingResult?.comboBestHand) == .firstWins
            }) //sort
            let ranked: [[PokerPlayer]] = sortedFinished.reduce(into: [[PokerPlayer]](), { currentRanks, eachPlayer in
                if currentRanks.isEmpty {
                    currentRanks.append([eachPlayer])
                } else {
                    let prevIdx = currentRanks.index(before: currentRanks.endIndex)
                    if let prevFirst = currentRanks[prevIdx].first {
                        if (prevFirst.lastFinishingResult?.comboBestHand ?? InterpretationHand()).isEqualInRank( as: eachPlayer.lastFinishingResult?.comboBestHand ?? InterpretationHand()) {
                            currentRanks[prevIdx].append(eachPlayer)
                        } else {
                            currentRanks.append([eachPlayer])
                        } //not equal
                    } else {
                        //
                    } //found empty slot
                } //not empty
            }) //ranks
            DispatchQueue.main.async {
                self.lastShowdownStatus = DealShowdownStatus( winners: ranked, pots: [], numberOfPlayers: self.allPlayers.count)
                onFinishCallBack()
            } //sync as
        }//back as
    } //func
    private func getBestHandBack( playerIndex:PokerPlayer.IndexType) -> GetBestHandResult {
        guard let player = allPlayers.get( by: playerIndex) else {
            return .failure(.userNotFound)
        }
        var availableCards = Array( flop.cards )
        availableCards.append(contentsOf: player.hand.cards)
        if !((5...7).contains( availableCards.count)) {
            return .failure(.invalidHand)
        }
        var variant = [Int](repeating: 0, count: 5)
        var bestHand = InterpretationHand()
        var bestStack = CardStack(cards: [], ownerIndex: nil, whoCanSee: .everyOne)
        runThroughCards(availableCards: &availableCards, variant: &variant, indexInVariant: 0) { eachStack in
            let eachBestHand = eachStack.getBestInterpretationHand()
            if PokerHandRank.compareHands( hand1: bestHand, hand2: eachBestHand) == .secondWins {
                bestHand = eachBestHand
                bestStack = eachStack
            }
        } //each variant
        //bestHand.printHand()
        // bestHand.sortedByOccurance().printHand()
        //let best = PokerHandRank.getBestRank(of: bestHand)
        //print(best.name)
        return .success((stack: bestStack, hand: bestHand))
    } //func
    private func runThroughCards( availableCards: inout [Card], variant: inout [Int], indexInVariant: Int, doWithVariant: (CardStack) -> Void) -> Void {
        guard availableCards.count >= variant.count && variant.indices.contains(indexInVariant) else {
            return
        }
        let startCardIndexToSet = indexInVariant == 0
        ? 0
        : variant[indexInVariant - 1] + 1
        let endCardIndexToSet = availableCards.count - variant.count + indexInVariant
        for cardIndex in startCardIndexToSet...endCardIndexToSet {
            variant[indexInVariant] = cardIndex
            if indexInVariant < variant.count - 1 {
                runThroughCards(availableCards: &availableCards, variant: &variant, indexInVariant: indexInVariant + 1, doWithVariant: doWithVariant)
            } else {
                let varCards = variant.map { _cardIndex in
                    availableCards[_cardIndex]
                }
                let varStack = CardStack(cards: varCards, ownerIndex: nil, whoCanSee: .everyOne)
                doWithVariant( varStack)
            } //if
        } //for
    } //run func
    
    func whoNeedsToAcknowledge() -> [PokerPlayer] {
        joiningPlayers
    } //func
    func allJoiningAcknowledged( in results: DealShowdownStatus) -> Bool {
        let mapped = joiningPlayers.map({
            results.acknowledgedBy( $0.matchParticipantIndex)
        })
        return !mapped.contains(false)
    } //func
    @MainActor func computeShowdown() async -> Bool {
        let winners = await orderPlayersByHandAsync()
        var resultingPots = [PokerPot]()
        var transfers = [PokerPlayer.IndexType: ChipsCountType]()
        guard await distributeChipsAsync( orderedWinners: winners, resultingPots: &resultingPots, transfersToBeMade: &transfers) else {
            debugMsg_("something wrong")
            return false
        }
        for player in allPlayers {
            player.applyTransfer( from: &transfers)
        }
        lastShowdownStatus = DealShowdownStatus( winners: winners, pots: resultingPots, numberOfPlayers: self.allPlayers.count)
        debugMsg_("computed")
        return true
    } //func
    func printPots(_ pots: [PokerPot]) -> String {
        var r = "\(pots.count) pots"
        for pot in pots {
            r += "\n total \(pot.accumulatedAmount),"
            r += "\n from \(pot.fromPoint) to \(pot.cutPoint), \(pot.contributers.count) contributers"
        }
        return r
    } //func
    @MainActor private func distributeChipsAsync ( orderedWinners: [[PokerPlayer]], resultingPots: inout [PokerPot], transfersToBeMade: inout [PokerPlayer.IndexType: ChipsCountType]) async -> Bool {
        guard allPlayers.filter({
            $0.lastFinishingResult == nil
        }).isEmpty else {
            return false
        }
        var KeepPots = computePots()
        debugMsg_(printPots(KeepPots))
        KeepPots = KeepPots.filter({
            $0.cutPoint > 0
        }) //filt
        debugMsg_(printPots(KeepPots))
        var pots = KeepPots
        var toTransferAmounts: [PokerPlayer.IndexType: ChipsCountType] = [:]
        for player in allPlayers {
            toTransferAmounts[player.matchParticipantIndex] = 0
        }
        for pot in pots {
            if !pot.destructiveAccumulate( with: &toTransferAmounts) {
                return false
            }
        } //for pots
        for winnerPlace in orderedWinners.indices {
            for winner in orderedWinners[winnerPlace] {
                let eachWinnerPots = pots.filter({
                    $0.contributers.contains(where: { contributer in
                        contributer.matchParticipantIndex == winner.matchParticipantIndex
                    })
                }) //pots filter
                for eachWinnerPot in eachWinnerPots {
                    let recipients = eachWinnerPot.contributers.intersection( with: orderedWinners[ winnerPlace])
                    if !eachWinnerPot.destructiveDistribute( to: recipients, with: &toTransferAmounts) {
                        return false
                    }
                    pots.removeAll(where: {
                        $0.cutPoint == eachWinnerPot.cutPoint
                    })
                } //each pot of winner
            } //each winner on level
        } //each level
        for eachLeftPot in pots {
            let rec = orderedWinners.first ?? eachLeftPot.contributers
            if !eachLeftPot.destructiveDistribute( to: rec, with: &toTransferAmounts) {
                return false
            }
        } //for left pots
        resultingPots = KeepPots
        transfersToBeMade = toTransferAmounts
        return true
    } //func
    @MainActor private func distributeChipsAsync2 ( orderedWinners: [[PokerPlayer]], resultingPots: inout [PokerPot], transfersToBeMade: inout [PokerPlayer.IndexType: ChipsCountType]) async -> Bool {
        guard allPlayers.filter({
            $0.lastFinishingResult == nil
        }).isEmpty else {
            return false
        }
        let KeepPots = computePots()
        var pots = KeepPots
        var toTransferAmounts: [PokerPlayer.IndexType: ChipsCountType] = [:]
        for player in allPlayers {
            toTransferAmounts[player.matchParticipantIndex] = 0
        }
        for pot in pots {
            if !pot.destructiveAccumulate( with: &toTransferAmounts) {
                return false
            }
        } //for pots
        for winnerPlace in orderedWinners.indices {
            for winner in orderedWinners[winnerPlace] {
                let eachWinnerPots = pots.filter({
                    $0.contributers.contains(where: { contributer in
                        contributer.matchParticipantIndex == winner.matchParticipantIndex
                    })
                }) //pots filter
                for eachWinnerPot in eachWinnerPots {
                    let recipients = eachWinnerPot.contributers.intersection( with: orderedWinners[ winnerPlace])
                    if !eachWinnerPot.destructiveDistribute( to: recipients, with: &toTransferAmounts) {
                        return false
                    }
                    pots.removeAll(where: {
                        $0.cutPoint == eachWinnerPot.cutPoint
                    })
                } //each pot of winner
            } //each winner on level
        } //each level
        for eachLeftPot in pots {
            let rec = orderedWinners.first ?? eachLeftPot.contributers
            if !eachLeftPot.destructiveDistribute( to: rec, with: &toTransferAmounts) {
                return false
            }
        } //for left pots
        resultingPots = KeepPots
        transfersToBeMade = toTransferAmounts
        return true
    } //func
    @MainActor private func establishPlayersDealResults() async -> Void {
        for player in self.allPlayers {
            switch await self.getBestHandAsync( playerIndex: player.matchParticipantIndex) {
            case .success(let sh):
                player.lastFinishingResult = FinishingSituation( stack: sh.stack)
            default:
                player.lastFinishingResult = FinishingSituation( stack: CardStack.emptyStackForViewing)
            } //swi
            player.lastFinishingResult?.didPlaceInBet = player.placedInBet
        }  //for
    } //func
    @MainActor private func orderPlayersByHandAsync () async -> [[PokerPlayer]] {
        await establishPlayersDealResults()
            let finishingPlayers = self.joiningNotDropped
            let sortedFinished = finishingPlayers.sorted( by: {
                PokerHandRank.compareHands( hand1: $0.lastFinishingResult?.comboBestHand, hand2: $1.lastFinishingResult?.comboBestHand) == .firstWins
            }) //sort
            let ranked: [[PokerPlayer]] = sortedFinished.reduce(into: [[PokerPlayer]](), { currentRanks, eachPlayer in
                if currentRanks.isEmpty {
                    currentRanks.append([eachPlayer])
                } else {
                    let prevIdx = currentRanks.index(before: currentRanks.endIndex)
                    if let prevFirst = currentRanks[prevIdx].first {
                        if (prevFirst.lastFinishingResult?.comboBestHand ?? InterpretationHand()).isEqualInRank( as: eachPlayer.lastFinishingResult?.comboBestHand ?? InterpretationHand()) {
                            currentRanks[prevIdx].append(eachPlayer)
                        } else {
                            currentRanks.append([eachPlayer])
                        } //not equal
                    } else {
                        //
                    } //found empty slot
                } //not empty
            }) //ranks
        return ranked
    } //func
    @MainActor private func getBestHandAsync( playerIndex:PokerPlayer.IndexType) async -> GetBestHandResult {
        guard let player = allPlayers.get( by: playerIndex) else {
            return .failure(.userNotFound)
        }
        var availableCards = Array( flop.cards )
        availableCards.append(contentsOf: player.hand.cards)
        if !((5...7).contains( availableCards.count)) {
            return .failure(.invalidHand)
        }
        var variant = [Int](repeating: 0, count: 5)
        var bestHand = InterpretationHand()
        var bestStack = CardStack(cards: [], ownerIndex: nil, whoCanSee: .everyOne)
        await Self.runThroughCardsAsync( availableCards: &availableCards, variant: &variant, indexInVariant: 0) { eachStack in
            let eachBestHand = eachStack.getBestInterpretationHand()
            if PokerHandRank.compareHands( hand1: bestHand, hand2: eachBestHand) == .secondWins {
                bestHand = eachBestHand
                bestStack = eachStack
            }
        } //each variant
        return .success((stack: bestStack, hand: bestHand))
    } //func
    static private func runThroughCardsAsync( availableCards: inout [Card], variant: inout [Int], indexInVariant: Int, doWithVariant: (CardStack) -> Void) async -> Void {
        guard availableCards.count >= variant.count && variant.indices.contains(indexInVariant) else {
            return
        }
        let startCardIndexToSet = indexInVariant == 0
        ? 0
        : variant[indexInVariant - 1] + 1
        let endCardIndexToSet = availableCards.count - variant.count + indexInVariant
        for cardIndex in startCardIndexToSet...endCardIndexToSet {
            variant[indexInVariant] = cardIndex
            if indexInVariant < variant.count - 1 {
                await runThroughCardsAsync( availableCards: &availableCards, variant: &variant, indexInVariant: indexInVariant + 1, doWithVariant: doWithVariant)
            } else {
                let varCards = variant.map { _cardIndex in
                    availableCards[_cardIndex]
                }
                let varStack = CardStack(cards: varCards, ownerIndex: nil, whoCanSee: .everyOne)
                doWithVariant( varStack)
            } //if
        } //for
    } //run func

} //ext

enum GetHandError: Error {
    case userNotFound, invalidHand
} //enum error
