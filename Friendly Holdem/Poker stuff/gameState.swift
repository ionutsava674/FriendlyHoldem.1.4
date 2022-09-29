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
        .fresh:  String(localized: "the game just started"),
        .negotiatingStructure: String(localized: "we are agreeing on a game betting stakes"),
        .startingGame: String(localized: "the game is ready to start"),
        .startingDeal: String(localized: "a new deal is starting"),
        .dealinghands: String(localized: "dealing the hand cards"),
        .round1: String(localized: "we are in round 1, the pre-flop betting round"),
        .dealingFlop: String(localized: "dealing the flop cards"),
        .round2: String(localized: "we are in round 2, the flop betting round"),
        .dealingTurn: String(localized: "dealing the turn card"),
        .round3: String(localized: "we are in round 3, the turn betting round"),
        .dealingRiver: String(localized: "dealing the river card"),
        .round4: String(localized: "we are in round 4, the river betting round"),
        .computingShowdown: String(localized: "preparing for showdown"),
        .presentingShowdown: String(localized: "this is the showdown"),
        .finalShow: String(localized: "the game has ended")
    ] //dict
    static let shortDescriptions: Dictionary<GameStateType, String> = [
        .fresh:  String(localized: "just started"),
        .negotiatingStructure: String(localized: "agreeing on the betting stakes"),
        .startingGame: String(localized: "preparing game"),
        .startingDeal: String(localized: "starting deal"),
        .dealinghands: String(localized: "dealing hands"),
        .round1: String(localized: "pre-flop round"),
        .dealingFlop: String(localized: "dealing flop"),
        .round2: String(localized: "flop round"),
        .dealingTurn: String(localized: "dealing turn"),
        .round3: String(localized: "turn round"),
        .dealingRiver: String(localized: "dealing river"),
        .round4: String(localized: "river round"),
        .computingShowdown: String(localized: "preparing showdown"),
        .presentingShowdown: String(localized: "showdown"),
        .finalShow: String(localized: "game over")
    ] //dict
    var longDescription: String {
        Self.longDescriptions[ self] ?? String(localized: "the game is in an unknown state")
    } //func
    var shortDescription: String {
        Self.shortDescriptions[ self] ?? String(localized: "unknown state")
    } //func
    func isRoundState() -> Bool {
        Self.roundStates.contains( self)
    } //func
} //enum
