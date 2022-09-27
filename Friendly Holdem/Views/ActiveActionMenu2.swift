//
//  ActiveActionMenu2.swift
//  CardPlay
//
//  Created by Ionut on 24.08.2022.
//

import SwiftUI
import GameKit

struct ActiveActionMenu2: View {
        @EnvironmentObject var gch: GCHelper
    @ObservedObject var gameModel: HoldemGame
        @ObservedObject var match: GKTurnBasedMatch
        
    @Binding var gotAmountPickerSeed: BetRaiseAmountPickerSeed?
        @State private var showingOptionsAlert = false
        
        var body: some View {
            let newMenu = compileClosureToupleList(for: gameModel.ActingPlayaMenu)
            HStack(alignment: .top, spacing: 0) {
                ForEach(gameModel.ActingPlayaMenu) { action in
                    if action.id != gameModel.ActingPlayaMenu.first?.id {
                        Spacer()
                            .frame(minWidth: 1, idealWidth: 32, maxWidth: 32, minHeight: 1, idealHeight: 1, maxHeight: 1, alignment: .top)
                    } //if not first
                    Button(action: tapClosure( for: action)) {
                        Text(action.localizedDisplayName().capitalizingFirst())
                            .fixedSize()
                            .lineLimit(1)
                            .minimumScaleFactor(1.0)
                            // .font(.headline)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 4, style: RoundedCornerStyle.circular)
                                    .fill(.black)
                                    .blur(radius: 4, opaque: false)
                                    .opacity(0.75)
                            )//bg
                    } //btn
                } //fe
            } //hs
            // .padding(.vertical, 2)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text( "please select an action" ))
            .accessibilityAction {
                self.showingOptionsAlert = true
            }
            .conditionalAddAction( ifHas: .drop, in: newMenu)
            .conditionalAddAction( ifHas: .stay, in: newMenu)
            .conditionalAddAction( ifHas: .allInBet, in: newMenu)
            .conditionalAddAction( ifHas: .check, in: newMenu)
            .conditionalAddAction( ifHas: .call, in: newMenu)
            .conditionalAddAction( ifHas: .raise, in: newMenu)
            .conditionalAddAction( ifHas: .bet, in: newMenu)
            .alert(Text(Self.presentOptions(for: gameModel.actingOrder.first ?? -1, in: gameModel)), isPresented: $showingOptionsAlert, actions: { })
            //.popover( item: $amountPicker) { pickerSeed in
                //BetRaiseAmountPicker( presentingSeed: $amountPicker, match: match, game: gameModel, actor: pickerSeed.actor, action: pickerSeed.action) { betAmount in
                    //gch.displayError(msg: "some error")
                    //showingOptionsAlert = true
                    //Task {
                        //debugMsg_("raising \(String(describing: pickerSeed.action.displayName())) for \(String(describing: pickerSeed.actor.matchParticipantIndex)) to \(betAmount)")
                        //await gch.gameCtl.actionAction3( for: gameModel, and: match, action: pickerSeed.action, by: pickerSeed.actor.matchParticipantIndex, to: betAmount)
                    //}
                //} //picker
            //} //pop
        } //body
        func compileClosureToupleList(for menu: [PokerPlayerAction]) -> [(PokerPlayerAction, (() -> Void))] {
            menu.map({
                ($0, tapClosure( for: $0))
            }) //map
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
        func tapClosure( for action: PokerPlayerAction) -> (() -> Void) {
            return {
                guard let firstActing = gameModel.actingOrder.first,
                      let actor = gameModel.allPlayers.get( by: firstActing) else {
                    return
                }
                switch action.type {
                case .allInBet, .stay, .call, .check, .drop:
                    Task {
                        await gch.gameCtl.actionAction3( for: gameModel, and: match, action: action, by: actor.matchParticipantIndex, to: nil)
                    }
                case .bet, .raise:
                    self.gotAmountPickerSeed = BetRaiseAmountPickerSeed( action: action, actor: actor, onSubmit: { chipsToBet in
                        Task {
                            await gch.gameCtl.actionAction3( for: gameModel, and: match, action: action, by: actor.matchParticipantIndex, to: chipsToBet)
                        }
                    }) //seed
                    //self.gotShowingAmountPicker = true
                } //swi
            } //closure
        } //func
    } //str
