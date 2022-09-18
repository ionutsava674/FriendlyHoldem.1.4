//
//  OrdinalNumberFormatterExt.swift
//  CardPlay
//
//  Created by Ionut on 09.07.2022.
//

import Foundation

extension NumberFormatter {
    static func ordinalString(_ from: Int) -> String? {
        ordinal.string(from: NSNumber(value: from))
    }
    static let ordinal: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .ordinal
        return nf
    }()
} //ext
