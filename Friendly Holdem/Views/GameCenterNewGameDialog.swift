//
//  myTurnMatcher.swift
//  CardPlay
//
//  Created by Ionut on 06.11.2021.
//

import SwiftUI
import GameKit

struct GameCenterNewGameDialog: UIViewControllerRepresentable {
    let withRequest: GKMatchRequest
    //@Environment(\.presentationMode) var premo
    /*
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
     */
    func makeUIViewController(context: Context) -> GKTurnBasedMatchmakerViewController {
        let ctl = GKTurnBasedMatchmakerViewController( matchRequest: withRequest)
        //ctl.delegate = context.coordinator
        ctl.turnBasedMatchmakerDelegate = GCHelper.helper
        ctl.showExistingMatches = false
        return ctl
    }
    func updateUIViewController(_ uiViewController: GKTurnBasedMatchmakerViewController, context: Context) {
        //
    }
    typealias UIViewControllerType = GKTurnBasedMatchmakerViewController
}
