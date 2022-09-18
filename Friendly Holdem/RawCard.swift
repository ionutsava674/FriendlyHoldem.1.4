//
//  RawCard.swift
//  CardPlay
//
//  Created by Ionut on 02.08.2021.
//

import SwiftUI

class RawCard: Codable {
    let suit: RawCardSuit
    let symbol: RawCardSymbol
    //lazy var emoji: String = {""}() //later
    lazy var id: String = {
        "\(suit.id)_\(symbol.id)"
    }()
    lazy var readableName: String = {
        "\(symbol.name) of \(suit.name)"
    }()
    init(suit: RawCardSuit, symbol: RawCardSymbol) {
        self.suit = suit
        self.symbol = symbol
    } //init
    
    static let cardSizeRatio: CGFloat = {
        guard let sample = UIImage(named: "clubs_2") else {
            return 1.0
        }
        return sample.size.height / sample.size.width
    }()
    
} //rawcard