//
//  ShowdownItem.swift
//  CardPlay
//
//  Created by Ionut on 03.07.2022.
//

import SwiftUI
import GameKit

struct ShowdownItem: View {
    let resultPlace: [PokerPlayer]
    let placeIndex: Int
    let match: GKTurnBasedMatch?
    var isFirstPlace: Bool { placeIndex == 0 }
    var moreThanOnePlayers: Bool { resultPlace.count > 1 }
    @Namespace private var stackNS
    @AccessibilityFocusState private var titleFocused: Bool

    func listAliases( of playerList: [PokerPlayer]) -> String {
        GameLocalizer.listAliases(of: playerList, in: match)
    } //func
    
    var body: some View {
        if resultPlace.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .center, spacing: 4) {
                if moreThanOnePlayers {
                    (isFirstPlace
                    ? Text("The winners are \( listAliases( of: resultPlace) ), with \( resultPlace.first?.lastFinishingResult?.rank.name ?? "no result" )")
                    : Text("\(NumberFormatter.ordinalString(placeIndex + 1) ?? "") place, \( listAliases( of: resultPlace) ), with \( resultPlace.first?.lastFinishingResult?.rank.name ?? "no result" )"))
                        .font(.title.bold())
                        .accessibilityFocused($titleFocused)
                }
                else {
                    (isFirstPlace
                    ? Text("The winner is \( listAliases( of: resultPlace) ), with \( resultPlace.first?.lastFinishingResult?.rank.name ?? "no result" )")
                    :                     Text("\(NumberFormatter.ordinalString(placeIndex + 1) ?? "") place, \( listAliases( of: resultPlace) ), with \( resultPlace.first?.lastFinishingResult?.rank.name ?? "no result" )"))
                        .font(.largeTitle.bold())
                        .accessibilityFocused($titleFocused)
                }
                ForEach( resultPlace, id: \.matchParticipantIndex) { eachPlayer in
                    VStack(alignment: .leading, spacing: 8) {
                        if moreThanOnePlayers {
                            Text("\( GameLocalizer.playerAlias( of: eachPlayer, in: match) )'s hand. \( eachPlayer.lastFinishingResult?.rank.name ?? "no result" )")
                                .font(.body.bold())
                        }
                        CardStackIDlessView(stack: eachPlayer.lastFinishingResult?.bestCombo ?? CardStack.emptyStackForViewing, anim_ns: stackNS, desiredCardWidth: 92, desiredXSpacing: 92, desiredYSpacing: 0, fitInRect: true, holdAtAngle: .zero, asSeenBy: eachPlayer.matchParticipantIndex)
                            .frame(minHeight: 100, idealHeight: 112, maxHeight: 144, alignment: .center)
                        Text("Bet \( "\(eachPlayer.lastFinishingResult?.didPlaceInBet ?? 0)" ) chips, got \( "\(eachPlayer.lastFinishingResult?.didGetAfterBet ?? 0)" ).")
                        Text( ((eachPlayer.lastFinishingResult?.didGetOverall ?? 0) >= 0)
                              ? LocalizedStringKey("won \( "\(Swift.abs(eachPlayer.lastFinishingResult?.didGetOverall ?? 0))" ) chips. Now has \( "\(eachPlayer.chips)" ).")
                              : LocalizedStringKey("lost \( "\(Swift.abs(eachPlayer.lastFinishingResult?.didGetOverall ?? 0))" ) chips. Now has \( "\(eachPlayer.chips)" ).") )
                        //Text("\( ((eachPlayer.lastFinishingResult?.didGetOverall ?? 0) >= 0) ? "won" : "lost" ) \( Swift.abs(eachPlayer.lastFinishingResult?.didGetOverall ?? 0) ) chips. Now has \( eachPlayer.chips ).")
                        Divider()
                    } //vs
                } //fe
            } //vs
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    if self.isFirstPlace {
                        //self.titleFocused = true
                    }
                }
            }
        } //not empty
    } //body
} //str showdownitem

