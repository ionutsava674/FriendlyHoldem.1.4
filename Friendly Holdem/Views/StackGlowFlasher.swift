//
//  StackGlowFlasher.swift
//  CardPlay
//
//  Created by Ionut on 04.12.2021.
//

import SwiftUI

struct StackGlowFlasher2: ViewModifier {
    let activeState: Bool
    let radius: CGFloat
    let color: Color
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var appActive = true
    private let matchRefreshTimer = Timer.publish( every: 2, tolerance: 0.3, on: .main, in: .common, options: nil).autoconnect()
    @State private var glowing = false
    var glowingAndActive: Bool {
        glowing && activeState
    }
    
    func body( content: Content) -> some View {
        let shaRad = self.glowing ? (radius / 3) : 0
        //let shaCol = self.glowing ? color : .clear
        return content
            .shadow(color: self.glowingAndActive ? color : .clear, radius: self.glowingAndActive ? shaRad : 0)
            .shadow(color: self.glowingAndActive ? color : .clear, radius: self.glowingAndActive ? shaRad : 0)
            .shadow(color: self.glowingAndActive ? color : .clear, radius: self.glowingAndActive ? shaRad : 0)
            //.background(content: {
                //Rectangle()
                    //.fill( self.glowing ? color : .clear )
                    //.frame(width: radius * 4, height: radius * 4, alignment: .center)
            //})
            .onReceive(matchRefreshTimer) { time in
                guard self.appActive && self.activeState else {
                    if !self.activeState {
                        self.glowing = false
                    }
                    return
                } //gua
                withAnimation( self.glowing ? .linear(duration: 1.5) : .easeInOut(duration: 1.5)) {
                    self.glowing.toggle()
                } //wa
            } //rec
            .onChange(of: scenePhase, perform: { newValue in
                self.appActive = newValue == .active
            }) //scene change
    } //body
} //str
struct StackGlowFlasher: ViewModifier {
    @ObservedObject var gameModel: HoldemGame
    let forStack: CardStack
    let radius: CGFloat
    let color: Color
    
    @State private var flashing: Bool = false
    private var shouldFlash: Bool {
        !gameModel.actingOrder.isEmpty
        && gameModel.actingOrder.first == forStack.ownerPlayer
    } //cv
    
    func body( content: Content) -> some View {
        let shaRad = flashing ? (radius / 3) : 0
        let shaCol = flashing ? color : .clear
        return content
            .shadow(color: shaCol, radius: flashing ? shaRad : 0)
            .shadow(color: shaCol, radius: flashing ? shaRad : 0)
            .shadow(color: shaCol, radius: flashing ? shaRad : 0)
            .onAppear {
                if shouldFlash {
                    flashing = true
                }
            } //app
        /*
            .onReceive( self.gameModel.actingOrder) { po in
                self.flashing = false
                if shouldFlash {
                    DispatchQueue.main.async {
                        self.flashing = self.shouldFlash
                    } /dq
                } //if
            } //rec
         */
    } //body
} //str
