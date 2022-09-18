//
//  GameStartParameters.swift
//  CardPlay
//
//  Created by Ionut on 04.12.2021.
//

import Foundation

struct GameStartParameters: Codable, Hashable, Equatable {
    let startChips, smallBlind, bigBlind, minRaiseAmount: ChipsCountType
    let turnTimeout: TimeInterval
    static let gameTimeouts: [TimeInterval] = [60, 900, 1800, 3600, 86400, 0]

    static func validStringParameters( startChips: String, smallBlind: String, bigBlind: String, minRaiseAmount: String) -> Bool {
        guard let c = ChipsCountType(startChips),
              let s = ChipsCountType(smallBlind),
              let b = ChipsCountType(bigBlind),
              let m = ChipsCountType(minRaiseAmount) else {
            return false
        }
        return validParameters( startChips: c, smallBlind: s, bigBlind: b, minRaiseAmount: m)
    }
    static func validParameters( startChips: ChipsCountType, smallBlind: ChipsCountType, bigBlind: ChipsCountType, minRaiseAmount: ChipsCountType) -> Bool {
        smallBlind > 0
        && bigBlind > smallBlind
        && startChips > bigBlind
        && minRaiseAmount > 0
        && minRaiseAmount < (startChips - bigBlind)
    } //func
} //str
