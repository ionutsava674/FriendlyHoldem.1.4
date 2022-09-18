//
//  MenuAndMatchView.swift
//  CardPlay
//
//  Created by Ionut on 03.12.2021.
//

import SwiftUI
import GameKit

struct MenuAndMatchView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @EnvironmentObject var gch: GCHelper
    @ObservedObject var match: GKTurnBasedMatch
    @Namespace var nsmatchviewID
    
    @AppStorage("savedMatch") private var savedMatch: String = ""
    @State private var showingDebugOutput = false
    @State private var showingMenu = false
    func dismissMenu() -> Void {
        animateMenu( visible: false)
    } //func
    func animateMenu( visible: Bool) -> Void {
        withAnimation(.default) {
            showingMenu = visible
        } //wa
    } //func

    var body: some View {
        GeometryReader { geo in
        VStack {
            HStack {
                Button( showingMenu ? "Close menu" : "menu") {
                    self.animateMenu( visible: !self.showingMenu)
                } //btn
                .font(.body.bold())
                .padding(.horizontal)
                Spacer()
                #if DEBUG
                if debugHeaderRow {
                    HStack { //deb hs
                        Button("Save") {
                            savedMatch = match.matchID
                        }
                        Button("Load") {
                            guard !savedMatch.isEmpty else {
                                return
                            }
                            _ = self.gch.selectAvailableMatch(matchID: savedMatch)
                        }
                    Button("see output") {
                        showingDebugOutput = true
                    } //btn

                        if match.isLocalPlayersTurn() {
                        Button("re create game") {
                            Task {
                                _ = gch.recreateGame()
                                await gch.preEvaluateCurrentGameAsync()
                            }
                        } //btn
                            Button("set for") {
                                guard let game = gch.currentGame,
                                      let lpi = match.localParticipantIndex()
                                else {
                                    return
                                }
                                // Tester1.getInstance.setFor3(for: game, nextActive: lpi)
                                //Tester1.getInstance.setFor3out1( for: game, nextActive: lpi)
                            } //btn
                        } //hs
                    } //debug hs
                    .background(.red)
                    .foregroundColor(.white)
                } // if debug
#endif
            } // menu hs
            if showingMenu {
                MatchInfo1View(match: match)
                    .padding()
                
                if match.isOpenOrMatching()
                    && match.localJoining() {
                    Button {
                        self.gch.showingQuitDialog = true
                        self.dismissMenu()
                    } label: {
                        Text("Quit this game")
                    } //btn
                } //if can quit

                MatchMenuView( onMenuItemSelected: {
                    self.dismissMenu()
                })
                .font(.largeTitle.bold())
                .transition(.pivotUpFromLeading.applyReduceMotion( reduceMotion: reduceMotion, allowFade: true))
            }
            else {
            ZStack {
                MatchView(match: match)
                    .matchedGeometryEffect(id: "mvid\( match.matchID)", in: self.nsmatchviewID)
            } //zs
            .frame(maxWidth: geo.size.width, maxHeight: geo.size.height, alignment: .center)
            .transition(.asymmetric(
                insertion: .move (edge: .bottom).applyReduceMotion( reduceMotion: reduceMotion, allowFade: true),
                //removal: .scale(scale: 10) ) )
                removal: .move (edge: .bottom).applyReduceMotion(reduceMotion: reduceMotion, allowFade: true)) )
            } //menu else
        } //vs
        } //geo
        #if DEBUG
        .sheet(isPresented: $showingDebugOutput, content: {
            if debugBuffer {
                DebugView()
            } else {
                EmptyView()
            }
        }) //debug sheet
        #endif
    } //body
} //str

extension AnyTransition {
    func applyReduceMotion( reduceMotion: Bool, allowFade: Bool) -> AnyTransition {
        reduceMotion
        ? (allowFade ? .opacity : .identity)
        : self
    }
    static var pivotUpFromLeading: AnyTransition {
        .modifier(
            active: ContentRotateModifier(amount: -90, anchor: .topLeading),
                  identity: ContentRotateModifier(amount: 0, anchor: .topLeading))
    } //cv
} //ext
struct ContentRotateModifier: ViewModifier {
    let amount: Double
    let anchor: UnitPoint
    
    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(amount), anchor: anchor)
            .clipped()
    } //body
} //modif str
