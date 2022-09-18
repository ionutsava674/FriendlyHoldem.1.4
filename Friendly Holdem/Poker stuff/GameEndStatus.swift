//
//  GameEndStatus.swift
//  CardPlay
//
//  Created by Ionut on 16.08.2022.
//

import Foundation

class GameEndStatus: ObservableObject {
    @Published var finishOrder: [[PokerPlayer]] = []
    
    private func isThereMoneyInGame() -> Bool {
        finishOrder.contains(where: {
            $0.contains(where: { player in
                player.chips > 0
            })
        })
    }
    @MainActor func setOutcomes() -> Void {
        let moneyInGame = isThereMoneyInGame()
        for ( rowIndex, row) in Array( finishOrder.enumerated()) {
            for finisher in row {
                guard !finisher.notJoiningReason.quitOrOuted() else {
                    continue
                } //gua
                guard rowIndex != 0 else {
                    finisher.notJoiningReason = row.count > 1
                    ? .tied
                    : ( moneyInGame ? .won : .first )
                    continue
                }
                finisher.notJoiningReason = .lost
            } //for
        } //for //for
    } //func
} //class
