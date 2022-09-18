//
//  PokerTableView.swift
//  CardPlay
//
//  Created by Ionut on 04.08.2022.
//

import SwiftUI
import GameKit

struct PokerTableView: View {
    @EnvironmentObject var gch: GCHelper
    @ObservedObject var game: HoldemGame
    @ObservedObject var viewedBy: PokerPlayer
    @ObservedObject var match: GKTurnBasedMatch
    @Namespace private var cardAnim_ns

    var body: some View {
        if viewedBy.joiningGame {
            JoiningTableView(game: game, viewedBy: viewedBy, match: match)
        } else {
            NonJoTableView(game: game, viewedBy: viewedBy, match: match)
        }
    } //body
} //str

