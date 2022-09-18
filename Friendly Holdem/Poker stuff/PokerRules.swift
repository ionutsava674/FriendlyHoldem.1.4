//
//  PokerRules.swift
//  CardPlay
//
//  Created by Ionut on 02.08.2021.
//

import Foundation

enum PokerRules {
    static private let basicValues: [Int] = {
        [Int](1...14).filter { v in
            v != 11
        }
    }()
    static let rankOrderValues: [Int] = {
        [Int](1...15).filter { v in
            v != 11
        }
    }()
    static let jokerActValues = rankOrderValues
    static let suitActValues: [[Int]] = {
        var r = basicValues.map { v in
            [v]
        }
        r[0].append(15)
        return r
    }()
    static let suitSymbols: [RawCardSymbol] = {
        [.ace, ._2, ._3, ._4, ._5, ._6, ._7, ._8, ._9, ._10, .jack, .queen, .king]
    }()
} //pr

