//
//  Stage2View.swift
//  CardPlay
//
//  Created by Ionut on 05.11.2021.
//

import SwiftUI
import GameKit

struct Stage2SetupView: View {
    @ObservedObject private var gch = GCHelper.helper
    enum VOFocusable: Hashable {
    case needToSignIn, signingIn
    }
    @AccessibilityFocusState private var firstVOFocus: VOFocusable?
    
    var body: some View {
        VStack {
            switch gch.authenticationState {
            case .authenticated:
                switch gch.userCanPlay {
                case .yes:
                    Stage3MainMenuView()
                default:
                    Text("We are sorry. There are restrictions in your account. This game is not available.")
                } //swi2
            case .unAuthenticated:
                Text("You need to be signed in to Game Center.")
                    .accessibilityFocused($firstVOFocus, equals: .needToSignIn)
                    .onAppear {
                        //self.firstVOFocus = .needToSignIn
                    }
            case .inProgress:
                ProgressView("Signing in to game center.")
                    .accessibilityFocused($firstVOFocus, equals: .signingIn)
                    .onAppear {
                        //self.firstVOFocus = .signingIn
                    }
            } //swi
        } //vs
        .task {
            await gch.beginAuthentication()
        } //task
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                //gch.beginAuthentication()
            } //as
        } //appear
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name.GKPlayerAuthenticationDidChangeNotificationName , object: nil) ) { _ in
            gch.updateAuthd()
        } //rec
    } //body
} //str

