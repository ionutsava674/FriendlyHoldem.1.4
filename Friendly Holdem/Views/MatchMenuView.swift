//
//  MatchMenuView.swift
//  CardPlay
//
//  Created by Ionut on 11.12.2021.
//

import SwiftUI
import GameKit

struct MatchMenuView: View {
    @EnvironmentObject var gch: GCHelper
    var onMenuItemSelected: (() -> Void)?
    @Environment(\.accessibilityReduceMotion) private var shouldReduceMotion
    @State private var newProgGameConfirmation = false
    @State private var choosingNumberOfPlayers = false
    @Namespace var nsID
    
    @State private var showingNewGameDialog: MatchMakerRequestContainer?
    @State private var showingHowToHelp = false
    @MainActor func FindNewGame( with players: Int) async -> Void {
        await gch.ClearCurrentMatch()
        await gch.FindNewGame( with: players)
    } //func
    func requestNewGame( with players: Int) -> Void {
        let req = GKMatchRequest()
        req.minPlayers = players
        req.maxPlayers = players
        req.inviteMessage = "How about a friendly game of hold'em"
        req.defaultNumberOfPlayers = players
        self.showingNewGameDialog = MatchMakerRequestContainer(request: req)
    } //func

    var body: some View {
        ZStack {
        VStack {
            Text("What would you like to do?")
                .padding()
        LeastWidthContainer { leastWidth in
        VStack(alignment: .center, spacing: 16) {
        //List() {
            Button {
                //_ = self.gch.downloadAvailableMatches()
                Task {
                    await gch.downloadAvailableMatches()
                }
                self.onMenuItemSelected?()
            } label: {
                self.gch.retrievingAvailableMatches
                ? Text("Retrieving game list")
                : Text("Continue a game that was already started")
            } //btn
            .fitToWidth(leastWidth)
            Button(action: {
                withAnimation {
                    //self.choosingNumberOfPlayers = true
                    if !gch.findingNewGame {
                        self.newProgGameConfirmation = true
                    } //if
                } //anim
            }, label: {
                Text( self.gch.findingNewGame
                      ? NSLocalizedString("Looking for a new game", comment: "")
                      : NSLocalizedString("Find a new game", comment: "")
                ) //text
                    .fitToWidth(leastWidth)
            }) //btn
            .disabled( gch.findingNewGame)
            //.alert("Finding a new game", isPresented: $showingFindingProgress, actions: { })
            .confirmationDialog("Find new game", isPresented: $newProgGameConfirmation, actions: {
                    ForEach(2..<9, id: \.self) { nop in
                        Button("\(nop) players", action: {
                            //let match = GKTurnBasedMatch.init()
                            Task {
                                await FindNewGame(with: nop)
                            }
                            self.onMenuItemSelected?()
                        }) //btn
                    } //fe
                }, message: {
                    Text("How many players")
                }) //dialog
            /*
            if !choosingNumberOfPlayers {
                Button(action: {
                    withAnimation {
                        self.choosingNumberOfPlayers = true
                    }
                }, label: {
                    Text("begin new game")
                        .matchedGeometryEffect(id: "dialogTitle", in: self.nsID)
                        .fitToWidth(leastWidth)
                }) //btn
                    .sheet(item: self.$showingNewGameDialog) {
                        //debugMsg_("new game dialog dismissed")
                        self.onMenuItemSelected?()
                    } content: { rqc in
                        GameCenterNewGameDialog( withRequest: rqc.request)
                    } //request sheet
            } //if btn visible
            else {
                NumberOfPlayersChooser( title: "New game", isPresented: $choosingNumberOfPlayers.animation(), onSelected: { nrOfPlayers in
                    self.requestNewGame( with: nrOfPlayers)
                }, nsID: self.nsID)
            } //else
            */
            Divider()
                .fitToWidth(leastWidth)
            Button {
                self.showingHowToHelp = true
            } label: {
                Text("How to start, step by step")
            } //btn
            .fitToWidth(leastWidth)
            .sheet(isPresented: $showingHowToHelp) {
                HowToBegin()
            }
        } //vs
        .font(.title)
        } //least width container
        } //vs0
            if gch.findingNewGame {
                Text("Looking for a new game")
                    .font(.title.bold())
                    .padding(32)
                    .foregroundColor(.primary)
                    .roundedDoubelBorder(Color.primary, radius: 4)
                    .background( Color( uiColor: .secondarySystemBackground))
                    .accessibilityAddTraits(.isModal)
                    .transition(.scale.applyReduceMotion( reduceMotion: shouldReduceMotion, allowFade: true))
            }
        } //zs
    } //body
} //str

class MatchMakerRequestContainer: Identifiable {
    let id = UUID()
    var request: GKMatchRequest
    init(request: GKMatchRequest) {
        self.request = request
    }
} //rq container
