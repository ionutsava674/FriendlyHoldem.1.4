//
//  VariantAddForm.swift
//  CardPlay
//
//  Created by Ionut on 24.06.2022.
//

import SwiftUI
import GameKit
struct GSPAddForm: View {
    @Binding var newChips: String
    @Binding var newSmallBlind: String
    @Binding var newBigBlind: String
    @Binding var newMinRaise: String
    @Binding var newTimeOut: TimeInterval
    
    var onClick: (() -> Void)?
    @FocusState private var focusedItem: FocusedItemType?
    @AccessibilityFocusState private var axFocused: FocusedItemType?
    enum FocusedItemType: Hashable {
    case chips, small, big, minraise, timeout, submit
    } //enum
    
    let hvSpacing: CGFloat = 12
    let animTime: TimeInterval = 0.7
    
    func timeStr(timeInterval: TimeInterval) -> String {
        guard timeInterval != GKTurnTimeoutNone else {
            return NSLocalizedString("no limit", comment: "no limit")
        }
        let f = DateComponentsFormatter()
        f.unitsStyle = .full
        f.formattingContext = .standalone
        return f.string(from: timeInterval) ?? "\(timeInterval) sec"
    } //func
    var body: some View {
        /*
        let timeoutBind = Binding<Int>(
            get: {
                guard let i = GameStartParameters.gameTimeouts.firstIndex( of: self.newTimeOut) else {
                    self.newTimeOut = GameStartParameters.gameTimeouts[0]
                    return 0
                }
                return i
            },
            set: {
                self.newTimeOut = GameStartParameters.gameTimeouts[$0]
            }
        )
         */
        return VStack(alignment: .center, spacing: 12) {
            Text("Enter below the game stakes you would like to propose")
                .font(.headline)
                //.padding()
        VStack(alignment: .leadingAlignInForm, spacing: hvSpacing) {
                HStack(spacing: hvSpacing) {
                Text("Each player will start with")
                        .accessibilityFocused($axFocused, equals: .chips)
                TextField("start chips", text: self.$newChips)
                        .focused($focusedItem, equals: .chips)
                        .submitLabel(.next)
                        .frame(width: 64, alignment: .leading)
                        .alignmentGuide(.leadingAlignInForm) { dim in dim[.leading] }
                } //hs
                HStack(spacing: hvSpacing) {
                Text("Small blind bet")
                        .accessibilityFocused($axFocused, equals: .small)
                TextField("small blind bet", text: self.$newSmallBlind)
                        .focused($focusedItem, equals: .small)
                        .submitLabel(.next)
                        .frame(width: 64, alignment: .leading)
                        .alignmentGuide(.leadingAlignInForm) { dim in dim[.leading] }
                } //hs
                HStack(spacing: hvSpacing) {
                Text("Big blind bet")
                        .accessibilityFocused($axFocused, equals: .big)
                TextField("big blind bet", text: self.$newBigBlind)
                        .focused($focusedItem, equals: .big)
                        .submitLabel(.next)
                        .frame(width: 64, alignment: .leading)
                        .alignmentGuide(.leadingAlignInForm) { dim in dim[.leading] }
                } //hs
                HStack(spacing: hvSpacing) {
                Text("Minimum bet raise")
                        .accessibilityFocused($axFocused, equals: .minraise)
                TextField("min raise amount", text: self.$newMinRaise)
                        .focused($focusedItem, equals: .minraise)
                        .submitLabel(.next)
                        .frame(width: 64, alignment: .leading)
                        .alignmentGuide(.leadingAlignInForm) { dim in dim[.leading] }
                } //hs
            /*
            HStack(spacing: hvSpacing) {
            Text("Select the time limit")
                .accessibilityFocused($axFocused, equals: .timeout)
            Picker("", selection: timeoutBind) {
                ForEach( 0..<GameStartParameters.gameTimeouts.count ) { eachIndex in
                    Text( timeStr(timeInterval: GameStartParameters.gameTimeouts[ eachIndex]) )
                        .font(.headline.bold())
                } //fe
            } //pk
            //.accessibilityLabel("Select the turn time limit")
            .accessibilityValue( timeStr( timeInterval: newTimeOut))
            .alignmentGuide(.leadingAlignInForm) { dim in dim[.leading] }
            } //hs
             */
            } //vs align
        .onSubmit {
            Task {
                await self.keyboardSubmitButtonClick( capturedFocus: self.focusedItem)
            } //task
        } //submit
        .keyboardType(.numbersAndPunctuation)
            /*
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    Button {
                        //self.submitButtonClick()
                        debugMsg_("nexted")
                    } label: {
                        Text(self.focusedItem == .minraise
                        ? "Propose"
                             : "Next field"
                        )
                    }

                } //t b i
            } //tb
             */
        PaddedButton( text: NSLocalizedString("Propose", comment: ""), onClick: onClick)
        .disabled( !validateButton())
        .accessibilityFocused($axFocused, equals: .submit)
            //} //sv
        } //vs 1
        .onAppear {
            //
        } //onapp
        //} //nv
        // .navigationViewStyle(.stack)
    } //body
    @MainActor func keyboardSubmitButtonClick( capturedFocus: FocusedItemType?) async -> Void {
        try? await Task.sleep( seconds: self.animTime)
        switch capturedFocus {
        case .chips:
            axFocused = .small
            focusedItem = .small
        case .small:
            axFocused = .big
            focusedItem = .big
        case .big:
            axFocused = .minraise
            focusedItem = .minraise
        case .minraise:
            axFocused = .submit
            self.focusedItem = nil
            //self.onClick?()
        default:
            break
        } //swi
    } //func
    func validateButton() -> Bool {
        return GameStartParameters.validStringParameters( startChips: self.newChips, smallBlind: self.newSmallBlind, bigBlind: self.newBigBlind, minRaiseAmount: self.newMinRaise)
    } //func
} //str
