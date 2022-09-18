//
//  AgreeingView.swift
//  CardPlay
//
//  Created by Ionut on 04.12.2021.
//

import SwiftUI
import GameKit

struct AgreeingView: View {
    @EnvironmentObject var gch: GCHelper
    @ObservedObject var gameModel: HoldemGame
    @ObservedObject var viewingPlayer: PokerPlayer
    var match: GKTurnBasedMatch
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
        VStack(alignment: .center, spacing: 10) {
            Spacer()
            MatchInfo1View(match: match)
            Spacer()
            if viewingPlayer.agreeingStage == .stage1CanSuggest {
                Stage1View( gspVariants: gameModel.gspStructureVariants, onSelectedVariant: { variant in
                    Task { await self.gch.gameCtl.actionGoToStage2(in: gameModel, of: match, for: viewingPlayer, with: variant) }
                }, onCreatedVariant: { variant in
                    if !gameModel.gspStructureVariants.contains( variant) {
                        gameModel.gspStructureVariants.append( variant)
                    }
                    Task { await self.gch.gameCtl.actionGoToStage2( in: gameModel, of: match, for: viewingPlayer, with: variant) }
                }) //stage view
            } //if1
            else {
                if viewingPlayer.agreeingStage == .stage2CanOnlyChoose {
                    GSPLister( gspVariants: gameModel.gspStructureVariants) { variant in
                        Task { await self.gch.gameCtl.actionGoToStage3(in: gameModel, of: match, for: viewingPlayer, with: variant) }
                    } //list
                } //if 2
                else {
                    if viewingPlayer.agreeingStage == .stage3YesOrNo {
                        GSPLister( gspVariants: gameModel.gspStructureVariants) { variant in
                            Task { await self.gch.gameCtl.actionGoToStage4(in: gameModel, of: match, for: viewingPlayer, with: variant) }
                        } //list
                    } //if 3
                } //else of 2
            } //else of 1
            thereAreMore
            Button("Leave game") {
                self.gch.showingQuitDialog = true
            } //quit btn
            .disabled( self.viewingPlayer.volaChose)
            Spacer()
            Spacer()
            Spacer()
        } //vs
        } //sv
    } //body
    var thereAreMore: Text? {
        let playersToCome = match.participants.filter({
            [.matching].contains($0.status)
        })//filt
            .count
        var outMsg = [String]()
        switch playersToCome {
        case 0:
            return nil
        case 1:
            outMsg.append(NSLocalizedString("There is one more free slot for a player.", comment: ""))
        default:
            outMsg.append(String.localizedStringWithFormat(NSLocalizedString("There are %lld more free slots for players.", comment: ""), playersToCome))
        } //swi
        if self.viewingPlayer.agreeingStage == .stage1CanSuggest && self.gameModel.gspStructureVariants.isEmpty {
            outMsg.append(NSLocalizedString("Please propose a variant for the game stakes.", comment: ""))
        } else if self.viewingPlayer.agreeingStage == .stage1CanSuggest && !self.gameModel.gspStructureVariants.isEmpty {
            outMsg.append(NSLocalizedString("Please select or propose a variant for the game stakes.", comment: ""))
        } else if self.viewingPlayer.agreeingStage == .stage2CanOnlyChoose || self.viewingPlayer.agreeingStage == .stage3YesOrNo {
            outMsg.append(NSLocalizedString("Please select a variant for the game stakes.", comment: ""))
        }
        outMsg.append(NSLocalizedString("Only after this, GameCenter will select players for the free slots.", comment: ""))
        return Text( outMsg.joined(separator: " ") )
    } //cv
} //str
