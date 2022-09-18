//
//  RelativeDateFormatterExtension.swift
//  CardPlay
//
//  Created by Ionut on 19.12.2021.
//

import Foundation

extension RelativeDateTimeFormatter {
    static func conversionMode1( of date: Date, errorValue: String = "") -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.dateTimeStyle = .numeric
        formatter.unitsStyle = .full
        formatter.formattingContext = .middleOfSentence
        return formatter.string( for: date) ?? errorValue
    } //func
} //ext
