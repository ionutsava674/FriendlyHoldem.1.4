//
//  AgreeingStage1View.swift
//  CardPlay
//
//  Created by Ionut on 24.06.2022.
//

import SwiftUI
import GameKit

struct Stage1View: View {
    var gspVariants: [GameStartParameters]
    var onSelectedVariant: ((GameStartParameters) -> Void)?
    var onCreatedVariant: ((GameStartParameters) -> Void)?

    @State private var wantToAdd = false
    private var needToAdd: Bool { wantToAdd || gspVariants.isEmpty } //cv
    
    @State private var newChips = "1000"
    @State private var newSmallBlind = "20"
    @State private var newBigBlind = "50"
    @State private var newMinRaise = "50"
    @State private var newTimeout: TimeInterval = GKTurnTimeoutNone

    @AccessibilityFocusState private var axTitleFocused: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text("First, we need to agree on the stakes of the game.")
                .font(.title)
                .padding()
                .accessibilityFocused($axTitleFocused)
        GSPLister( gspVariants: self.gspVariants, onClick: onSelectedVariant)
            if !self.gspVariants.isEmpty {
                Text("or, you can")
                    .font(.headline)
            }
        if !needToAdd {
            PaddedButton( text: NSLocalizedString("Propose a different structure", comment: "")) {
                self.wantToAdd = true
            } //btn
        } //if
        else {
            GSPAddForm(newChips: $newChips, newSmallBlind: $newSmallBlind, newBigBlind: $newBigBlind, newMinRaise: $newMinRaise, newTimeOut: $newTimeout, onClick: {
                guard let c = ChipsCountType(self.newChips),
                      let s = ChipsCountType(self.newSmallBlind),
                      let b = ChipsCountType(self.newBigBlind),
                      let m = ChipsCountType(self.newMinRaise),
                      GameStartParameters.validParameters( startChips: c, smallBlind: s, bigBlind: b, minRaiseAmount: m)
                else {
                    return
                }
                let newVal = GameStartParameters( startChips: c, smallBlind: s, bigBlind: b, minRaiseAmount: m, turnTimeout: self.newTimeout)
                onCreatedVariant?(newVal)
            }) //form
        } //can show form
        } //vs
    } //body
} //str
