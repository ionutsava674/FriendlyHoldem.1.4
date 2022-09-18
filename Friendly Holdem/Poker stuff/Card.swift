//
//  Card.swift
//  CardPlay
//
//  Created by Ionut on 02.08.2021.
//

import Foundation

class Card: ObservableObject, Identifiable, Codable {
    enum CodingKeys: CodingKey {
        case rawCard//: RawCard
        case actAsValue//: [Int]
        case actAsSuit//: [RawCardSuit]
        //case viewChangeTrigger//: Bool
    } //enum
    let rawCard: RawCard
    private let actAsValue: [Int]
    private let actAsSuit: [RawCardSuit]
    @Published var viewChangeTrigger: Bool = false
    
    var id: String { rawCard.id }
    var readableName: String { rawCard.readableName }
    lazy var interpretations: [CardInterpretation] = {
        actAsValue.reduce( into: [CardInterpretation]()) { r, value in
            for suit in actAsSuit {
                r.append(CardInterpretation(suit: suit, value: value))
            }
        }
    }() //lazy
    
    
    func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode( rawCard, forKey: .rawCard)
        try container.encode( actAsSuit, forKey: .actAsSuit)
        try container.encode( actAsValue, forKey: .actAsValue)
        //try container.encode( viewChangeTrigger, forKey: .viewChangeTrigger)
    } //func
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        rawCard = try container.decode( RawCard.self, forKey: .rawCard)
        actAsValue = try container.decode( [Int].self, forKey: .actAsValue)
        actAsSuit = try container.decode( [RawCardSuit].self, forKey: .actAsSuit)
        //viewChangeTrigger = try container.decode( Bool.self, forKey: .viewChangeTrigger)
        viewChangeTrigger = false
    } //func
    init(rawCard: RawCard, actSuits: [RawCardSuit], actValues: [Int]) {
        self.rawCard = rawCard
        self.actAsSuit = actSuits
        self.actAsValue = actValues
        self.viewChangeTrigger = false
    } //init
    func triggerViewChange() {
        viewChangeTrigger.toggle()
    }
    
    static let noCards = [Card]()
} //card
