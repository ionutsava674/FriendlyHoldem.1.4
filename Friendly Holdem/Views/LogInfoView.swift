//
//  LogInfoView.swift
//  CardPlay
//
//  Created by Ionut on 13.09.2022.
//

import SwiftUI
import GameKit

struct LogInfoView: View {
    @Binding var isPresented: Bool
    var dismissable: Bool
    @ObservedObject var game: HoldemGame
    @ObservedObject var match: GKTurnBasedMatch
    @ObservedObject var viewedBy: PokerPlayer
    
    @AccessibilityFocusState private var voFocused: String?
    var body: some View {
        VStack(spacing: 16) {
            Text("This is what happened so far in the game:")
                .font(.headline.bold())
            ScrollViewReader { svp in
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .leading, spacing: 0) {
                        ForEach(Array( game.gameLog.enumerated() ), id: \.offset) { (index, entry) in
                            Text( entry.print( for: game, and: match))
                                .id("gl\(match.matchID)\(index)")
                                .accessibilityFocused($voFocused, equals: "vogl\(match.matchID)\(index)")
                                .padding(8)
                        } //fe
                    } //vs
                    .background(.blue.bright(amount: 0.1))
                } //sv
                HStack(spacing: 12) {
                    Button {
                        if let index = lastActionIndex( of: viewedBy) {
                            withAnimation {
                                svp.scrollTo("gl\(match.matchID)\(index)", anchor: .top)
                                self.voFocused = "vogl\(match.matchID)\(index)"
                            }
                        }
                    } label: {
                        Text("Your last action")
                    } //btn
                    Button {
                        if let index = game.gameLog.lastIndex( where: { _ in true }) {
                            withAnimation {
                                svp.scrollTo("gl\(match.matchID)\(index)", anchor: .top)
                                self.voFocused = "vogl\(match.matchID)\(index)"
                            }
                        }
                    } label: {
                        Text("Jump to latest")
                    } //btn
                } //hs
            } //svr
            if dismissable {
                Button {
                    //withAnimation(.easeIn(duration: 4)) {
                        self.isPresented = false
                    //}
                } label: {
                    Text("OK")
                        .font(.title.bold())
                        .padding(.horizontal)
                        .padding()
                        .accessibilityElement(children: .combine)
                } //btn
                // .padding(.top)
            } //if
        } //vs
        .foregroundColor(.white)
        .frame(maxHeight: 450, alignment: .center)
        .padding(18)
        .roundedDoubleBorder(.white, radius: 8, lineWidth: 1.5, withBackground: .blue.bright(amount: 0.6))
    } //body
    
    func lastActionIndex( of player: PokerPlayer) -> Int? {
        game.gameLog.lastIndex( where: { entry in
            entry.actors?.contains(where: { mpi in
                mpi == player.matchParticipantIndex
            }) ?? false
        }) //last
    } //func
} //str

