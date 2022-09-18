//
//  CTestView.swift
//  CardPlay
//
//  Created by Ionut on 09.12.2021.
//

import SwiftUI

struct CTestView: View {
    static let allCards = HoldemGame.newPokerDeck()
    @Namespace private var nsid
    @State private var stack: CardStack = CardStack(cards: [ allCards[0] ] , ownerIndex: nil, whoCanSee: .everyOne)
    @State private var stack2: CardStack = CardStack(cards: Card.noCards , ownerIndex: nil, whoCanSee: .noOne)

    func give() {
        if self.stack.cards.isEmpty {
            _ = self.stack2.giveLastCard(to: self.stack)
        } else {
            _ = self.stack.giveLastCard(to: self.stack2)
        } //else
    } //func
    var body: some View {
        HStack {
            CardStackView(stack: self.stack, anim_ns: nsid, desiredCardWidth: 200, desiredXSpacing: 0, desiredYSpacing: 0, fitInRect: true, holdAtAngle: .zero, onlyLastAccessible: false, asSeenBy: 20)
            VStack {
                Button("give") {
                    self.give()
                } //btn
                Button("anim give") {
                    withAnimation(.easeInOut(duration: 6)) {
                        self.give()
                    }
                } //btn
                VStack {
                    Button("flip") {
                        self.stack.whoCanSee = (self.stack.whoCanSee == .noOne)
                        ? .everyOne
                        : .noOne
                    } //btn
                    Button("anim flip") {
                        withAnimation(.easeInOut(duration: 6)) {
                            self.stack.whoCanSee = (self.stack.whoCanSee == .noOne)
                            ? .everyOne
                            : .noOne
                        } //wa
                    } //btn
                } //vs
                //.hidden()
            } //vs2
            CardStackView(stack: self.stack2, anim_ns: nsid, desiredCardWidth: 200, desiredXSpacing: 0, desiredYSpacing: 0, fitInRect: true, holdAtAngle: .zero, onlyLastAccessible: false, asSeenBy: 20)
        } //hs
    } //body
} //str

struct CTestView_Previews: PreviewProvider {
    static var previews: some View {
        CTestView()
    }
}
