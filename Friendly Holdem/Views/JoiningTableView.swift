//
//  mainGameView.swift
//  CardPlay
//
//  Created by Ionut on 17.08.2021.
//

import SwiftUI
import GameKit

struct JoiningTableView: View {
    @EnvironmentObject var gch: GCHelper
    @ObservedObject var game: HoldemGame
    @ObservedObject var viewedBy: PokerPlayer
    @ObservedObject var match: GKTurnBasedMatch
    @Namespace private var cardAnim_ns
    
    @Environment(\.accessibilityReduceMotion) private var shouldReduceMotion
    @AccessibilityFocusState private var playerAxFocus: Int?
    
    @State private var amountPickerToShow: BetRaiseAmountPickerSeed?
    @State private var showingPotInfo = false
    @State private var showingOverlayedGameLog = false
    private var combineStates: Int {
        (showingPotInfo ? 1 : 0) |
        (showingOverlayedGameLog ? 2 : 0) |
        ((amountPickerToShow == nil) ? 4: 0)
    }
    private let OTHER_STACK_CARD_WIDTH: CGFloat = 72
    private let DEALER_STACK_CARD_WIDTH: CGFloat = 96
    private let FLOP_STACK_CARD_WIDTH: CGFloat = 102
    private let HAND_STACK_CARD_WIDTH: CGFloat = 220
    
    private let TOP_ROW_RATIO_PORTRAIT: CGFloat = 0.16
    private let TOP_ROW_RATIO_LANDSCAPE: CGFloat = 0.32
    private let MID_ROW_RATIO_PORTRAIT: CGFloat = 0.28
    private let MID_ROW_RATIO_LANDSCAPE: CGFloat = 0.48
    private let BOT_ROW_RATIO_PORTRAIT: CGFloat = 0.5
    private let BOT_ROW_RATIO_LANDSCAPE: CGFloat = 0.68

    var body: some View {
        GeometryReader { geo in
        ZStack {
            Text("\( amountPickerToShow?.actor.matchParticipantIndex ?? -1 )").hidden()
            RadialGradient( colors: [
                Color( red: 0.1, green: 0.2, blue: 0.45),
                Color( red: 0.1, green: 0.45, blue: 0.2)
            ], center: UnitPoint(x: 0.3, y: 0.8), startRadius: 0.2 * 1000.0, endRadius: 0.6 * 1000.0)
                .brightness( 0.0)
            //Color.pink
        VStack(alignment: .center, spacing: 0) { //main vs //others and tokens
            HStack(alignment: .center, spacing: 0) {
                let otherPlayers = game.allPlayers.nextOthersOf( mpIndex: viewedBy.matchParticipantIndex, includeAtEnd: false) ?? game.allPlayers
                ForEach(otherPlayers, id: \.matchParticipantIndex) { otherPlayer in
                    OtherPlayerView(otherPlayer: otherPlayer, game: game, viewedBy: viewedBy, match: match, anim_ns: cardAnim_ns, desiredCardWidth: OTHER_STACK_CARD_WIDTH)
                    .accessibilityFocused( $playerAxFocus, equals: 20 + otherPlayer.matchParticipantIndex)
                } //fe
            } //top hs
            .padding(.top, 4)
            .padding(.bottom)
            //.frame(minHeight: geo.size.height * 0.20, idealHeight: geo.size.height * 0.21, maxHeight: geo.size.height * 0.22, alignment: .top)
            .frame(height: geo.size.height * (geo.isLandscape ? TOP_ROW_RATIO_LANDSCAPE : TOP_ROW_RATIO_PORTRAIT), alignment: .top)
            // .background(.black)
            Spacer()
            SwappableBiStack(vertical: !geo.isLandscape, swapped: false, vAlignment: .top, spacing: 0) {
                SwappableBiStack(vertical: true, swapped: false, spacing: 0) {
                    GeometryReader {midGeo in
                        HStack(alignment: .center, spacing: 0) { //mid
                            if game.dealerStackVisible {
                                VStack {
                                    
                                    CardStackView(stack: game.dealerStack, anim_ns: cardAnim_ns, desiredCardWidth: DEALER_STACK_CARD_WIDTH, desiredXSpacing: DEALER_STACK_CARD_WIDTH / 5 / 54, desiredYSpacing: DEALER_STACK_CARD_WIDTH / 5 / 54, fitInRect: true, holdAtAngle: .zero, onlyLastAccessible: true, asSeenBy: viewedBy.matchParticipantIndex, backFacingText: "Cards facing down, … ", onlyShow: 10)
                                        .padding(.top, 8)
                                        .accessibilityLabel(game.gameState.longDescription)
                                        .accessibilityAction( named: Text( GameLocalizer.thereAreCardsOnTheTable( in: game) ), {
                                            self.playerAxFocus = 40
                                        }) //act
                                        .conditionalAxAction( condition: !GameController.isLocalTurnDoubleCheck(in: game, and: match),
                                                              named: Text( GameLocalizer.whenItsYourTurn(in: game, and: match) ), { })
                                        .accessibilityAction( named: Text("Total pot: \(game.totalPotSize) chips."), { })
                                        .accessibilityAction( named: Text( GameLocalizer.yourChipsStatus( in: game, of: viewedBy) ), { })
                                        .accessibilityAction( named: Text( GameLocalizer.nowItsWhosReallyTurn(in: game, and: match) ?? "the current turn is unknown" ), {
                                            self.setFocusToFirstActing()
                                        }) //act
                                    
                                    VStack {
                                        Text("Total:")
                                        JumpingText(text: "🪙 \(game.totalPotSize)", uniqueId: "\(match.matchID)PotSize")
                                    } //gr
                                    .accessibilityElement( children: .combine)
                                    .accessibilityLabel(Text("Total pot"))
                                    .accessibilityValue( Text("\(game.totalPotSize) chips."))
                                    .onTapGesture {
                                        self.showingPotInfo = true
                                    }
                                    // .background(.yellow)
                                } //vs
                                .frame(width: midGeo.size.width * 0.3, alignment: .center)
                                // .background(.black)
                            } //if
                            GeometryReader { flopGeo in
                                List {
                                    CardStackView(stack: game.flop, anim_ns: cardAnim_ns, desiredCardWidth: FLOP_STACK_CARD_WIDTH, desiredXSpacing: FLOP_STACK_CARD_WIDTH * 1.2, desiredYSpacing: 0, fitInRect: true, holdAtAngle: .zero, asSeenBy: viewedBy.matchParticipantIndex)
                                        .conditionalAxContent( !game.flop.cards.isEmpty, key: AccessibilityCustomContentKey(Text("On the table, facing up"), id: "location"), contentValue: Text(""))
                                        .accessibilityFocused($playerAxFocus, equals: 40)
                                        .frame(width: flopGeo.size.width
                                               , height: flopGeo.size.height
                                               , alignment: .center)
                                        // .background(.blue)
                                        .listRowInsets(EdgeInsets())
                                        .listRowBackground(Color.clear)
                                    // .background(.orange)
                                } //ls
                                .environment(\.defaultMinListRowHeight, 0)
                                .listStyle(PlainListStyle() )
                                .accessibilityLabel("flop")
                            } //flopGeo
                        } //mid hs
                    } //midGeo
                } secondContent: {
                    LastActionLine(gameModel: game, viewedBy: viewedBy, match: match)
                        .padding()
                    // .padding(.vertical, 4)
                        .onTapGesture {
                            HoldemGame.cardMoveSound?.prepareAndPlay()
                            self.showingOverlayedGameLog = true
                        } //tap
                }

                // .padding(.bottom)
                //.frame(minHeight: geo.size.height * 0.21, idealHeight: geo.size.height * 0.24, maxHeight: geo.size.height * 0.26, alignment: .center)
                .frame(height: geo.size.height * (geo.isLandscape ? MID_ROW_RATIO_LANDSCAPE : MID_ROW_RATIO_PORTRAIT), alignment: .center)
                // .background(.black)
            } secondContent: {
                VStack(alignment: .center, spacing: 0) { //me and token
                    if GameController.isLocalTurnDoubleCheck(in: game, and: match) {
                        ActiveActionMenu2(gameModel: game, match: match, gotAmountPickerSeed: $amountPickerToShow)
                            .accessibilityFocused($playerAxFocus, equals: 30)
                            .padding(.bottom, 6)
                    } else {
                        //if inactive
                        InactiveActionMenuView(gameModel: game, viewedBy: viewedBy, match: match)
                            .padding(.vertical, 4)
                            .accessibilityCustomContent( AccessibilityCustomContentKey(Text( "" ), id: "when your turn"), Text( GameLocalizer.whenItsYourTurn(in: game, and: match) ))
                            .accessibilityCustomContent( AccessibilityCustomContentKey(Text(""), id: "game status"), Text( game.gameState.shortDescription ))
                            .accessibilityCustomContent( AccessibilityCustomContentKey(Text("is acting as current dealer"), id: "current dealer"), Text( GameLocalizer.playerAlias( of: game.actAsDealer, in: match, unknownIndexDefault: "unknown") ))
                            .accessibilityCustomContent( AccessibilityCustomContentKey(Text("is now in turn"), id: "now in turn"), Text( GameLocalizer.playerAlias(of: game.actingOrder.first, in: match, unknownIndexDefault: "unknown") ))
                    } //else
                    JumpingText(text: "🪙 \(viewedBy.placedInBet)", uniqueId: "\(match.matchID)YourBet")
                        .padding(.horizontal)
                        .accessibilityLabel("your bet, \(viewedBy.placedInBet) chips. ")
                        .accessibilityValue(" (\( GameLocalizer.itsHisTurn( of: viewedBy, in: game, and: match) ))")
                        .accessibilityCustomContent(AccessibilityCustomContentKey(Text(""), id: "quickSummary"), Text( GameLocalizer.quickStatus( of: game, and: match, for: viewedBy).joined(separator: ". \n") ) )
                    DealerToken(forPlayer: viewedBy, game: game, tokenSize: 26)
                    
                    CardStackView(stack: viewedBy.hand, anim_ns: cardAnim_ns,
                                  desiredCardWidth: HAND_STACK_CARD_WIDTH, desiredXSpacing: HAND_STACK_CARD_WIDTH, desiredYSpacing: 0, fitInRect: true, holdAtAngle: .degrees(-2), asSeenBy: viewedBy.matchParticipantIndex)
                    .accessibilityHint( Text("In your hand."))
                    .rotation3DEffect(viewedBy.dropped ? .degrees(70) : .zero, axis: (x: 1, y: 0, z: 0), anchor: .bottom, anchorZ: 0, perspective: 1)
                    //.modifier(StackGlowFlasher2(activeState: game.actingOrder.first == viewedBy.matchParticipantIndex, radius: 27, color: .white) )
                    .accessibilityFocused($playerAxFocus, equals: 20 + viewedBy.matchParticipantIndex)
                    .accessibilityCustomContent("this card is in your hand", Text(""))                        .padding(.bottom, 8)
                    
                } //vs cards and token
                //.frame(minHeight: geo.size.height * 0.3, idealHeight: geo.size.height * 0.379, maxHeight: geo.size.height * 0.407, alignment: .bottom)
                .frame(
                    height: geo.size.height * (geo.isLandscape ? BOT_ROW_RATIO_LANDSCAPE : BOT_ROW_RATIO_PORTRAIT),
                    //maxWidth: geo.isLandscape ? ( geo.size.width * 0.35 ) : .infinity,
                    alignment: .bottom)
                // .background(.black)
            } //combo swap vs
        } //main vs
        .foregroundColor(.white)
        .font(.headline)
            VStack {
                if let seed = amountPickerToShow,
                   viewedBy === amountPickerToShow?.actor,
                   game.ActingPlayaMenu.contains( where: { act in
                       act.id == amountPickerToShow?.action.id
                   })
                {
                    BetRaiseAmountPicker(isPresented: $amountPickerToShow, match: match, game: game, actor: seed.actor, action: seed.action, onSubmit: seed.onSubmit)
                        .accessibility(addTraits: .isModal)
                        .transition(.scale.applyReduceMotion( reduceMotion: shouldReduceMotion, allowFade: true))
                } //if
                if showingPotInfo {
                    PotInfoView( isPresented: $showingPotInfo, game: game, match: match)
                        .accessibility(addTraits: .isModal)
                        .transition(.scale.applyReduceMotion( reduceMotion: shouldReduceMotion, allowFade: true))
                } //if
                if showingOverlayedGameLog {
                    LogInfoView(isPresented: $showingOverlayedGameLog.animation(), dismissable: true, game: game, match: match, viewedBy: viewedBy)
                        .accessibility(addTraits: .isModal)
                    .transition(.scale.applyReduceMotion( reduceMotion: shouldReduceMotion, allowFade: true))
                        // .transition(.asymmetric(
                            //insertion: .move (edge: .bottom).applyReduceMotion( reduceMotion: shouldReduceMotion, allowFade: true),
                            //removal: .move (edge: .bottom).applyReduceMotion( reduceMotion: shouldReduceMotion, allowFade: true)) )
                } //if
            } //vs
            // .animation(.default, value: showingOverlayedGameLog || showingPotInfo || (amountPickerToShow != nil))
            .animation(.default, value: combineStates)
        } //zs
        } //geo
        //.sheet(isPresented: $showingPotInfo, content: {
            //PotInfoView( game: game, match: match)
        //})
    } //body
    func setFocusToFirstActing() -> Void {
        if match.isLocalPlayersTurn() {
            self.playerAxFocus = 30
        } else {
            if let firstActing = game.actingOrder.first {
                self.playerAxFocus = 20 + firstActing
            }
        }
    } //func
} //str

struct DealerToken: View {
    let forPlayer: PokerPlayer
    @ObservedObject var game: HoldemGame
    let tokenSize: CGFloat
    
    var body: some View {
        if forPlayer.matchParticipantIndex == game.actAsDealer {
            Circle()
                .fill(Color.green )
                .frame(width: tokenSize, height: tokenSize, alignment: .center)
        } else {
            //EmptyView()
            Color.clear
                .frame(width: tokenSize, height: tokenSize, alignment: .center)
        } //else
    } //body
} //str

extension GeometryProxy {
    var isLandscape: Bool {
        size.width > size.height
    } //cv
} //ext
extension GameController {
    static func isLocalTurnDoubleCheck(in game: HoldemGame, and match: GKTurnBasedMatch) -> Bool {
        match.isLocalPlayersTurn()
        && !game.actingOrder.isEmpty
        && game.actingOrder.first == match.localParticipantIndex()
    } //func
} //ext
extension GameLocalizer {
    static func yourChipsStatus(in game: HoldemGame, of viewer: PokerPlayer) -> String {
        let f = NumberFormatter()
        //f.formatterBehavior = .behavior10_4
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 2
        return String.localizedStringWithFormat("you have a total of %@ chips, of which you have bet %@", f.string(from: NSNumber(value: viewer.chips)) ?? "unknown", f.string(from: NSNumber(value: viewer.placedInBet)) ?? "unknown")
    } //func
    static func thereAreCardsOnTheTable(in game: HoldemGame) -> String {
        switch game.flop.cards.count {
        case 0:
            return "there are no common cards facing up, on the flop"
        default:
            return String.localizedStringWithFormat("there are %d common cards facing up, in the flop", game.flop.cards.count)
        } //swi
    } //func
    static func quickStatus( of game: HoldemGame, and match: GKTurnBasedMatch, for player: PokerPlayer) -> [String] {
        var result = [ game.gameState.longDescription ]
        result.append( thereAreCardsOnTheTable(in: game) )
        if !game.flop.cards.isEmpty {
            result.append( ListFormatter.localizedString( byJoining: game.flop.cards.map({
                $0.readableName
            })) )
        } //if
        result.append( "Your cards are: " + ListFormatter.localizedString( byJoining: player.hand.cards.map({
            $0.readableName
        })) )
        result.append( GameLocalizer.yourChipsStatus( in: game, of: player) )
        result.append("The game bet is now \(game.currentBetSize)")
        result.append("Total pot: \(game.totalPotSize) chips.")
        return result
    }
} //ext
