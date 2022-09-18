//
//  PokerInterpretationHand.swift
//  CardPlay
//
//  Created by Ionut on 15.08.2021.
//

import Foundation

typealias InterpretationHand = [CardInterpretation]

extension Array where Element == CardInterpretation {
    func getString() -> String {
        let values = (map { ci in
            "\(ci.value) \(ci.suit.name)"
        }).joined(separator: ", ")
return values
    }
    func sortedByValue() -> InterpretationHand {
        sorted { ci1, ci2 in
            ci1.value < ci2.value
        }
    } //func
    func sortedByOccurance() -> InterpretationHand {
        let occs = getOccurances( trimMultiples: false)
        let se = enumerated().sorted { i1, i2 in
            occs[ i1.offset] > occs[ i2.offset] ||
                ( occs[ i1.offset] == occs[ i2.offset] && i1.element.value > i2.element.value)
        }
        return se.map { e in
            e.element
        }
        
    } //func
    func isStraightInPoker( sortBeforeChecking: Bool) -> Bool {
        let sortedHand = sortBeforeChecking ? sortedByValue() : self
        for i in 1..<sortedHand.count {
            guard let p1 = PokerRules.rankOrderValues.firstIndex(of: sortedHand[i - 1].value) else {
                return false
            }
            guard let p2 = PokerRules.rankOrderValues.firstIndex(of: sortedHand[i].value) else {
                return false
            }
            if p2 - p1 != 1 {
                return false
            }
        } //for
        return true
    } //func
    func isTheSameSuit() -> Bool {
        for i in 1..<count {
            if self[ i].suit != self[ 0].suit {
                return false
            }
        }
        return true
    } //func
    func getOccurances( trimMultiples: Bool) -> [Int] {
        var pool = self
        var result = [Int]()
        for ci in self {
            let occ = pool.reduce(0, { sum, ici in
                return sum + ( ici.value == ci.value ? 1 : 0 )
            })
            if occ == 0 {
                continue
            }
            result.append( occ)
            if trimMultiples {
                pool.removeAll { ici in
                    ici.value == ci.value
                }
            }
        } //for
        return result
    } //occ
} //ext
