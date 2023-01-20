//
//  ContactView.swift
//  Friendly Holdem
//
//  Created by Ionut Sava on 16.01.2023.
//

import SwiftUI
import MessageUI

struct ContactView: View {
    @Binding var isPresented: Bool
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    @State private var showingMail = false

    let gitHubPageUrl = "https://ionutsava674.github.io/FriendlyHoldem.1.4/"
    let appStoreReviewUrl = "https://apps.apple.com/app/id1632308313?action=write-review"
    let mailToAddr = "ionutsava027@gmail.com"
    let mailToName = "Ionut Sava <ionutsava027@gmail.com>"
    let mailSubject = "contacting for Friendly Holdem"
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                Button("Back") {
                    withAnimation {
                        self.isPresented = false
                    }
                } //btn
                .font(.title)
                .padding()
                Spacer()
            } //hs
            Text("Contact")
                .font(.subheadline.bold())
            Text("For suggestions, bugs, critics etc 😅 feel free to drop me an email:")
            Button( self.mailToName) {
                self.showingMail = true
            } //btn
            .disabled( !MFMailComposeViewController.canSendMail())
            Link(destination: URL(string: self.gitHubPageUrl)!) {
                Text("Visit the project website on github")
                    .accessibilityLabel(Text("Visit the project website on github."))
            } //link
            .padding()
            Text("If you enjoy Friendly Holdem, and like the fact that it's free, you can really help out by giving a rating and leaving a good review on the app store.")
            Link(destination: URL(string: self.appStoreReviewUrl)!) {
                Text("rate and review on the app store")
            } //link

        } //vs
            .padding()
            .sheet(isPresented: $showingMail) {
                //
            } content: {
                MailComposerView(result: self.$mailResult, toRecipient: self.mailToAddr, subject: self.mailSubject)
            } //mail
    } //body
} //str
