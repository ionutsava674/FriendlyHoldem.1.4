//
//  gameView.swift
//  CardPlay
//
//  Created by Ionut on 17.08.2021.
//

import SwiftUI
import GameKit

struct GameView: View {
    @EnvironmentObject var gch: GCHelper
    @ObservedObject var gameModel: HoldemGame
    @ObservedObject var viewedBy: PokerPlayer
    @ObservedObject var match: GKTurnBasedMatch
    
    var body: some View {
        VStack {
        switch gameModel.gameState {
        case .negotiatingStructure:
            if match.isLocalPlayersTurn() && !viewedBy.volaChose {
                AgreeingView( gameModel: gameModel, viewingPlayer: viewedBy, match: match)
            } else {
                AgreeingInactive( gameModel: gameModel, match: match)
            }
        case .computingShowdown, .presentingShowdown:
            ShowdownView(game: gameModel, viewedBy: viewedBy, match: match)
        case .finalShow:
            FinalShowView(game: gameModel, viewedBy: viewedBy, match: match)
        case  .fresh, .startingGame, .startingDeal, .dealinghands, .round1, .dealingFlop, .round2, .dealingTurn, .round3, .dealingRiver, .round4:
            PokerTableView(game: gameModel, viewedBy: viewedBy, match: match)
                //.matchedGeometryEffect(id: "cgclsvid\( match.matchID)", in: self.ns_cgcviewid)
                //.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            //CardGameContainerView( gameModel: gameModel, viewedBy: viewedBy, match: match)
        } //swi
        } //vs
    } //body
} //gv

