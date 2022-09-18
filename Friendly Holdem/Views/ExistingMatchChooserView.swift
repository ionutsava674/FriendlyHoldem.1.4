//
//  MatchChooserView.swift
//  CardPlay
//
//  Created by Ionut on 01.12.2021.
//

import SwiftUI
import GameKit

struct ExistingMatchChooserView: View {
    var matchList: [GKTurnBasedMatch]
    var shouldDismiss: Bool = false
    var onSelect: ((GKTurnBasedMatch) -> Void)?
    @EnvironmentObject var gch: GCHelper
    @Environment(\.presentationMode) private var premo
    
    @State private var showingError: Bool = false

    func itemClick (match: GKTurnBasedMatch) -> Void {
        self.onSelect?(match)
    } //func
    var activeMatches: [GKTurnBasedMatch] {
        matchList.filter({
            $0.localJoining()
        })
    } //cv
    var passiveMatches: [GKTurnBasedMatch] {
        matchList.filter({
            !($0.localJoining())
        })
    } //cv
    func bbody() { }
    @AccessibilityFocusState private var TitleAxFocused: Bool
    private let appearAnimDuration: TimeInterval = 0.7
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if premo.wrappedValue.isPresented {
                HStack {
                    Button("Cancel") {
                        self.premo.wrappedValue.dismiss()
                    } //btn
                    Spacer()
                } //hs
            } //if
                Text(matchList.isEmpty
                ? "You are not currently participating in any game."
                     : "Select a game from below.")
                .accessibilityFocused( $TitleAxFocused)
            List {
                Section("Active games, (\(activeMatches.count)") {
                    if activeMatches.isEmpty {
                        Text("No active games")
                    } else {
                        ForEach(activeMatches) { match in
                            MatchSelectorItem( match: match) { selectedMatch in
                                self.itemClick(match: selectedMatch)
                            } //item
                        } //fe
                    } //else
                } //se
                if !passiveMatches.isEmpty {
                    Section("Games in which you are no longer participating:") {
                        ForEach(passiveMatches) { match in
                            MatchSelectorItem(match: match) { selectedMatch in
                                self.itemClick(match: selectedMatch)
                            }
                        } //fe
                    } //se
                } //if
                if !self.gch.doneMatches.isEmpty {
                    Section("Finished games:") {
                        ForEach(self.gch.doneMatches) { match in
                            MatchSelectorItem(match: match) { selectedMatch in
                                self.itemClick(match: selectedMatch)
                            }
                        } //fe
                    } //se
                } //if
            } //ls
            //.accessibilityValue("lalalala")
        } //main vs
        .onAppear(perform: {
            DispatchQueue.main.relativeAsync(after: appearAnimDuration) {
                self.TitleAxFocused = true
            } //as
        }) //app
        .alert(Text(self.gch.errorDialog?.title ?? ""), isPresented: self.$showingError, presenting: self.gch.errorDialog, actions: { ed in
            //
        }, message: { ed in
            Text( ed.msg)
        })
        //.alert(item: self.$errorMessage, content: { errCon in
            //Alert(title: Text(errCon.msg), message: nil, dismissButton: .default(Text("OK")))
        //}) //alert
    } //body
} //str

struct MatchSelectorItem: View {
    let match: GKTurnBasedMatch
    var onSelect: ((GKTurnBasedMatch) -> Void)?
    
    @State private var showingDetails: Bool = false
    
    func detailsClick() -> Void {
        showingDetails.toggle()
    } //func
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            MatchLocalizer.title( of: match).toText()
                .font(.title)
                .onTapGesture {
                    self.onSelect?(match)
                }
            //MatchLocalizer.shortSubtitle(of: match)?.toText()
            (Text( showingDetails ? "Last activity: " : "") + Text(match.lastActionDate(), style: .relative))
                //.font(.body)
            MatchLocalizer.itsWhoosTurnText(of: match)?.toText()
                .font(.caption)
            if showingDetails {
                MatchDetailsView(match: match)
            }
            HStack {
                Spacer()
                Button {
                    self.detailsClick()
                } label: {
                    Text(showingDetails ? "Hide details" : "Show details")
                } //btn
            } //hs
            .accessibilityHidden(!showingDetails)
        } //vs2
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .border(Color(UIColor.opaqueSeparator))
        .accessibilityElement(children: showingDetails ? .contain : .combine )
        .accessibilityAction(.default, {
            self.onSelect?(match)
        })
        .accessibilityAction(named: Text(showingDetails ? "Hide details" : "Show details")) {
            self.detailsClick()
        } //action
    } //body
} //str
