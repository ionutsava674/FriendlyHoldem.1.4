//
//  LastActionLine.swift
//  Friendly Holdem
//
//  Created by Ionut on 20.09.2022.
//

import SwiftUI
import GameKit

struct LastActionLine: View {
    @ObservedObject var gameModel: HoldemGame
    @ObservedObject var viewedBy: PokerPlayer
    @ObservedObject var match: GKTurnBasedMatch
    
    var body: some View {
        if let lastEntry = gameModel.gameLog.last {
            Text( lastEntry.print(for: gameModel, and: match).capitalizingFirst() )
                // .textCase(.lowercase)
        } //if
    } //body
} //str
