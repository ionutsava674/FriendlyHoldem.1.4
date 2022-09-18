//
//  gameState.swift
//  CardPlay
//
//  Created by Ionut on 23.09.2021.
//

import Foundation
enum GameStateType: String, Codable, CaseIterable {
    case fresh //stable
    case negotiatingStructure //stable
    case startingGame
    case startingDeal,
         dealinghands,
         round1, //stable
         dealingFlop,
         round2, //stable
         dealingTurn,
         round3, //stable
         dealingRiver,
         round4, //stable
         computingShowdown,
    presentingShowdown, //stable
    finalShow //stable
    
    static let roundStates: Set<GameStateType> = [.round1, .round2, .round3, .round4]
    static let finalStates: Set<GameStateType> = [.computingShowdown, .presentingShowdown, .finalShow]
    static let stableStates: Set<GameStateType> = Set([.fresh, .negotiatingStructure, .presentingShowdown, .finalShow]).union( roundStates)
    
    static let longDescriptions: Dictionary<GameStateType, String> = [
        .fresh:  "the game just started",
        .negotiatingStructure: "we are agreeing on a game betting stakes",
        .startingGame: "the game is ready to start",
        .startingDeal: "a new deal is starting",
        .dealinghands: "dealing the hand cards",
        .round1: "we are in round 1, the pre-flop betting round",
        .dealingFlop: "dealing the flop cards",
        .round2: "we are in round 2, the flop betting round",
        .dealingTurn: "dealing the turn card",
        .round3: "we are in round 3, the turn betting round",
        .dealingRiver: "dealing the river card",
        .round4: "we are in round 4, the river betting round",
        .computingShowdown: "preparing for showdown",
        .presentingShowdown: "this is the showdown",
        .finalShow: "the game has ended"
    ] //dict
    static let shortDescriptions: Dictionary<GameStateType, String> = [
        .fresh:  "just started",
        .negotiatingStructure: "agreeing on the betting stakes",
        .startingGame: "preparing game",
        .startingDeal: "starting deal",
        .dealinghands: "dealing hands",
        .round1: "pre-flop round",
        .dealingFlop: "dealing flop",
        .round2: "flop round",
        .dealingTurn: "dealing turn",
        .round3: "turn round",
        .dealingRiver: "dealing river",
        .round4: "river round",
        .computingShowdown: "preparing showdown",
        .presentingShowdown: "showdown",
        .finalShow: "game over"
    ] //dict
    var longDescription: String {
        Self.longDescriptions[ self] ?? "the game is in an unknown state"
    } //func
    var shortDescription: String {
        Self.shortDescriptions[ self] ?? "unknown state"
    } //func
    func isRoundState() -> Bool {
        Self.roundStates.contains( self)
    } //func
} //enum
