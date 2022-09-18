//
//  BetRaiseAmountPicker.swift
//  CardPlay
//
//  Created by Ionut on 24.08.2022.
//

import SwiftUI
import GameKit

struct BetRaiseAmountPickerSeed: Identifiable {
    let action: PokerPlayerAction
    let actor: PokerPlayer
    let onSubmit: ((ChipsCountType) -> Void)?
    var id: UUID { action.id }
} //str
struct BetRaiseAmountPicker: View {
    //@Binding var isPresented: Bool
    @Binding var isPresented: BetRaiseAmountPickerSeed?
    @ObservedObject var match: GKTurnBasedMatch
    @ObservedObject var game: HoldemGame
    @ObservedObject var actor: PokerPlayer
    let action: PokerPlayerAction
    let onSubmit: ((ChipsCountType) -> Void)?
    
    private var minAmount: ChipsCountType {
        Swift.min(game.minRaiseTarget, actor.chips)
    } //cv
    private var maxAmount: ChipsCountType { actor.chips }
    
    @State private var customChosenBetAmount = ""
    private var submitTitle: String {
        guard let nv = ChipsCountType( customChosenBetAmount) else {
            return NSLocalizedString("OK", comment: "")
        }
        switch game.canSetBet( for: actor.matchParticipantIndex, to: nv) {
        case .raiseBet:
            return String.localizedStringWithFormat(NSLocalizedString("Raise to %@", comment: ""), "\(nv)")
        case .allIn:
            return NSLocalizedString("Bet all in", comment: "")
        case .call:
            return String.localizedStringWithFormat(NSLocalizedString("Call at %@", comment: ""), "\(nv)")
        case .lessThanMin, .dontHaveEnough, .someOtherError, .invalidPlayer:
            return NSLocalizedString("OK", comment: "")
        }
    } //cv
    private var msgForValue: String {
        guard let nv = ChipsCountType( customChosenBetAmount) else {
            return NSLocalizedString("You need to enter a valid amount of chips.", comment: "")
        }
        switch game.canSetBet( for: actor.matchParticipantIndex, to: nv) {
        case .raiseBet:
            return ""
        case .allIn:
            return ""
        case .call:
            return ""
        case .lessThanMin:
            return String.localizedStringWithFormat(NSLocalizedString("You need to raise the bet to at least %@.", comment: ""), "\(game.minRaiseTarget)")
        case .dontHaveEnough:
            return NSLocalizedString("You don't have enough to bet this much.", comment: "")
        case .someOtherError, .invalidPlayer:
            return NSLocalizedString("An unexpected error occured.", comment: "")
        } //swi
    } //cv
    
    //@Environment(\.presentationMode) private var premo
    private func dismiss() {
        self.isPresented = nil
    } //func
    private func submit() -> Void {
        guard let amount = ChipsCountType( customChosenBetAmount) else {
            return
        }
        dismiss()
        onSubmit?( amount)
    } //func
    private func isValidAmount( _ amount: String) -> Bool {
        guard let nv = ChipsCountType( amount) else {
            return false
        }
        return game.canSetBet( for: actor.matchParticipantIndex, to: nv).succeeded
    } //func
    
    var body: some View {
        VStack {
            Text("How much do you want to raise the bet to?")
                .font(.title.bold())
                .padding()
            let amounts = Self.generateIntermediaryAmounts(from: minAmount, to: maxAmount, count: 5)
            HStack {
                Spacer()
                ForEach(amounts, id: \.self) { amount in
                    Button {
                        dismiss()
                        onSubmit?( amount)
                    } label: {
                        Text("\(amount)")
                            .padding(2)
                    } //btn
                    //.padding(4)
                    Spacer()
                } //fe
            } //hs
            Text("or, you can type the value below:")
                .padding(.top)
            TextField("", text: $customChosenBetAmount, prompt: Text("raise the bet to"))
                .keyboardType(.decimalPad)
                .onSubmit {
                    self.submit()
                }//edit
            if isValidAmount( self.customChosenBetAmount) {
                Button {
                    submit()
                } label: {
                    Text( submitTitle )
                        .padding(2)
                } //btn
            }
            else {
                Text( msgForValue)
                    .padding(2)
            }
            Button {
                self.dismiss()
            } label: {
                Text("Back")
                    .padding(2)
            } //btn

        } //vs
        //.padding()
        .overlay(content: {
            RoundedRectangle(cornerRadius: 4, style: .circular)
                .stroke(Color.primary, lineWidth: 1)
        })
        .padding(2)
        .overlay(content: {
            RoundedRectangle(cornerRadius: 6, style: .circular)
                .stroke(Color.primary, lineWidth: 1)
        })
        .background(Color( UIColor.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .circular) )
    } //body
    
    static func new1_getRoundation( for difference: ChipsCountType, intervals: Int) -> ChipsCountType {
        guard intervals >= 1,
              difference / ChipsCountType( intervals) >= 1
        else {
            return 1
        }
        let butLessThan = difference / ChipsCountType( intervals)
        let limits: [(limit: ChipsCountType, round: ChipsCountType)] = [
        (30, 1),
        (150, 5),
        (300, 25),
        //(3000, 50)
        ]
            //.filter({
            //$0.round < butLessThan
        //})
        var weAreAt: ChipsCountType = 1
        for limit in limits {
            if limit.round >= butLessThan {
                return weAreAt
            }
            if difference <= limit.limit {
                return limit.round
            }
            weAreAt = limit.round
        } //for
        //return weAreAt
        return new1_getRoundation(for: difference / 10, intervals: intervals) * 10
    } //func
    static func getRoundationFor(difference: ChipsCountType, intervals: Int ) -> ChipsCountType {
        if difference <= 30 {
            return 1
        }
        if difference <= 100 {
            return 5
        }
        if difference <= 300 {
            return 25
        }
        if difference <= 1000 {
            return 50
        }
        return getRoundationFor( difference: difference / 10, intervals: intervals) * 10
    } //func
    static func generateIntermediaryAmounts(from minAmount: ChipsCountType, to maxAmount: ChipsCountType, count: Int = 5) -> [ChipsCountType] {
        let dif = maxAmount - minAmount
        guard dif >= 0,
              count > 1
        else {
            return []
        } //gua
        let intervals = count - 1
        let increment = Swift.max( dif / ChipsCountType( intervals), ChipsCountType(1))
        var result = Array( stride( from: minAmount, to: maxAmount, by: increment).prefix(intervals) )
        if !result.contains( maxAmount) {
            result.append( maxAmount)
        }
        let roundWith = new1_getRoundation(for: dif, intervals: intervals)
        for i in 1..<result.count - 1 {
            result[i] = result[i].roundedBy(roundWith, .toNearestOrAwayFromZero)
        }
        return result
    } //func
    static func testIntervalGenerator(_ min: ChipsCountType, _ max: ChipsCountType, count: Int = 5) -> Void {
        let ints = generateIntermediaryAmounts(from: min, to: max, count: count)
        let dststr = ints.map({
            "\($0)"
        }).joined(separator: ", ")
        debugMsg_("\(min), \(max)")
        debugMsg_(dststr)
    } //func
    static func testSomeIntervals() -> Void {
        testIntervalGenerator(0, 0)
        testIntervalGenerator(0, 2)
        testIntervalGenerator(2, 10)
        testIntervalGenerator(0, 5)
        testIntervalGenerator(700, 1000)
        testIntervalGenerator(900, 1000)
        testIntervalGenerator(150, 1000)
        testIntervalGenerator(300, 1000)
        testIntervalGenerator(3000, 10000)
    }
} //str

extension ChipsCountType {
    func roundedBy(_ number: Self, _ rule: FloatingPointRoundingRule) -> Self {
        guard number > 1 else {
            return self
        }
        return Self((Double(self) / Double(number)).rounded( rule)) * number
        //return ChipsCountType( Int( self / number) * Int( number) )
    }
} //ext
