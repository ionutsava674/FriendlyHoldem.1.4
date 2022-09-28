//
//  RawCardSuit.swift
//  CardPlay
//
//  Created by Ionut on 04.08.2021.
//

import Foundation

struct RawCardSuit: Equatable, Codable {
    enum SuitID: Int, Codable {
    case none, clubs, diamonds, hearts, spades
    } //enum
    let id: SuitID
    var emo: String {
        switch id {
        case .none:
            return ""
        case .clubs:
            return "♣"
        case .diamonds:
            return "♦"
        case .hearts:
            return "♥"
        case .spades:
            return "♠"
        } //sw
    } //cv
    var name: String {
        switch id {
        case .none:
            return ""
        case .clubs:
            return String(localized: "clubs.suit", defaultValue: "clubs", comment: "clubs suit")
        case .diamonds:
            return String(localized: "diamonds.suit", defaultValue: "diamonds", comment: "clubs suit")
        case .hearts:
            return String(localized: "hearts.suit", defaultValue: "hearts", comment: "clubs suit")
        case .spades:
            return String(localized: "spades.suit", defaultValue: "spades", comment: "clubs suit")
        } //sw
    } //cv
    var originalName: String {
        switch id {
        case .none:
            return ""
        case .clubs:
            return "clubs"
        case .diamonds:
            return "diamonds"
        case .hearts:
            return "hearts"
        case .spades:
            return "spades"
        } //sw
    } //cv

    static let clubs = RawCardSuit(id: .clubs)
    static let hearts = RawCardSuit(id: .hearts)
    static let spades = RawCardSuit(id: .spades)
    static let diamonds = RawCardSuit(id: .diamonds)
    static let none = RawCardSuit(id: .none)
    //static let red = RawCardSuit(emo: "🟥", name: "red", id: "red")
    //static let black = RawCardSuit(emo: "■", name: "black", id: "black")

    static let allSuits: [RawCardSuit] = [.hearts, .diamonds, .spades, .clubs]
    static let redSuits: [RawCardSuit] = [.hearts, .diamonds]
    static let blackSuits: [RawCardSuit] = [.spades, .clubs]
}
