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
    
    func localizedDisplayName() -> String {
        type.localizedDisplayName()
    } //func
    
    init(_ type: ActionType) {
        self.type = type
    } //init
    enum ActionType: String, Codable {
    case drop, check, call, bet, raise, allInBet, stay
        
        func localizedDisplayName() -> String {
            switch self {
            case .drop:
                return NSLocalizedString("throw", comment: "action name")
            case .check:
                return NSLocalizedString("check", comment: "action name")
            case .call:
                return NSLocalizedString("call", comment: "action name")
            case .bet:
                return NSLocalizedString("bet", comment: "action name")
            case .raise:
                return NSLocalizedString("raise", comment: "action name")
            case .allInBet:
                return NSLocalizedString("bet all", comment: "action name")
            case .stay:
                return NSLocalizedString("stay all in", comment: "action name")
            } //swi
        } //func
    } //enum //enum
} //act
