//
//  MatchInfoView.swift
//  CardPlay
//
//  Created by Ionut on 24.06.2022.
//

import SwiftUI
import GameKit

struct MatchInfo1View: View {
    @ObservedObject var match: GKTurnBasedMatch
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("This game is with \(MatchLocalizer.title( of: match, justTheList: true) ).")
                .font(.title)
            Text("Game began \( match.creationDate, style: .relative ) ago.")
                .font(.headline)
                .foregroundColor(.secondary)
                .offset(x: 8, y: 0)
            MatchLocalizer.itsWhoosTurnText( of: match).toTextOptional( format: "%@")?
                .font(.headline)
                .foregroundColor(.secondary)
                .offset(x: 8, y: 0)
        } //head vs
    } //body
} //str
