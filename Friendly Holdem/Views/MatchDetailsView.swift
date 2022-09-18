//
//  MatchDetailsView.swift
//  CardPlay
//
//  Created by Ionut on 27.06.2022.
//

import SwiftUI
import GameKit

struct MatchDetailsView: View {
        @ObservedObject var match: GKTurnBasedMatch
        
        var body: some View {
            VStack(alignment: .leading, spacing: 2) {
                Text("Game began: ") + Text(match.creationDate, style: .relative)
                ForEach( Array( match.participants.enumerated()), id: \.element) { (index, part) in
                    let isl = part.player == GKLocalPlayer.local
                    let partName = "\(part.name(in: match))\(isl ? ", (you)" : "")"
                    let isc = part == match.currentParticipant
                    
                            Text("\(partName), \(ParticipantLocalization.Statusstring( for: part, isLocal: isl, isCurrent: isc, showOutcome: true) );")
                            .font(.body)
                } //fe players
            } //head vs
        } //body
    } //str
