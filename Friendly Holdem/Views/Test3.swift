//
//  Test3.swift
//  CardPlay
//
//  Created by Ionut on 10.07.2022.
//

import SwiftUI

struct Test3: View {
    @ObservedObject var game: HoldemGame
    @Namespace var testcardAnim_ns
    
    func encdec(_ gm: HoldemGame) -> HoldemGame? {
        if let d1 = gm.toJSON() {
            if let gg = try? JSONDecoder().decode(HoldemGame.self, from: d1) {
                return gg
            }
        }
        return nil
    } //func
    func retrieve( newActive: Int) -> Void {
        guard let g = encdec(game) else {
return
        }
        _ = g.allPlayers[0].hand.giveLastCard(to: g.dealerStack)
        _ = g.allPlayers[0].hand.giveLastCard(to: g.dealerStack)
        _ = g.allPlayers[0].hand.giveLastCard(to: g.dealerStack)
        _ = g.setInRoundActingOrder( startingWith: newActive, andCompileMenu: true)
        withAnimation(.easeInOut(duration: 5)) {
            Tester1.getInstance.game = g
        }
    } //func
    func give( newActive: Int) -> Void {
        guard let g = encdec(game) else {
return
        }
        _ = g.dealerStack.giveLastCard(to: g.allPlayers[0].hand)
        _ = g.dealerStack.giveLastCard(to: g.allPlayers[0].hand)
        _ = g.dealerStack.giveLastCard(to: g.allPlayers[0].hand)
        _ = g.setInRoundActingOrder( startingWith: newActive, andCompileMenu: true)
        withAnimation(.easeInOut(duration: 5)) {
            Tester1.getInstance.game = g
        }
    } //func
    func setup() -> Void {
        let g = self.game
        g.enterRound0Old()
        g.putStaticCards()
        _ = g.setInRoundActingOrder(startingWith: 0, andCompileMenu: true)
        _ = g.dealerStack.giveLastCard(to: g.allPlayers[0].hand)
        _ = g.dealerStack.giveLastCard(to: g.allPlayers[0].hand)
        _ = g.dealerStack.giveLastCard(to: g.allPlayers[0].hand)
        Tester1.getInstance.game = g
    } //func
    
    var body: some View {
        VStack {
            HStack {
                CardStackView(stack: game.dealerStack, anim_ns: testcardAnim_ns, desiredCardWidth: 58, desiredXSpacing: 58 / 5 / 54, desiredYSpacing: 58 / 5 / 54, fitInRect: true, holdAtAngle: .zero, onlyLastAccessible: true, asSeenBy: 0, backFacingText: "card deck", onlyShow: 10)
                    .frame(minHeight: 50, idealHeight: 100, maxHeight: 150, alignment: .center)
                CardStackView(stack: game.allPlayers[0].hand, anim_ns: testcardAnim_ns, desiredCardWidth: 50, desiredXSpacing: 40, desiredYSpacing: 0, fitInRect: true, holdAtAngle: .degrees(-5), asSeenBy: 0)
                        .rotation3DEffect( .zero, axis: (x: 1, y: 0, z: 0), anchor: .bottom, anchorZ: 0, perspective: 1)
                        .modifier(StackGlowFlasher(gameModel: game, forStack: game.allPlayers[0].hand, radius: 127, color: .white) )
                        //.accessibilityElement(children: .ignore)
                        //.accessibilityLabel( "otherAlias")
                        .accessibilityValue("(\( GameController.dealerStatus( of: game.allPlayers[0], in: game) )")
            } //hs
            HStack {
                Button("setup") { setup() }
            } //hs
            HStack {
                Button("retrieve 2") { retrieve(newActive: 2) }
                Button("retrieve 0") { retrieve(newActive: 0) }
            } //hs
            HStack {
                Button("give 2") { give(newActive: 2) }
                Button("give 0") { give(newActive: 0) }
            } //hs
                //.accessibilityValue("(\( GameController.whoIsCurrentDealer( in: game, and: match) ))")
        } //vs
    } //body
} //str

