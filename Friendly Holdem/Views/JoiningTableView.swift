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

    var body: some View {
        GeometryReader { geo in
        ZStack {
            Text("\( amountPickerToShow?.actor.matchParticipantIndex ?? -1 )").hidden()
            //Text("\(playerAxFocus ?? -1)").hidden()
            RadialGradient( colors: [
                Color( red: 0.1, green: 0.2, blue: 0.45),
                Color( red: 0.1, green: 0.45, blue: 0.2)
            ], center: UnitPoint(x: 0.3, y: 0.8), startRadius: 0.2 * 1000.0, endRadius: 0.6 * 1000.0)
                .brightness( 0.112)
            Color.pink
        VStack(alignment: .center, spacing: 0) { //main vs //others and tokens
            HStack(alignment: .center, spacing: 0) {
                let otherPlayers = game.allPlayers.nextOthersOf( mpIndex: viewedBy.matchParticipantIndex, includeAtEnd: false) ?? game.allPlayers
                ForEach(otherPlayers, id: \.matchParticipantIndex) { otherPlayer in
                    OtherPlayerView(otherPlayer: otherPlayer, game: game, viewedBy: viewedBy, match: match, anim_ns: cardAnim_ns)
                    .accessibilityFocused( $playerAxFocus, equals: 20 + otherPlayer.matchParticipantIndex)
                } //fe
            } //top hs
            //.padding([.top], 4)
            .frame(minHeight: geo.size.height * 0.20, idealHeight: geo.size.height * 0.21, maxHeight: geo.size.height * 0.22, alignment: .top)
            .background(.black)
            Spacer()
            HStack(alignment: .center, spacing: 0) { //mid
                if game.dealerStackVisible {
                    VStack {
                        CardStackView(stack: game.dealerStack, anim_ns: cardAnim_ns, desiredCardWidth: 58, desiredXSpacing: 58 / 5 / 54, desiredYSpacing: 58 / 5 / 54, fitInRect: true, holdAtAngle: .zero, onlyLastAccessible: true, asSeenBy: viewedBy.matchParticipantIndex, backFacingText: "Cards facing down, … ", onlyShow: 10)
                            .accessibilityLabel(game.gameState.longDescription)
                            .accessibilityAction( named: Text( GameController.thereAreCardsOnTheTable( in: game) ), {
                                self.playerAxFocus = 40
                            }) //act
                            .conditionalAxAction( condition: !GameController.isLocalTurnDoubleCheck(in: game, and: match),
                                                  named: Text( GameController.whenItsYourTurn(in: game, and: match) ), { })
                            .accessibilityAction( named: Text("Total pot: \(game.totalPotSize) chips."), { })
                            .accessibilityAction( named: Text( GameController.yourChipsStatus( in: game, of: viewedBy) ), { })
                            .accessibilityAction( named: Text( GameController.nowItsWhosReallyTurn(in: game, and: match) ?? "the current turn is unknown" ), {
                                self.setFocusToFirstActing()
                            }) //act
                        
                        JumpingText(text: "🪙 \(game.totalPotSize)", uniqueId: "\(match.matchID)PotSize")
                            .accessibilityLabel(Text("Total pot"))
                            .accessibilityValue( Text("\(game.totalPotSize) chips."))
                            .onTapGesture {
                                self.showingPotInfo = true
                            }
                } //vs
                    .frame(width: geo.size.width * 0.33, alignment: .center)
                } //if
                //GeometryReader { flopGeo in
                    //List {
                        CardStackView(stack: game.flop, anim_ns: cardAnim_ns, desiredCardWidth: 92, desiredXSpacing: 110, desiredYSpacing: 0, fitInRect: true, holdAtAngle: .zero, asSeenBy: match.localParticipantIndex() ?? -1)
                    //.conditionalAxValue( !game.flop.cards.isEmpty, valueDescription: Text(", this is a flop card"))
                    .conditionalAxContent( !game.flop.cards.isEmpty, key: AccessibilityCustomContentKey(Text("On the table, facing up"), id: "location"), contentValue: Text(""))
                    .accessibilityFocused($playerAxFocus, equals: 40)
                        // .background(Color.red)
                    //} //ls
                //} //geo
            } //mid hs
            .frame(minHeight: geo.size.height * 0.21, idealHeight: geo.size.height * 0.24, maxHeight: geo.size.height * 0.26, alignment: .center)
            .background(.black)
            Spacer()
            Button("show events") {
                HoldemGame.cardMoveSound?.prepareAndPlay()
                withAnimation {
                    self.showingOverlayedGameLog = true
                }
            }
            //if match.isLocalPlayersTurn() && game.isActingPlayer( viewedBy) {
            if GameController.isLocalTurnDoubleCheck(in: game, and: match) {
                    //AxActionMenuView(gameModel: game, match: match)
                    ActiveActionMenu2(gameModel: game, match: match, gotAmountPickerSeed: $amountPickerToShow)
                        .accessibilityFocused($playerAxFocus, equals: 30)
                    //BlinkingButton()
            } else {
                //if inactive
                InactiveActionMenuView(gameModel: game, viewedBy: viewedBy, match: match)
                    .accessibilityCustomContent( AccessibilityCustomContentKey(Text( "" ), id: "when your turn"), Text( GameController.whenItsYourTurn(in: game, and: match) ))
                .accessibilityCustomContent( AccessibilityCustomContentKey(Text(""), id: "game status"), Text( game.gameState.shortDescription ))
                .accessibilityCustomContent( AccessibilityCustomContentKey(Text("is acting as current dealer"), id: "current dealer"), Text( GameController.playerAlias( of: game.actAsDealer, in: match, unknownIndexDefault: "unknown") ))
                .accessibilityCustomContent( AccessibilityCustomContentKey(Text("is now in turn"), id: "now in turn"), Text( GameController.playerAlias(of: game.actingOrder.first, in: match, unknownIndexDefault: "unknown") ))
            } //else
                VStack(alignment: .center, spacing: 0) { //me and token
                    JumpingText(text: "🪙 \(viewedBy.placedInBet)", uniqueId: "\(match.matchID)YourBet")
                        .padding(.horizontal)
                            .accessibilityLabel("your bet, \(viewedBy.placedInBet) chips. ")
                            .accessibilityValue(" (\( GameController.itsHisTurn( of: viewedBy, in: game, and: match) ))")
                            .accessibilityCustomContent(AccessibilityCustomContentKey(Text(""), id: "quickSummary"), Text( GameController.quickStatus(of: game, and: match, for: viewedBy).joined(separator: ". \n") ) )
                            .onTapGesture {
                                gch.displayError(msg:  game.gameLog.map({
                                    $0.print(for: game, and: match)
                                }).joined(separator: "\n") )
                            }
                    DealerToken(forPlayer: viewedBy, game: game, tokenSize: 26)
                    CardStackView(stack: viewedBy.hand, anim_ns: cardAnim_ns,
                                  desiredCardWidth: 200, desiredXSpacing: 200, desiredYSpacing: 0, fitInRect: true, holdAtAngle: .degrees(-2), asSeenBy: viewedBy.matchParticipantIndex)
                    .accessibilityHint( Text("In your hand."))
                        .rotation3DEffect(viewedBy.dropped ? .degrees(70) : .zero, axis: (x: 1, y: 0, z: 0), anchor: .bottom, anchorZ: 0, perspective: 1)
                        .modifier(StackGlowFlasher2(activeState: game.actingOrder.first == viewedBy.matchParticipantIndex, radius: 27, color: .white) )
                        .accessibilityFocused($playerAxFocus, equals: 20 + viewedBy.matchParticipantIndex)
                        .accessibilityCustomContent("this card is in your hand", Text(""))                        .padding(.bottom, 8)
                } //vs cards and token
            .frame(minHeight: geo.size.height * 0.3, idealHeight: geo.size.height * 0.379, maxHeight: geo.size.height * 0.407, alignment: .bottom)
            .background(.black)
        } //main vs
        .foregroundColor(.white)
            
            if let seed = amountPickerToShow,
               viewedBy === amountPickerToShow?.actor,
               game.ActingPlayaMenu.contains( where: { act in
                   act.id == amountPickerToShow?.action.id
               })
            {
                BetRaiseAmountPicker(isPresented: $amountPickerToShow, match: match, game: game, actor: seed.actor, action: seed.action, onSubmit: seed.onSubmit)
                    .accessibility(addTraits: .isModal)
            } //if
            if showingOverlayedGameLog {
                LogInfoView(isPresented: $showingOverlayedGameLog, dismissable: true, game: game, match: match, viewedBy: viewedBy)
                    .accessibility(addTraits: .isModal)
                    .transition(.scale.applyReduceMotion( reduceMotion: shouldReduceMotion, allowFade: true))
                    // .animation(.easeIn, value: showingOverlayedGameLog)
            } //if
        } //zs
        } //geo
        .sheet(isPresented: $showingPotInfo, content: {
            PotInfoView( game: game, match: match)
        })
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

extension GameController {
    static func isLocalTurnDoubleCheck(in game: HoldemGame, and match: GKTurnBasedMatch) -> Bool {
        match.isLocalPlayersTurn()
        && !game.actingOrder.isEmpty
        && game.actingOrder.first == match.localParticipantIndex()
    } //func
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
    static func quickStatus(of game: HoldemGame, and match: GKTurnBasedMatch, for player: PokerPlayer) -> [String] {
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
        result.append( GameController.yourChipsStatus( in: game, of: player) )
        result.append("The game bet is now \(game.currentBetSize)")
        result.append("Total pot: \(game.totalPotSize) chips.")
        return result
    }
} //ext
