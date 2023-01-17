//
//  MailComposer.swift
//  Tab Extractor
//
//  Created by Ionut on 19.02.2022.
//

import SwiftUI
import UIKit
import MessageUI

struct MailComposerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = MFMailComposeViewController
    
    @Environment(\.presentationMode) var premo
    @Binding var result: Result<MFMailComposeResult, Error>?
    let toRecipient: String
    let subject: String
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(premo: premo, result: $result)
    } //func
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients([toRecipient])
        vc.setSubject(subject)
        return vc
    } //func
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        //
    } //func
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var premo: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?
        init(premo: Binding<PresentationMode>, result: Binding<Result<MFMailComposeResult, Error>?>) {
            self._premo = premo
            self._result = result
        } //init
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            if let err = error {
                self.result = .failure(err)
                $premo.wrappedValue.dismiss()
                return
            }
            self.result = .success(result)
            $premo.wrappedValue.dismiss()
        } //func
    } //class
} //str
