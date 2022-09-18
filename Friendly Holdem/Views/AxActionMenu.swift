//
//  AxActionMenu.swift
//  CardPlay
//
//  Created by Ionut on 18.07.2022.
//

import SwiftUI
import GameKit

struct AxActionMenuView: View {
    @ObservedObject var gameModel: HoldemGame
    @EnvironmentObject var gch: GCHelper
    let match: GKTurnBasedMatch
    
    @State private var iqData: InputQuery?
    @State private var showingOptionsAlert = false
    
    var body: some View {
        let newMenu = compileClosureToupleList(for: gameModel.ActingPlayaMenu)
        HStack {
            ForEach(gameModel.ActingPlayaMenu) { action in
                Button(action.displayName() , action: tapClosure( for: action))
            } //fe
        } //hs
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text( "please select an action" ))
        .accessibilityAction {
            self.showingOptionsAlert = true
        }
        .conditionalAddAction(ifHas: .allInBet, in: newMenu)
        .conditionalAddAction(ifHas: .bet, in: newMenu)
        .conditionalAddAction(ifHas: .call, in: newMenu)
        .conditionalAddAction(ifHas: .check, in: newMenu)
        .conditionalAddAction(ifHas: .drop, in: newMenu)
        .conditionalAddAction(ifHas: .raise, in: newMenu)
        .conditionalAddAction(ifHas: .stay, in: newMenu)
        .alert(Text(Self.presentOptions(for: gameModel.actingOrder.first ?? -1, in: gameModel)), isPresented: $showingOptionsAlert, actions: {
            //
        })
        .popover( item: $iqData) { iq in
            InputQuery( title: iq.title, hint: iq.hint, initialValue: iq.initialValue, keyboardType: iq.keyboardType, descriptionProc: iq.descriptionProc, validationProc: iq.validationProc, onOkCallback: iq.onOkCallback, okButtonTitle: iq.okButtonTitle)
        } //pop
    } //body
    func compileClosureToupleList(for menu: [PokerPlayerAction]) -> [(PokerPlayerAction, (() -> Void))] {
        /*
        var rv: [(PokerPlayerAction, (() -> Void))] = []
        for action in menu {
            rv.append((action, tapClosure( for: action)))
        } //for
        return rv
         */
        menu.map({
            ($0, tapClosure( for: $0))
        })
    } //func
    static func presentOptions(for playerIdx: PokerPlayer.IndexType, in game: HoldemGame) -> String {
        guard let player = game.allPlayers.get( by: playerIdx) else {
            return ""
        } //gua
        var msg = """
        The bet is now \(game.currentBetSize)
        You have \(player.placedInBet) chips in the pot.
""" //string end
        if game.canCall( by: playerIdx) {
            msg += "\(String.newLine)You can call at \(game.currentBetSize)."
        }
        if game.canBetAllIn( by: playerIdx) {
            msg += "\(String.newLine)You can bet all in, \(player.chips) chips."
        }
        if game.canRaise( byPlayer: playerIdx, to: game.minRaiseTarget) {
            msg += "\(String.newLine)You can raise the bet to at least \(game.minRaiseTarget)."
        }
        return msg
    } //func
    func tapClosure(for action: PokerPlayerAction) -> (() -> Void) {
        return {
            guard let firstActing = gameModel.actingOrder.first,
                  let actor = gameModel.allPlayers.get( by: firstActing) else {
                return
            }
            switch action.type {
            case .allInBet, .stay, .call, .check, .drop:
                // gch.gameCtl.actionAction( gameCheck: gameModel, actionCheck: action, by: actor.matchParticipantIndex, to: nil)
                Task {
                    await gch.gameCtl.actionAction3( for: gameModel, and: match, action: action, by: actor.matchParticipantIndex, to: nil)
                }
            case .bet, .raise:
                self.iqData =             InputQuery( title: "Raise the bet to", hint: "chips", initialValue: "\(gameModel.minRaiseTarget)", keyboardType: .decimalPad, descriptionProc: { v in
                    guard let nv = ChipsCountType( v) else {
                        return "You need to enter a valid amount of chips."
                    }
                    var msg = Self.presentOptions(for: firstActing, in: gameModel)
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
                    // gch.gameCtl.actionAction( gameCheck: gameModel, actionCheck: action, by: actor.matchParticipantIndex, to: nv)
                    Task {
                        await gch.gameCtl.actionAction3( for: gameModel, and: match, action: action, by: actor.matchParticipantIndex, to: nv)
                    }
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
                    case .lessThanMin, .dontHaveEnough, .someOtherError, .invalidPlayer:
                        return "OK"
                    }
                }) //input Query Init
            } //swi
        } //btn
    } //func
} //str

