//
//  RangeTrim.swift
//  CardPlay
//
//  Created by Ionut on 12.12.2021.
//

import Foundation

extension Comparable {
    func trim( to closedRange: ClosedRange<Self>) -> Self {
        max(closedRange.lowerBound, min(closedRange.upperBound, self))
    } //func
} //ext
extension ClosedRange {
    func trim(_ value: Bound) -> Bound {
        Swift.max(self.lowerBound, Swift.min(self.upperBound, value))
    } //func
}
