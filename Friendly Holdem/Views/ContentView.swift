//
//  ContentView.swift
//  CardPlay
//
//  Created by Ionut on 02.08.2021.
//

import SwiftUI

struct ContentView: View {
    @State private var mainScreen: MainScreenType = .blank
    @AppStorage( wrappedValue: Glop.skipWelcomeScreen.defaultValue, Glop.skipWelcomeScreen.name) private var skipWelcome
    @Environment(\.accessibilityEnabled) var accEna
    var voiceOverEna: Bool { accEna && UIAccessibility.isVoiceOverRunning }
    //@ObservedObject var gameTester: Tester1 = Tester1.getInstance
    //@Namespace var contentTester3NS

    var body: some View {
        ZStack {
        switch mainScreen {
        case .welcome:
            WelcomeView {
                mainScreen = .setup
            }
        case .setup:
            Stage2SetupView()
        default:
            Text("Loading")
            //Test3(game: gameTester.game)
                //.matchedGeometryEffect(id: "test3", in: contentTester3NS)
            //Test2View()
            //ShowdownView(game: gameTester.game)
                .onAppear {
                    //blank below for test
                    DispatchQueue.main.async {
                        mainScreen = skipWelcome ? .setup : .welcome
                    }
                }
        } //swi
        } //zs
    } //body
} //str

enum MainScreenType {
    case blank,
         welcome,
         setup //username etc
}
