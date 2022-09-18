//
//  GameCtlExt_Agreeing.swift
//  CardPlay
//
//  Created by Ionut on 02.07.2022.
//

import Foundation
import GameKit

extension GameController {
    @MainActor func actionGoToStage2(in game: HoldemGame, of match: GKTurnBasedMatch, for player: PokerPlayer, with structureVariant: GameStartParameters) async -> Void {
        guard GCHelper.helper.currentGame === game,
              GCHelper.helper.currentMatch === match else {
            return
        }
        if await game.goToStage2( for: player, with: structureVariant) {
            _ = await giveTurnBackAsync(gameModel: game, in: match, with: nil, players: game.actingOrder)
        }
} //func
    @MainActor func actionGoToStage3( in game: HoldemGame, of match: GKTurnBasedMatch, for player: PokerPlayer, with structureVariant: GameStartParameters) async -> Void {
        guard GCHelper.helper.currentGame === game,
              GCHelper.helper.currentMatch === match else {
            return
        }
        if await game.goToStage3( for: player, with: structureVariant) {
            _ = await giveTurnBackAsync(gameModel: game, in: match, with: nil, players: game.actingOrder)
        }
    } //func
    @MainActor func actionGoToStage4( in game: HoldemGame, of match: GKTurnBasedMatch, for player: PokerPlayer, with structureVariant: GameStartParameters) async -> Void {
        guard GCHelper.helper.currentGame === game,
              GCHelper.helper.currentMatch === match else {
            return
        }
        if await game.goToStage4( for: player, with: structureVariant) {
            _ = await giveTurnBackAsync(gameModel: game, in: match, with: nil, players: game.actingOrder)
        }
    } //func
} //ext gctl
