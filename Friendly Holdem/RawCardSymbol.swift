//
//  RawCardSymbol.swift
//  CardPlay
//
//  Created by Ionut on 04.08.2021.
//

import Foundation

struct RawCardSymbol: Equatable, Codable {
    enum symbolID: String, Codable, CustomStringConvertible {
    case ace = "A",
         v2 = "2",
         v3 = "3",
         v4 = "4",
         v5 = "5",
         v6 = "6",
         v7 = "7",
         v8 = "8",
         v9 = "9",
         v10 = "10",
         jack = "J",
         queen = "Q",
         king = "K",
         joker = "R"

        var description: String {
            rawValue
        } //cv
    } //enum
    let id: symbolID
    var display: String {
        id.rawValue
    } //cv
    var name: String {
        switch id {
        case .ace:
            return String(localized: "ace.card", defaultValue: "ace", comment: "card name")
        case .jack:
            return String(localized: "jack.card", defaultValue: "jack", comment: "card name")
        case .queen:
            return String(localized: "queen.card", defaultValue: "queen", comment: "card name")
        case .king:
            return String(localized: "king.card", defaultValue: "king", comment: "card name")
        case .joker:
            return String(localized: "joker.card", defaultValue: "joker", comment: "card name")
        default:
            return display
        } //swi
    } //cv
    var originalName: String {
        switch id {
        case .ace:
            return "ace"
        case .jack:
            return "jack"
        case .queen:
            return "queen"
        case .king:
            return "king"
        case .joker:
            return "joker"
        default:
            return id.rawValue
        } //swi
    } //cv

    static let ace = RawCardSymbol(id: .ace)
    static let _2 = RawCardSymbol(id: .v2)
    static let _3 = RawCardSymbol(id: .v3)
    static let _4 = RawCardSymbol(id: .v4)
    static let _5 = RawCardSymbol(id: .v5)
    static let _6 = RawCardSymbol(id: .v6)
    static let _7 = RawCardSymbol(id: .v7)
    static let _8 = RawCardSymbol(id: .v8)
    static let _9 = RawCardSymbol(id: .v9)
    static let _10 = RawCardSymbol(id: .v10)
    static let jack = RawCardSymbol(id: .jack)
    static let queen = RawCardSymbol(id: .queen)
    static let king = RawCardSymbol(id: .king)
    static let joker = RawCardSymbol(id: .joker)

//    static let ace = RawCardSymbol(display: "A", name: "ace", id: "ace")
//    static let _2 = RawCardSymbol(shortId: "2")
//    static let _3 = RawCardSymbol(shortId: "3")
//    static let _4 = RawCardSymbol(shortId: "4")
//    static let _5 = RawCardSymbol(shortId: "5")
//    static let _6 = RawCardSymbol(shortId: "6")
//    static let _7 = RawCardSymbol(shortId: "7")
//    static let _8 = RawCardSymbol(shortId: "8")
//    static let _9 = RawCardSymbol(shortId: "9")
//    static let _10 = RawCardSymbol(shortId: "10")
//    static let jack = RawCardSymbol(display: "J", name: "jack", id: "jack")
//    static let queen = RawCardSymbol(display: "Q", name: "queen", id: "queen")
//    static let king = RawCardSymbol(display: "K", name: "king", id: "king")
//    static let joker = RawCardSymbol(display: "R", name: "joker", id: "joker")
} //str
