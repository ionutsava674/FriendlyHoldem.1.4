//
//  MatchView.swift
//  CardPlay
//
//  Created by Ionut on 02.12.2021.
//

import SwiftUI
import GameKit

struct MatchView: View {
    @EnvironmentObject var gch: GCHelper
    @ObservedObject var match: GKTurnBasedMatch
    @Namespace var ns_gameviewid
    
    @Environment(\.scenePhase) var scenePhase
    @State private var appActive = true
    let matchRefreshTimer = Timer.publish( every: 20.45, tolerance: 3.20, on: .main, in: .common, options: nil).autoconnect()
    
    @MainActor func refreshTimerProc() -> Void {
        guard self.appActive else {
            return
        }
        Task {
            _ = await self.gch.refreshCurrentMatch()
        }
    } //func
    
    var body: some View {
        let localGamePlayer = gch.currentGame?.allPlayers.get( by: match.localParticipantIndex() ?? -1)
        return ZStack {
            Text("\(self.gch.currentGame?.gameState.rawValue ?? "")").hidden()
            Text("\(localGamePlayer?.matchParticipantIndex ?? -1)").hidden()
            VStack {
                switch match.status {
                    /*
                case .ended:
                    VStack {
                        Text("This game has ended.")
                        Button("Main menu") {
                            Task {
                     self.gch.ClearCurrentMatch()
                        } //btn
                    } //vs
                     */
                case .matching, .open, .ended:
                    if gch.currentGame != nil
                    && localGamePlayer != nil {
                        GameView( gameModel: gch.currentGame!, viewedBy: localGamePlayer!, match: match)
                            .matchedGeometryEffect(id: "gvid\( match.matchID)", in: self.ns_gameviewid)
                            .onReceive(matchRefreshTimer) { time in
                                refreshTimerProc()
                            } //rec
                    } else {
                        Text("There was a problem loading the game data.")
                    }
                default:
                    Text("An unexpected problem has occured.")
                } //swi
            } //vs
            .confirmationDialog(Text("Attention"), isPresented: self.$gch.showingQuitDialog, titleVisibility: .visible) {
                Button(role: .destructive) {
                    Task {
                        _ = await self.gch.gameCtl.quit(match, with: nil)
                        _ = await self.gch.refreshCurrentMatch()
                    }
                } label: {
                    Text("Leave game")
                } //btn
                Button(role: .cancel) {
                    // cancel
                } label: {
                    Text("Stay in the game")
                } //btn
            } message: {
                Text("Are you really really sure you want to quit this game?")
            } //conf
        } //zs
        .onChange(of: scenePhase, perform: { newValue in
            self.appActive = (newValue == .active)
        }) //scene change
    } //body
} //str
