//
//  InterpretationHandExtension.swift
//  CardPlay
//
//  Created by Ionut on 30.11.2021.
//

import Foundation

//extension Array: Comparable where Element == CardInterpretation {
extension InterpretationHand: Comparable {
    func isEqualInRank(as hand: Self) -> Bool {
        PokerHandRank.compareHands(hand1: self, hand2: hand) == .areEqual
    }
    static public func <(h1: Self, h2: Self) -> Bool {
        PokerHandRank.compareHands(hand1: h1, hand2: h2) == .secondWins
    }
}
