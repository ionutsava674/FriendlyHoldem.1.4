//
//  DebugView.swift
//  CardPlay
//
//  Created by Ionut on 11.11.2021.
//

import SwiftUI
import GameKit

#if DEBUG
let debugHeaderRow = true
let debugBuffer = true
#endif

#if DEBUG
struct DebugView: View {
    @ObservedObject var gch = GCHelper.helper
    @Environment(\.presentationMode) var premo
    var body: some View {
        VStack {
            TextEditor(text: self.$gch.outMsg)
            Button("clear debug lines") {
                gch.outMsg = ""
                premo.wrappedValue.dismiss()
            } //btn
        } //vs
    } //body
} //str
#endif
func gdebug(_ msg: String) -> Bool {
    debugMsg_(msg)
    return true
} //func
func debugMsg_(_ msg: String) {
    guard debugBuffer else {
        return
    }
    print( msg)
    GCHelper.helper.outMsg += String.newLine + msg
} //msg func

extension GKTurnBasedMatch {
    func printOutcomes() -> String {
        "outcomes " + participants.map({ "\($0.matchOutcome.rawValue)" }).joined(separator: " ")
    } //func
    func printIfJoining( in game: HoldemGame) -> String {
        "joining " + game.allPlayers.map({ "\($0.joiningGame ? 1 : 0)" }).joined(separator: " ")
    } //func
    func printInitials() -> String {
        "names " + participants.map({ "\($0.player?.alias.prefix(1) ?? "-")" }).joined(separator: " ")
    } //func
    func printExchanges() -> String {
        let exC = exchanges?.count ?? -1
        let acC = activeExchanges?.count ?? -1
        let comC = completedExchanges?.count ?? -1
        return "exchanges: \(exC), \(acC), \(comC)"
    } //func
    func printMsg() -> String {
        message ?? "no message"
    }
} //ext
