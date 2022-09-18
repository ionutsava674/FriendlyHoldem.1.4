//
//  PokerPlayerAction.swift
//  CardPlay
//
//  Created by Ionut on 26.11.2021.
//

import Foundation

class PokerPlayerAction: Codable, Identifiable {
    static func drop() -> PokerPlayerAction { PokerPlayerAction(.drop) }
    static func check() -> PokerPlayerAction { PokerPlayerAction(.check) }
    static func bet() -> PokerPlayerAction { PokerPlayerAction(.bet) }
    static func raise() -> PokerPlayerAction { PokerPlayerAction(.raise) }
    static func allInBet() -> PokerPlayerAction { PokerPlayerAction(.allInBet) }
    static func call() -> PokerPlayerAction { PokerPlayerAction(.call) }
    static func stayAllIn() -> PokerPlayerAction { PokerPlayerAction(.stay) }
    
    private(set) var id: UUID = UUID()
    let type: ActionType
    
    func displayName() -> String {
        type.displayName()
    } //func
    
    init(_ type: ActionType) {
        self.type = type
    } //init
    enum ActionType: String, Codable {
    case drop, check, call, bet, raise, allInBet, stay
        
        func displayName() -> String {
            switch self {
            case .drop:
                return NSLocalizedString("throw", comment: "")
            case .check:
                return NSLocalizedString("Check", comment: "")
            case .call:
                return NSLocalizedString("Call", comment: "")
            case .bet:
                return NSLocalizedString("Bet", comment: "")
            case .raise:
                return NSLocalizedString("Raise", comment: "")
            case .allInBet:
                return NSLocalizedString("Bet all", comment: "")
            case .stay:
                return NSLocalizedString("Stay all in", comment: "")
            } //swi
        } //func
    } //enum //enum
} //act
