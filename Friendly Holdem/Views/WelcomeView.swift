//
//  WelcomeView.swift
//  CardPlay
//
//  Created by Ionut on 20.09.2021.
//

import SwiftUI

struct WelcomeView: View {
    @AppStorage( wrappedValue: Glop.skipWelcomeScreen.defaultValue, Glop.skipWelcomeScreen.name) private var skipWelcome
    var whenClickedContinue: (() -> Void)?
    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            /*
            if bbv {
                BlinkingButton( back1: Color.init( red: 0, green: 0.4, blue: 0), back2: .yellow, animDuration: 0.6 )
            }
             */
            Text("Welcome to friendly hold'em. Your very accessible game of Texas Hold'em")
                .font(.title.bold())
            Toggle("Don't show this again", isOn: self.$skipWelcome)
                .font(.title)
            Button {
                self.whenClickedContinue?()
                //bbv.toggle()
            } label: {
                Text("Next")
                    .font(.largeTitle)
                    .padding()
            } //btn

        } //vs
    } //body
}
