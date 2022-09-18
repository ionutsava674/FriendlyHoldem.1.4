//
//  InactiveActionMenuView.swift
//  CardPlay
//
//  Created by Ionut on 29.06.2022.
//

import SwiftUI
import GameKit

struct InactiveActionMenuView: View {
    @ObservedObject var gameModel: HoldemGame
    @ObservedObject var viewedBy: PokerPlayer
    @ObservedObject var match: GKTurnBasedMatch
    
    @EnvironmentObject var gch: GCHelper

    var body: some View {
        VStack {
            if viewedBy.joiningGame {
                Text( GameController.nowItsWhosReallyTurn(in: gameModel, and: match) ?? "the current turn is unknown" )
            } //if
            else {
                Text("You are no longer in the game \(viewedBy.chips) left")
            } //else
            //if gameModel.timeoutToUse > 0 {
                //Text("Time limit: ") + Text(match.lastActionDate() + gameModel.timeoutToUse, style: .offset)
            //}
            } //vs
    } //body
} //str

