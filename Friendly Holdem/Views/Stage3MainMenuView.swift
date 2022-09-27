//
//  Stage3v2View.swift
//  CardPlay
//
//  Created by Ionut on 01.12.2021.
//

import SwiftUI
import GameKit

struct Stage3MainMenuView: View {
    @AppStorage("savedMatch") private var savedMatch: String = ""
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let localPlayer = GKLocalPlayer.local
    @ObservedObject private var gch = GCHelper.helper
    
    #if DEBUG
    @State private var showingDebugOutput = false
    #endif
    
    @AccessibilityFocusState private var titleFocused: Bool
    let appearAnimDelay: TimeInterval = 0.7

    var body: some View {
        ZStack {
            HStack {
            Text("\(self.gch.currentGame?.gameState.rawValue ?? "")").hidden()
            Text("\(self.gch.currentMatch?.matchID ?? "")").hidden()
                Text("\(self.gch.availableMatches?.count ?? 0)").hidden()
                Text("\(self.gch.errorDialog?.msg ?? "")").hidden()
            } //hhs
        VStack {
            if gch.currentMatch == nil {
                VStack(alignment: .center, spacing: 50) {
                    #if DEBUG
                    if debugHeaderRow {
                        HStack {
                            Button("TestO") {
                                //test4Outcomes().testOutcomes( numberOfPlayers: 3)
                                //BetRaiseAmountPicker.testSomeIntervals()
                            }
                            Button("Load") {
                                guard !savedMatch.isEmpty else {
                                    return
                                }
                                _ = self.gch.selectAvailableMatch(matchID: savedMatch)
                            }
                        Button("see output") {
                            showingDebugOutput = true
                        } //btn
                            Button("players") {
                                if let game = gch.currentGame,
                                   let match = gch.currentMatch {
                                    let outcomes = match.printOutcomes()
                                    let names = match.printInitials()
                                    let joining = match.printIfJoining(in: game)
                                    gch.displayError( msg: "\(names);\n\(outcomes),\n\(joining)")
                                } //ifl
                                else {
                                    gch.displayError( msg: "no game")
                                }
                            } //btn
                        } //debug hs
                        .background(.red)
                        .foregroundColor(.white)
                    } //if
                    #endif
                    Text("welcome, \(localPlayer.displayName)")
                            .font(.title.bold())
                            .accessibilityFocused($titleFocused)
                    MatchMenuView()
                        .environmentObject( gch)
                } //vs
                .transition(.scale.applyReduceMotion(reduceMotion: reduceMotion, allowFade: true))
            } //if
            else {
                MenuAndMatchView(match: gch.currentMatch!)
                    .environmentObject( gch)
                    .transition(.scale.applyReduceMotion(reduceMotion: reduceMotion, allowFade: true))
            } //else
        } //main vs
        .alert(Text(self.gch.errorDialog?.title ?? ""),
               isPresented: self.$gch.showingErrorDialog,
               presenting: self.gch.errorDialog,
               actions: { ed in
            //
        }, message: { ed in
            Text( ed.msg)
        })
        .animation(.default, value: self.gch.currentMatch == nil)
        } //zs
        .sheet(item: self.$gch.availableMatches, onDismiss: {
            //dismiss
        }, content: { matchList in
            ExistingMatchChooserView(matchList: matchList, onSelect: { match in
                _ = self.gch.selectAvailableMatch( matchID: match.matchID, onError: { error in
                }) //clo
            }) //chooser
                .environmentObject( self.gch)
        }) //sheet
        #if DEBUG
        .sheet(isPresented: $showingDebugOutput, onDismiss: {
            //
        }, content: {
            if debugBuffer {
                DebugView()
            }
            else {
                EmptyView()
            }
        }) //debug sheet
        #endif
        .alert(item: self.$gch.turnEventConfirmation, content: { confirmation in
            Alert(title: Text("Received event for a different game"),
                  message: Text("The game \( MatchLocalizer.title( of: confirmation.receivedFor) ) has received an update. \( MatchLocalizer.itsWhoosTurnText( of: confirmation.receivedFor) ?? ""). Would you like to switch to it?"),
                  primaryButton: Alert.Button.default( Text( "switch"), action: {
                _ = gch.selectAvailableMatch(matchID: confirmation.receivedFor.matchID)
            }) ,
                  secondaryButton: Alert.Button.cancel(Text("ignore")) )
        }) //alert
    } //body
} //str

typealias mlArray = [GKTurnBasedMatch]
extension mlArray: Identifiable {
    public var id: String {
        self.map({
            $0.matchID
        }).joined(separator: "")
    }
} //ext
