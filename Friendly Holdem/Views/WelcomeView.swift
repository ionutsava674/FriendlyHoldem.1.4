//
//  WelcomeView.swift
//  CardPlay
//
//  Created by Ionut on 20.09.2021.
//

import SwiftUI

struct WelcomeView: View {
    //@AppStorage( wrappedValue: Glop.skipWelcomeScreen.defaultValue, Glop.skipWelcomeScreen.name) private var skipWelcome
    @ObservedObject private var glop = GlobalPreferences2.global

    var whenClickedContinue: (() -> Void)?
    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            GeometryReader {geo in
                VStack(alignment: .center, spacing: 12) {
                    Text("Welcome to friendly hold'em.")
                        .font(.largeTitle.bold())
                    Text("Your very accessible game of Texas Hold'em")
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                    //Text("Welcome to friendly hold'em. Your very accessible game of Texas Hold'em")
                        //.font(.title.bold())
                } //vs
                .accessibilityElement(children: .combine)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } //geo
            Toggle("Don't show this again", isOn: self.$glop.skipWelcome)
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
