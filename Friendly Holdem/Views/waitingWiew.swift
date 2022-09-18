//
//  waitingWiew.swift
//  CardPlay
//
//  Created by Ionut on 23.09.2021.
//

import SwiftUI
import GameKit

struct WaitingWiew: View {
    @EnvironmentObject var gch: GCHelper
    @ObservedObject var gameModel: HoldemGame
    var match: GKTurnBasedMatch

    var currentArrow: some View {
        Text(Image(systemName: "arrow.right.circle.fill"))
            .background(Color(uiColor: .systemBackground ))
            .blurYourself(radius:3, shape: Circle())
    } //cv
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
            VStack(alignment: .leading, spacing: 0) {
                Text(match.shortTitle())
                    .font(.title)
                match.othersList().toTextOptional(format: "  (%@)")?
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                //Text("Game began \( RelativeDateTimeFormatter.conversionMode1(of: match.creationDate) )")
                Text("  Game duration: \( Text(match.creationDate, style: .relative) )")
                    .font(.headline)
                    .foregroundColor(.secondary)
            } //head vs
Text("Waiting for players to join the game.")
                .multilineTextAlignment(.center)
                .font(.largeTitle.bold())
                .padding()

                VStack(alignment: .leadingAlignInForm, spacing: 8) {
            ForEach(Array(match.participants.enumerated()), id: \.element) { (index, part) in
                let isl = part.player == GKLocalPlayer.local
                let partName = "\(part.player?.alias ?? "Player \(index + 1)")\(isl ? ", (you)" : "")"
                let isc = part == match.currentParticipant
                
                    HStack(alignment: VerticalAlignment.center, spacing: 16) {
                    if isc {
                        currentArrow
                            .accessibilityHidden( true)
                            //.accessibilityElement()
                            //.accessibilityLabel("current player")
                    }
                        let tn =  Text(partName)
                        //.font(.body.bold())
                        let tss = Text(", \(ParticipantLocalization.Statusstring( for: part, isLocal: isl, isCurrent: isc) )")
                        //.font(.body)
                        InterText("\(tn)\(tss)")
                            .alignmentGuide(.leadingAlignInForm) { dim in dim[.leading] }
                } //hs
                    .accessibilityElement(children: .combine)
                    .padding(.horizontal, 8)
                    .blurryBackground( enabled: isl, color: .blue, accessibilityAdjust: false)
                    .blurryBackground( enabled: part.status == .done, color: .red, accessibilityAdjust: false)
                //.background(isl ? RoundedRectangle(cornerRadius: 4).fill(Color.blue).blur(radius: 4) : nil)
                //.background( (part.status == .done) ? RoundedRectangle(cornerRadius: 4).fill(Color.red).blur(radius: 4) : nil)
            } //fe players
        } //vs align
            Spacer()
            Spacer()
        } //vs
        //.frame(alignment: .trailing)
    } //body
} //wv
