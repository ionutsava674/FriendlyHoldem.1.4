//
//  ActionMenuView.swift
//  CardPlay
//
//  Created by Ionut on 21.11.2021.
//

import SwiftUI

struct ActionMenuView: View {
    @ObservedObject var gameModel: HoldemGame
    @EnvironmentObject var gch: GCHelper
    
    @State private var iqData: InputQuery?
    
    var body: some View {
        HStack {
            ForEach(gameModel.actingPlayerMenu) { action in
                Button(action.displayName() ) {
                    guard let actor = gameModel.allPlayers.get( by: gameModel.actingPlayer) else {
                        return
                    }
                    switch action.type {
                    case .allInBet, .stay, .call, .check, .drop:
                        gch.gameCtl.actionAction( gameCheck: gameModel, actionCheck: action, by: actor.matchParticipantIndex, to: nil)
                    case .bet, .raise:
                        self.iqData =             InputQuery( title: "Raise the bet to", hint: "chips", initialValue: "\(gameModel.minRaiseTarget)", keyboardType: .decimalPad, descriptionProc: { v in
                            guard let nv = ChipsCountType( v) else {
                                return "You need to enter a valid amount of chips."
                            }
                            var msg = """
                            The bet is now \(gameModel.currentBetSize)
                            You have \(actor.placedInBet) chips in the pot.
""" //string end
                            if gameModel.canCall( by: actor.matchParticipantIndex) {
                                msg += "\(String.newLine)You can call at \(gameModel.currentBetSize)."
                            }
                            if gameModel.canBetAllIn( by: actor.matchParticipantIndex) {
                                msg += "\(String.newLine)You can bet all in, \(actor.chips) chips."
                            }
                            if gameModel.canRaise( byPlayer: actor.matchParticipantIndex, to: gameModel.minRaiseTarget) {
                                msg += "\(String.newLine)You can raise the bet to at least \(gameModel.minRaiseTarget)."
                            }
                            switch gameModel.canSetBet( for: actor.matchParticipantIndex, to: nv) {
                            case .raiseBet:
                                msg = "\(msg)\(String.newLine)Tap OK to raise the bet to \(v)."
                            case .allIn:
                                msg = "Tap OK to bet all your chips\(String.newLine)\(msg)"
                            case .call:
                                msg = "Tap OK to call the bet at \(nv)\(String.newLine)\(msg)"
                            case .lessThanMin:
                                msg = "You need to raise the bet to at least \(gameModel.minRaiseTarget).\(String.newLine)\(msg)"
                            case .dontHaveEnough:
                                msg = "You don't have enough to bet this much.\(String.newLine)\(msg)"
                            case .someOtherError, .invalidPlayer:
                                msg = "An unexpected error occured.\(String.newLine)\(msg)"
                            } //swi
                            return msg
                        }, validationProc:                         { v in
                            guard let nv = ChipsCountType( v) else {
                                return false
                            }
                            return gameModel.canSetBet( for: actor.matchParticipantIndex, to: nv).succeeded
                        }, onOkCallback: { v in
                            guard let nv = ChipsCountType(v) else {
                                return
                            }
                            gch.gameCtl.actionAction( gameCheck: gameModel, actionCheck: action, by: actor.matchParticipantIndex, to: nv)
                        }, okButtonTitle: { v in
                            guard let nv = ChipsCountType( v) else {
                                return "OK"
                            }
                            switch gameModel.canSetBet( for: actor.matchParticipantIndex, to: nv) {
                            case .raiseBet:
                                return "Raise"
                            case .allIn:
                                return "Bet all in"
                            case .call:
                                return "Call"
                            case .lessThanMin:
                                return "OK"
                            case .dontHaveEnough:
                                return "OK"
                            case .someOtherError, .invalidPlayer:
                                return "OK"
                            }
                        }) //input Query Init
                    } //swi
                } //btn
            } //fe
        } //hs
        .popover( item: $iqData) { iq in
            InputQuery( title: iq.title, hint: iq.hint, initialValue: iq.initialValue, keyboardType: iq.keyboardType, descriptionProc: iq.descriptionProc, validationProc: iq.validationProc, onOkCallback: iq.onOkCallback, okButtonTitle: iq.okButtonTitle)
        } //pop
    } //body
    
    func tapClosure(for action: PokerPlayerAction) -> (() -> Void) {
        return {
            guard let actor = gameModel.allPlayers.get( by: gameModel.actingPlayer) else {
                return
            }
            switch action.type {
            case .allInBet, .stay, .call, .check, .drop:
                gch.gameCtl.actionAction( gameCheck: gameModel, actionCheck: action, by: actor.matchParticipantIndex, to: nil)
            case .bet, .raise:
                self.iqData =             InputQuery( title: "Raise the bet to", hint: "chips", initialValue: "\(gameModel.minRaiseTarget)", keyboardType: .decimalPad, descriptionProc: { v in
                    guard let nv = ChipsCountType( v) else {
                        return "You need to enter a valid amount of chips."
                    }
                    var msg = """
                    The bet is now \(gameModel.currentBetSize)
                    You have \(actor.placedInBet) chips in the pot.
""" //string end
                    if gameModel.canCall( by: actor.matchParticipantIndex) {
                        msg += "\(String.newLine)You can call at \(gameModel.currentBetSize)."
                    }
                    if gameModel.canBetAllIn( by: actor.matchParticipantIndex) {
                        msg += "\(String.newLine)You can bet all in, \(actor.chips) chips."
                    }
                    if gameModel.canRaise( byPlayer: actor.matchParticipantIndex, to: gameModel.minRaiseTarget) {
                        msg += "\(String.newLine)You can raise the bet to at least \(gameModel.minRaiseTarget)."
                    }
                    switch gameModel.canSetBet( for: actor.matchParticipantIndex, to: nv) {
                    case .raiseBet:
                        msg = "\(msg)\(String.newLine)Tap OK to raise the bet to \(v)."
                    case .allIn:
                        msg = "Tap OK to bet all your chips\(String.newLine)\(msg)"
                    case .call:
                        msg = "Tap OK to call the bet at \(nv)\(String.newLine)\(msg)"
                    case .lessThanMin:
                        msg = "You need to raise the bet to at least \(gameModel.minRaiseTarget).\(String.newLine)\(msg)"
                    case .dontHaveEnough:
                        msg = "You don't have enough to bet this much.\(String.newLine)\(msg)"
                    case .someOtherError, .invalidPlayer:
                        msg = "An unexpected error occured.\(String.newLine)\(msg)"
                    } //swi
                    return msg
                }, validationProc:                         { v in
                    guard let nv = ChipsCountType( v) else {
                        return false
                    }
                    return gameModel.canSetBet( for: actor.matchParticipantIndex, to: nv).succeeded
                }, onOkCallback: { v in
                    guard let nv = ChipsCountType(v) else {
                        return
                    }
                    gch.gameCtl.actionAction( gameCheck: gameModel, actionCheck: action, by: actor.matchParticipantIndex, to: nv)
                }, okButtonTitle: { v in
                    guard let nv = ChipsCountType( v) else {
                        return "OK"
                    }
                    switch gameModel.canSetBet( for: actor.matchParticipantIndex, to: nv) {
                    case .raiseBet:
                        return "Raise"
                    case .allIn:
                        return "Bet all in"
                    case .call:
                        return "Call"
                    case .lessThanMin:
                        return "OK"
                    case .dontHaveEnough:
                        return "OK"
                    case .someOtherError, .invalidPlayer:
                        return "OK"
                    }
                }) //input Query Init
            } //swi
        } //btn
    } //func
} //str

