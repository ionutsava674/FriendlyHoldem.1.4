//
//  PokerGameAgreeing.swift
//  CardPlay
//
//  Created by Ionut on 14.08.2022.
//

import Foundation

extension HoldemGame {
    private func allChoseTheSameStructure() -> Bool {
        //needTovisit
        guard !joiningPlayers.contains(where: {
            $0.chosenStructureVariant == nil
        }) else {
            return false
        }
        let allVars = (joiningPlayers.reduce( into: [GameStartParameters]()) { partialResult, player in
            if let variant = player.chosenStructureVariant {
                if !partialResult.contains( variant) {
                    partialResult.append( variant)
                } //if
            } //ifl
        }) //alvars
        return allVars.count == 1
    } //func
    @MainActor private func clampGSPVariantsToMostPopular() -> Bool {
        var occurances:[(vnt: GameStartParameters, cnt: Int)] = gspStructureVariants.map({ variant in
            let vc = self.joiningPlayers.filter({ player in
                player.chosenStructureVariant == variant
            }).count
            return (variant, vc)
        }) //occ
        guard !occurances.isEmpty else {
            return false
        }
        occurances.sort( by: {v1, v2 in
            v1.cnt > v2.cnt
        }) //sort
        self.gspStructureVariants = [occurances[0].vnt]
        return true
    } //func
    @MainActor private func gotoStartAsync() async {
        guard let gameStructure = self.joiningPlayers.first?.chosenStructureVariant
            //!self.gspStructureVariants.isEmpty,
              //let gameStructure = self.gspStructureVariants.first
        else {
                    debugMsg_("no condition for start")
            return
        } //gua
        gameState = .startingGame
        for player in joiningPlayers {
            player.chips = gameStructure.startChips
        }
        smallBlind = gameStructure.smallBlind
        bigBlind = gameStructure.bigBlind
        minRaise = gameStructure.minRaiseAmount
        turnTimeout = gameStructure.turnTimeout
        gspStructureVariants = []
        await beginNewDealAsync()
    } //func
    @MainActor func goToStage2( for player: PokerPlayer, with structureVariant: GameStartParameters) async -> Bool {
        guard !player.volaChose else {
            return false
        }
        debugMsg_("going to 2 for \(player.matchParticipantIndex)")
        player.volaChose = true
        player.chosenStructureVariant = structureVariant
        player.agreeingStage = .naturalAfter( .stage1CanSuggest)

    if joiningPlayers.count < 2 {
        //goto end needtovisit
        return true
    }
        if allChoseTheSameStructure() {
            await gotoStartAsync()
            return true
        }
        //let preReOrdered = joiningPlayers.sortedByAgreeingStage( butBefore: player).mapToIndices
        actingOrder = joiningPlayers.sortedByAgreeingStage( butBefore: player).mapToIndices
        return true
    } //func
    @MainActor func goToStage3( for player: PokerPlayer, with structureVariant: GameStartParameters) async -> Bool {
        guard !player.volaChose else {
            return false
        }
        debugMsg_("going to 3 for \(player.matchParticipantIndex)")
        player.volaChose = true
        player.chosenStructureVariant = structureVariant
        player.agreeingStage = .naturalAfter(.stage2CanOnlyChoose)

    if joiningPlayers.count < 2 {
        //goto end needtovisit
        return true
    }
        if allChoseTheSameStructure() {
            await gotoStartAsync()
            return true
        }
        _ = clampGSPVariantsToMostPopular()
        actingOrder = joiningPlayers.sortedByAgreeingStage( butBefore: player).mapToIndices
        return true
    } //func
    @MainActor func goToStage4( for player: PokerPlayer, with structureVariant: GameStartParameters) async -> Bool {
        guard !player.volaChose else {
            return false
        }
        debugMsg_("going to 3 for \(player.matchParticipantIndex)")
        player.volaChose = true
        player.chosenStructureVariant = structureVariant
        player.agreeingStage = .naturalAfter(.stage3YesOrNo)

        if joiningPlayers.count < 2 {
            //goto end needtovisit
            return true
        }

        if allChoseTheSameStructure() {
            await gotoStartAsync()
            return true
        }

        let preReOrdered = joiningPlayers.sortedByAgreeingStage( butBefore: player)
        let whoIsStillInStage = preReOrdered.filter({
            $0.agreeingStage == .stage3YesOrNo
        })
        if !whoIsStillInStage.isEmpty {
            actingOrder = preReOrdered.mapToIndices
            return true
        } //still in 2
        await gotoStartAsync()
        return true
    } //func
} //ext
