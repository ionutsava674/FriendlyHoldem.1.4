//
//  CardStack.swift
//  CardPlay
//
//  Created by Ionut on 04.08.2021.
//

import Foundation

class CardStack: ObservableObject, Codable {
    enum CodingKeys: CodingKey {
    case cards, ownerPlayer, whoCanSee
    }
    @Published private(set) var cards: [Card]
    var ownerPlayer: PokerPlayer.IndexType?
    @Published var whoCanSee: WhoCanSee
    
    init( cards: [Card], ownerIndex: PokerPlayer.IndexType?, whoCanSee: WhoCanSee) {
        self.cards = cards
        self.ownerPlayer = ownerIndex
        self.whoCanSee = whoCanSee
    } //init
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cards, forKey: .cards)
        try container.encode(ownerPlayer, forKey: .ownerPlayer)
        try container.encode(whoCanSee, forKey: .whoCanSee)
    } //enc
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        cards = try container.decode([Card].self, forKey: .cards)
        ownerPlayer = try container.decode(PokerPlayer.IndexType?.self, forKey: .ownerPlayer)
        whoCanSee = try container.decode(WhoCanSee.self, forKey: .whoCanSee)
    }
    func putStaticCards(from: [Card]) -> Void {
        //debugMsg_("putting ")
        let newCards: [Card] = cards.map({ eachOldCard in
            from.first(where: {
                $0.id == eachOldCard.id
            }) ?? eachOldCard
        }) //map
        self.cards = newCards
        /*
        for i in cards.indices {
            if let found = from.first(where: {
                $0.id == cards[i].id
            }) {
                cards[i] = found
            }
        } //for
         */
        /*
        for i in cards.indices {
            cards[i] = from.first(where: {
                $0.id == cards[i].id
            }) ?? cards[i]
        } //for
         */
    } //func
    func canBeSeen( by player: PokerPlayer.IndexType?) -> Bool {
        whoCanSee == .everyOne
        || ( whoCanSee == .ownerOnly && player == ownerPlayer )
    }
    enum StackPrintType {
        case short, medium, long
    } //enum
    func getString( printType: StackPrintType) -> String {
        (cards.map { c in
            switch printType {
            case .short:
                return c.rawCard.symbol.display
            case .medium:
                return "\(c.rawCard.symbol.display) \(c.rawCard.suit.name)"
            default:
                return c.readableName
            }
        }).joined(separator: ", ")
    } //print func
    func clearCards() -> Void {
        cards = []
    } //clear
    func give( card: Card, to stack: CardStack) -> Bool {
        guard cards.contains(where: { c in
            c.id == card.id
        }) else {
            return false
        }
        cards.removeAll { c in
            c.id == card.id
        }
        stack.cards.append( card)
        card.triggerViewChange()
        //debugMsg_("rrig1")
        return true
    } //func
    func giveLastCard( to stack: CardStack) -> Bool {
        if let card = (cards.last) {
            return give( card: card, to: stack)
        }
        return false
    } //func
    
    func getBestInterpretationHand() -> InterpretationHand {
        var startHand = InterpretationHand()
        getInterpretations { eachHand in
            if PokerHandRank.compareHands( hand1: startHand, hand2: eachHand) == .secondWins {
                startHand = eachHand
            } //if
        } //get interpretations
        return startHand
    } //func
    func getInterpretations( doWithHand: (InterpretationHand) -> Void) -> Void {
        var data = cards.map { _ in
            CardInterpretation(suit: .none, value: 0)
        }
        listInterpretations(interpretations: &data, stackIndex: 0, doWithHand: doWithHand)
    }
    private func listInterpretations( interpretations: inout InterpretationHand, stackIndex: Int, doWithHand: (InterpretationHand) -> Void) -> Void {
        guard cards.indices.contains(stackIndex) else {
            return
        }
        let card = cards[stackIndex]
        for interpretation in card.interpretations {
            interpretations[stackIndex] = interpretation
            if stackIndex < cards.count - 1 {
                listInterpretations(interpretations: &interpretations, stackIndex: stackIndex + 1, doWithHand: doWithHand)
            } else {
                doWithHand(interpretations)
            } //if
        } //for
    } //list ints func
    
    enum WhoCanSee: String, Codable {
    case noOne, everyOne, ownerOnly
    } //enum
    
    static let emptyStackForViewing = CardStack(cards: Card.noCards, ownerIndex: nil, whoCanSee: .noOne)
} //stk
