//
//  RawCardSuit.swift
//  CardPlay
//
//  Created by Ionut on 04.08.2021.
//

import Foundation

struct RawCardSuit: Equatable, Codable {
    let emo: String
    let name: String
    let id: String
    
    static let clubs = RawCardSuit(emo: "♣", name: "clubs", id: "clubs")
    static let hearts = RawCardSuit(emo: "♥", name: "hearts", id: "hearts")
    static let spades = RawCardSuit(emo: "♠", name: "spades", id: "spades")
    static let diamonds = RawCardSuit(emo: "♦", name: "diamonds", id: "diamonds")
    static let none = RawCardSuit(emo: "", name: "", id: "none")
    static let red = RawCardSuit(emo: "🟥", name: "red", id: "red")
    static let black = RawCardSuit(emo: "■", name: "black", id: "black")

    static let allSuits: [RawCardSuit] = [.hearts, .diamonds, .spades, .clubs]
    static let redSuits: [RawCardSuit] = [.hearts, .diamonds]
    static let blackSuits: [RawCardSuit] = [.spades, .clubs]
}
