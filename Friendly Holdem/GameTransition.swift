//
//  GameTransition.swift
//  CardPlay
//
//  Created by Ionut on 12.11.2021.
//

import Foundation
import SwiftUI

class GameTransition: Codable {
    var fromState: Data?
    var toState: Data?
    var actionTaken: GameTransitionAction
    var shouldReEnact: Bool
    var customMessage: String?// = ""
    
    static func newEmptyTransition() -> GameTransition {
        return GameTransition( actionTaken: .none, reEnact: false, fromState: nil)
    }
    init(actionTaken: GameTransitionAction, reEnact: Bool, fromState: Data?) {
        self.actionTaken = actionTaken
        self.shouldReEnact = reEnact
        self.fromState = fromState
        self.toState = nil
    } //init
    init?(gameSnapshot: HoldemGame?, reenactmentAction: GameTransitionAction) {
        guard let game = gameSnapshot else {
            return nil
        }
        guard let gameData = game.toJSON() else {
            return nil
        }
        self.fromState = gameData
        self.toState = nil
        self.shouldReEnact = true
        self.actionTaken = reenactmentAction
    }
    func toJSON() -> Data? {
        try? JSONEncoder().encode(self)
    } //func
    static func getFinalGameFromTransition(_ transitionData: Data?) -> HoldemGame? {
        guard let data = transitionData,
              let tr = try? JSONDecoder().decode(GameTransition.self, from: data)
        else {
            return nil
        } //gua
        guard let newGameData = tr.toState,
              let newGame = try? JSONDecoder().decode(HoldemGame.self, from: newGameData)
        else {
            return nil
        }
        return newGame
    } //func
    static func gameToSourcelessTransitionData( _ game: HoldemGame) -> Data? {
        guard let gd = game.toJSON() else {
            return nil
        } //gua
        let gt = GameTransition(actionTaken: .none, reEnact: false, fromState: nil)
        gt.toState = gd
        return gt.toJSON()
    } //func
} //class
enum GameTransitionAction: Int, Codable {
    case none
    case startedGame, dealtFlop, dealtTurn, dealtRiver
    case wentToShowdown, gameEnded
    case raised, bet, smallBlind, bigBlind
    case called
    case stayed
    case checked
    case wentAllIn
    case dropped
} //enum
