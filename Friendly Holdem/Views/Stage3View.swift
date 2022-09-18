//
//  Stage3View.swift
//  CardPlay
//
//  Created by Ionut on 05.11.2021.
//

import SwiftUI
import GameKit

struct Stage3View: View {
    @State private var iq = false
    let localPlayer = GKLocalPlayer.local
    let forId: String
    @ObservedObject private var gch = GCHelper.helper
    @Namespace private var cardAnim
    @State private var showingDebugOutput = false
    var body: some View {
        VStack {
            HStack {
            Button("see output") {
                showingDebugOutput = true
            } //btn
                Button("players") {
                    var msg = "\(gch.currentGame?.currentBetSize ?? -1)"
                    gch.currentGame?.allPlayers.forEach({ pp in
                        msg += "\r\n\(pp.matchParticipantIndex): \(pp.placedInBet)"
                    })
                    gch.displayError(msg: msg + gch.printGamePlayers())
                } //btn
            if gch.currentMatch?.isLocalPlayersTurn() ?? false {
            Button("re create game") {
                _ = gch.recreateGame(turn: gch.curTurn ?? UUID())
            } //btn
            } //if
            } //hs
        Text("welcome, \(localPlayer.displayName)")
            Text("\(self.gch.currentGame?.gameState.rawValue ?? "")").hidden()
            Text("\(self.gch.currentMatch?.matchID ?? "")").hidden()
            if gch.currentGame != nil && gch.currentMatch != nil {
                GameView(gameModel: gch.currentGame!, viewedBy: PokerPlayer(index: -2, initialChips: 0) , match: gch.currentMatch!)
                    .environmentObject( gch)
            } //if
        } //vs
        .alert(item: self.$gch.errorDialog, content: { errCon in
            Alert(title: Text(errCon.msg), message: nil, dismissButton: .default(Text("OK")))
        })
        .onReceive(NotificationCenter.default.publisher(for: .presentGame, object: nil), perform: { po in
            //po.object
            debugMsg_("received turn 02")
        })
        .sheet(isPresented: $showingDebugOutput, onDismiss: {
            //
        }, content: {
            DebugView()
        })

    } //body
} //str
