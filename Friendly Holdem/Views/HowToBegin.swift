//
//  HowToBegin.swift
//  CardPlay
//
//  Created by Ionut on 08.09.2022.
//

import SwiftUI

struct HowToBegin: View {
    @Environment(\.dismiss) private var dismiss
    @AccessibilityFocusState private var TitleAxFocused: Bool
    private let appearAnimDuration: TimeInterval = 0.7
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Text("How to begin a game")
                .font(.title.bold())
                .padding()
                .accessibilityFocused( $TitleAxFocused)
            ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Finding a game works like this")
                    .font(.headline)
                Group {
                    Text("First, tap \"Find a new game\" and then select the number of players you wish the game to have.")
                    Text("For example, let's say you chose 3")
                    Text("Game Center will search for a game for 3, with at least one free slot")
                    Text("And will put you in that slot.")
                    Text("If no existing game was found, a new game is created and you will fill the first slot.")
                    Text("After the new game is opened, you get to choose the game stakes.")
                    Text("Then, when another player searches for a game for 3, they will be automatically selected to the remaining slots.")
                    Text("Only after you choose the stakes, others can join the game. This is so that, when you join a game, you get to interract immediately.")
                    Text("When someone joins your game, or when it's your turn to act, you will be notified.")
                } //gr
                Text("Choosing the game stakes")
                    .font(.headline)
                Group {
                    Text(" This game is entertainment only, no actual money is involved.")
                    Text(" At first, each one gets to propose a game structure, consisting of initial amount and bet sizes.")
                    Text(" After that, if different variants were proposed, everyone gets to choose again from these Structures.")
                    Text(" If still there are different choices, the most popular variant is automatically selected.")
                }
            } //vs2
            .padding(8)
            } //sv
            Button {
                self.dismiss()
            } label: {
                Text("OK")
                    .font(.title.bold())
                    .padding(8)
            }//btn
            .padding(8)
        } //vs
        .onAppear(perform: {
            DispatchQueue.main.relativeAsync(after: appearAnimDuration) {
                self.TitleAxFocused = true
            } //as
        }) //app
    } //body
} //str
