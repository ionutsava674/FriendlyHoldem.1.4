//
//  RawCardSymbol.swift
//  CardPlay
//
//  Created by Ionut on 04.08.2021.
//

import Foundation

struct RawCardSymbol: Equatable, Codable {
    let display: String
    let name: String
    let id: String
    
    init(shortId: String) {
        display = shortId
        id = shortId
        name = shortId
    } //init
    init(display: String, name: String, id: String) {
        self.display = display
        self.name = name
        self.id = id
    } //init
    
    static let ace = RawCardSymbol(display: "A", name: "ace", id: "ace")
    static let _2 = RawCardSymbol(shortId: "2")
    static let _3 = RawCardSymbol(shortId: "3")
    static let _4 = RawCardSymbol(shortId: "4")
    static let _5 = RawCardSymbol(shortId: "5")
    static let _6 = RawCardSymbol(shortId: "6")
    static let _7 = RawCardSymbol(shortId: "7")
    static let _8 = RawCardSymbol(shortId: "8")
    static let _9 = RawCardSymbol(shortId: "9")
    static let _10 = RawCardSymbol(shortId: "10")
    static let jack = RawCardSymbol(display: "J", name: "jack", id: "jack")
    static let queen = RawCardSymbol(display: "Q", name: "queen", id: "queen")
    static let king = RawCardSymbol(display: "K", name: "king", id: "king")
    static let joker = RawCardSymbol(display: "R", name: "joker", id: "joker")
} //str
