//
//  PokerHandRank.swift
//  CardPlay
//
//  Created by Ionut on 15.08.2021.
//

import Foundation

class PokerHandRank {
    let name: String
    let rankLevel: Int
    let validateHand: HandRankValidationFunc
    //private let compareHandsOfSameRank: HandRankCompareHandsFunc?
    
    enum HandCompareResult {
    case firstWins, areEqual, secondWins
    } //enum
    static func compareHands( hand1: InterpretationHand?, hand2: InterpretationHand?) -> HandCompareResult {
        if let h1 = hand1 {
            if let h2 = hand2 {
                return compareHands(hand1: h1, hand2: h2)
            }
            return .firstWins
        }
        if let _ = hand2 {
            return .secondWins
        }
        return .areEqual
    } //func
    static func compareHands( hand1: InterpretationHand, hand2: InterpretationHand) -> HandCompareResult {
        let r1 = getBestRank(of: hand1)
        let r2 = getBestRank(of: hand2)
        if r1.rankLevel == r2.rankLevel {
            if hand1.count != hand2.count { //not a hand
                return hand1.count > hand2.count ? .firstWins : .secondWins
            }
            let oc1 = hand1.sortedByOccurance()
            let oc2 = hand2.sortedByOccurance()
            for i in oc1.indices {
                if oc1[i].value > oc2[i].value {
                    return .firstWins
                }
                if oc1[i].value < oc2[i].value {
                    return .secondWins
                }
            } //for
            return .areEqual
        }
        return r1.rankLevel < r2.rankLevel ? .firstWins : .secondWins
    } //func
    static func getBestRank(of hand: InterpretationHand) -> PokerHandRank {
        for rank in orderedPokerRanks {
            if rank.validateHand(hand) {
                return rank
            }
        }
        return notAHand
    }
    static let orderedPokerRanks: [PokerHandRank] = [royalFlush, straightFlush, fourKind, fullHouse, flush, straight, threeKind, twoPairs, onePair, highCard]
    
    typealias HandRankValidationFunc = (InterpretationHand) -> Bool
    //typealias HandRankCompareHandsFunc = (InterpretationHand, InterpretationHand) -> Int

    static let royalFlush = PokerHandRank(name: "royal flush", rankLevel: 1, validateHand: royalFlushValidation)
    static let straightFlush = PokerHandRank(name: "straight flush", rankLevel: 2, validateHand: straightFlushValidation)
    static let fourKind = PokerHandRank(name: "four of a kind", rankLevel: 3, validateHand: fourKindValidation)
    static let fullHouse = PokerHandRank(name: "full house", rankLevel: 4, validateHand: fullHouseValidation)
    static let flush = PokerHandRank(name: "flush", rankLevel: 5, validateHand: flushValidation)
    static let straight = PokerHandRank(name: "straight", rankLevel: 6, validateHand: straightValidation)
    static let threeKind = PokerHandRank(name: "three of a kind", rankLevel: 7, validateHand: threeKindValidation)
    static let twoPairs = PokerHandRank(name: "two pairs", rankLevel: 8, validateHand: twoPairsValidation)
    static let onePair = PokerHandRank(name: "one pair", rankLevel: 9, validateHand: onePairValidation)
    static let highCard = PokerHandRank(name: "play high card", rankLevel: 10, validateHand: highCardValidation)
    static let notAHand = PokerHandRank(name: "not a hand", rankLevel: 11, validateHand: notAHandValidation)
    

    static private let royalFlushValidation: HandRankValidationFunc = { hand in
        guard straightFlush.validateHand( hand) else {
            return false
        }
        return hand.sortedByValue()[0].value == 10
    } //ro flu
    static private let straightFlushValidation: HandRankValidationFunc = { hand in
        guard flush.validateHand( hand) else {
            return false
        }
        let sortedHand = hand.sortedByValue()
        return sortedHand.isStraightInPoker(sortBeforeChecking: false)
    } //st flu
    static private let fourKindValidation: HandRankValidationFunc = { hand in
        guard hand.count == 5 else {
            return false
        }
        let occs = hand.getOccurances(trimMultiples: true).sorted()
        return occs == [1,4]
    } //4k
    static private let fullHouseValidation: HandRankValidationFunc = { hand in
        guard hand.count == 5 else {
            return false
        }
        let occs = hand.getOccurances(trimMultiples: true).sorted()
        return occs == [2,3]
    } //fh
    static private let flushValidation: HandRankValidationFunc = { hand in
        guard hand.count == 5 else {
            return false
        }
        return hand.isTheSameSuit()
    } //flu
    static private let straightValidation: HandRankValidationFunc = { hand in
        guard hand.count == 5 else {
            return false
        }
        return hand.isStraightInPoker(sortBeforeChecking:  true)
    } //st
    static private let threeKindValidation: HandRankValidationFunc = { hand in
        guard hand.count == 5 else {
            return false
        }
        let occs = hand.getOccurances(trimMultiples: true).sorted()
        return occs == [1,1,3]
    } //3k
    static private let twoPairsValidation: HandRankValidationFunc = { hand in
        guard hand.count == 5 else {
            return false
        }
        let occs = hand.getOccurances(trimMultiples: true).sorted()
        return occs == [1,2,2]
    } //2p
    static private let onePairValidation: HandRankValidationFunc = { hand in
        guard hand.count == 5 else {
            return false
        }
        let occs = hand.getOccurances(trimMultiples: true).sorted()
        return occs == [1,1,1,2]
    } //1p
    static private let highCardValidation: HandRankValidationFunc = { hand in
        return hand.count == 5
    } //no
    static private let notAHandValidation: HandRankValidationFunc = { hand in
        return true
    } //no

    private init(name: String, rankLevel: Int, validateHand: @escaping HandRankValidationFunc) {
        self.name = name
        self.rankLevel = rankLevel
        self.validateHand = validateHand
        //self.compareHandsOfSameRank = compareHandsOfSameRank
    }
} //rank
