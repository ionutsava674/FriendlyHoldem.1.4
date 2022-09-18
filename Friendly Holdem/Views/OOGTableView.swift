//
//  InactiveTableView.swift
//  CardPlay
//
//  Created by Ionut on 04.08.2022.
//

import SwiftUI
import GameKit

struct NonJoTableView: View {
    @EnvironmentObject var gch: GCHelper
    @ObservedObject var game: HoldemGame
    @ObservedObject var viewedBy: PokerPlayer
    let match: GKTurnBasedMatch
    @Namespace private var cardAnim_ns
    @AccessibilityFocusState private var playerAxFocus: Int?

    var body: some View {
        GeometryReader { geo in
        ZStack {
            RadialGradient( colors: [
                Color( red: 0.1, green: 0.2, blue: 0.45),
                Color( red: 0.1, green: 0.45, blue: 0.2)
            ], center: UnitPoint(x: 0.3, y: 0.8), startRadius: 0.2 * 1000.0, endRadius: 0.6 * 1000.0)
                .brightness(0.012)
        VStack(alignment: .center, spacing: 0) { //main vs //others and tokens
            HStack(alignment: .center, spacing: 0) {
                let otherPlayers = game.allPlayers.nextOthersOf(mpIndex: match.localParticipantIndex() ?? -1, includeAtEnd: false) ?? game.allPlayers
                ForEach(otherPlayers, id: \.matchParticipantIndex) { otherPlayer in
                    VStack(alignment: .center, spacing: 0) {
                        let otherAlias = GameController.playerAlias( of: otherPlayer, in: match)
                        Text(otherAlias)
                            .accessibilityHidden(true)
                        CardStackView(stack: otherPlayer.hand, anim_ns: cardAnim_ns, desiredCardWidth: 50, desiredXSpacing: 40, desiredYSpacing: 0, fitInRect: true, holdAtAngle: .degrees(-5), asSeenBy: otherPlayer.matchParticipantIndex)
                            .rotation3DEffect(otherPlayer.dropped ? .degrees(70) : .zero, axis: (x: 1, y: 0, z: 0), anchor: .bottom, anchorZ: 0, perspective: 1)
                            .modifier(StackGlowFlasher2(activeState: game.actingOrder.first == otherPlayer.matchParticipantIndex, radius: 27, color: .white) )
                            //.accessibilityElement(children: .ignore)
                            //.accessibilityLabel( otherAlias)
                            //.accessibilityValue(" (\( GameController.dealerStatus( of: otherPlayer, in: game) )")
                            .accessibilityFocused($playerAxFocus, equals: 20 + otherPlayer.matchParticipantIndex)
                        DealerToken( forPlayer: otherPlayer, game: game, tokenSize: 17)
                        if otherPlayer.joiningGame {
                            JumpingText( text: "🪙 \(otherPlayer.placedInBet)", uniqueId: "\(match.matchID)BetFrom\(otherAlias)")
                                .font(otherPlayer.dropped ? .subheadline : .subheadline.italic())
                                .accessibilityLabel("\(otherPlayer.placedInBet) chips bet by \(otherAlias)")
                                .accessibilityValue("(\( GameController.itsHisTurn( of: otherPlayer, in: game, and: match) ))")
                        } else {
                            Text(  GameController.LocalizednoJoinReason(for: otherPlayer, in: match, withName: false, isLocal: false) )
                                .accessibilityLabel( GameController.LocalizednoJoinReason(for: otherPlayer, in: match, withName: true, isLocal: false) )
                        } //chips or info
                    } //vs
                } //fe
            } //top hs
            //.padding([.top])
            .frame(minHeight: geo.size.height * 0.30, idealHeight: geo.size.height * 0.40, maxHeight: geo.size.height * 0.45, alignment: .top)
            Spacer()
            HStack(alignment: .center, spacing: 0) { //mid
                if game.dealerStackVisible {
                    VStack {
                        CardStackView(stack: game.dealerStack, anim_ns: cardAnim_ns, desiredCardWidth: 58, desiredXSpacing: 58 / 5 / 54, desiredYSpacing: 58 / 5 / 54, fitInRect: true, holdAtAngle: .zero, onlyLastAccessible: true, asSeenBy: viewedBy.matchParticipantIndex, backFacingText: "Cards facing down, … ", onlyShow: 10)
                            .accessibilityLabel(game.gameState.longDescription)
                            .accessibilityAction(named: Text( GameController.thereAreCardsOnTheTable(in: game) ), {
                                self.playerAxFocus = 40
                            }) //act
                            .accessibilityAction(named: GameController.isLocalTurnDoubleCheck(in: game, and: match)
                                                 ? Text( GameController.yourChipsStatus(in: game, of: viewedBy) )
                                                 : Text( GameController.whenItsYourTurn(in: game, and: match) ), {
                            }) //act
                            .accessibilityAction(named: Text( GameController.nowItsWhosReallyTurn(in: game, and: match) ?? "the current turn is unknown" ), {
                                if match.isLocalPlayersTurn() {
                                    self.playerAxFocus = 30
                                } else {
                                    if let firstActing = game.actingOrder.first {
                                        self.playerAxFocus = 20 + firstActing
                                    }
                                }
                            }) //act
                        JumpingText(text: "🪙 \(game.totalPotSize)", uniqueId: "\(match.matchID)PotSize")
                            .accessibilityLabel(Text("Total pot"))
                            .accessibilityValue(Text("\(game.totalPotSize) chips."))
                } //vs
                    .frame(width: geo.size.width * 0.33, alignment: .center)
                } //if
                //GeometryReader { flopGeo in
                    //List {
                        CardStackView(stack: game.flop, anim_ns: cardAnim_ns, desiredCardWidth: 92, desiredXSpacing: 110, desiredYSpacing: 0, fitInRect: true, holdAtAngle: .zero, asSeenBy: match.localParticipantIndex() ?? -1)
                //accessibilityValue(Text( self.playerAxFocus == 40
                                       //? ""
                                         //: ", this is a flop card" ))
                    .accessibilityFocused($playerAxFocus, equals: 40)
                    .accessibilityCustomContent("this card is in the flop", Text(""))
                        // .background(Color.red)
                    //} //ls
                //} //geo
            } //mid hs
            .frame(minHeight: geo.size.height * 0.30, idealHeight: geo.size.height * 0.35, maxHeight: geo.size.height * 0.40, alignment: .center)
            Spacer()
                InactiveActionMenuView(gameModel: game, viewedBy: viewedBy, match: match)
        } //main vs
        .foregroundColor(.white)
        } //zs
        } //geo
    } //body
} //str
