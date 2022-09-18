//
//  AgreeingInactive.swift
//  CardPlay
//
//  Created by Ionut on 20.12.2021.
//

import SwiftUI
import GameKit

struct AgreeingInactive: View {
        @EnvironmentObject var gch: GCHelper
        @ObservedObject var gameModel: HoldemGame
    @ObservedObject var match: GKTurnBasedMatch

    @Environment(\.accessibilityReduceTransparency) var shouldReduceTransp
    @AccessibilityFocusState private var TitleAxFocused: Bool
    private let appearAnimDuration: TimeInterval = 0.7
        var currentArrow: some View {
            Text(Image(systemName: "arrow.right.circle.fill"))
                .background(Color( uiColor: .systemBackground ))
                .blurYourself(radius:3, shape: Circle())
        } //cv
        var body: some View {
            //ZStack {
            VStack(alignment: .center, spacing: 0) {
                Spacer()
                MatchInfo1View(match: match)
                    .accessibilityFocused($TitleAxFocused)
                Spacer()
                Text("Game stage: Choosing the betting stakes.")
                    .multilineTextAlignment(.center)
                    .font(.largeTitle.bold())
                    .padding()
                VStack {
                    Text("Players:")
                                        .font(.body)
                                        .padding(2)
                                        VStack(alignment: .leadingAlignInForm, spacing: 8) {
                                    ForEach(Array(match.participants.enumerated()), id: \.element) { (index, part) in
                                        let isl = part.player == GKLocalPlayer.local
                                        let partName = "\(part.name( in: match))\(isl ? ", (you)" : "")"
                                        let isc = part == match.currentParticipant
                                        
                                            HStack(alignment: VerticalAlignment.center, spacing: 16) {
                                            if isc {
                                                currentArrow
                                                    .accessibilityHidden( true)
                                            }
                                                let tn =  Text(partName)
                                                //.font(.body.bold())
                                                let tss = Text(", \(ParticipantLocalization.Statusstring( for: part, isLocal: isl, isCurrent: isc, showOutcome: true) )")
                                                //.font(.body)
                                                let ct = tn + tss
                                                ct
                                                    .alignmentGuide(.leadingAlignInForm) { dim in dim[.leading] }
                                                    .accessibility(label: ct)
                                        } //hs
                                            .padding(.horizontal, 8)
                                            .blurryBackground( enabled: (isl && !(self.shouldReduceTransp)),
                                                               color: .blue)
                                            .blurryBackground( enabled: part.status == .done && !(self.shouldReduceTransp),
                                                               color: .red)
                                            .accessibilityElement(children: .combine)
                                    } //fe players
                                } //vs align
                } //vs
                Divider()
                if self.match.localParticipant()?.status.meansStillInGame( includingWaiting: false) ?? false {
                    Button(action: {
                        self.gch.showingQuitDialog = true
                    }, label: {
                        Text("Leave game")
                    }) //btn
                } //if still joining
                Spacer()
                Spacer()
                Spacer()
            } //vs
            //} //zs
            .onAppear {
                //DispatchQueue.main.relativeAsync(after: initAnimDuration) {
                    //self.TitleAxFocused = true
                //} //as
            } //app
        } //body
    } //aistruct
