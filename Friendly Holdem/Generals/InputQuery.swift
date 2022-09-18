//
//  InputQuery.swift
//  CardPlay
//
//  Created by Ionut on 23.11.2021.
//

import SwiftUI

extension String {
    var isInt: Bool {
        (Int(self)) != nil
    } //cv
} //ext
struct InputQuery: View, Identifiable {
    let id = UUID()
    var title: String = "Enter value"
    var hint: String = ""
    var initialValue: String = ""
    var keyboardType: UIKeyboardType = .default
    
    var descriptionProc: ((String) -> String)?
    var validationProc: ((String) -> Bool)?
    var onOkCallback: ((String) -> Void)?
    var okButtonTitle: ((String) -> String)?

    @State private var value = ""
    @Environment(\.presentationMode) private var premo
    func okClick() -> Void {
        if validationProc?(value) ?? true {
            self.premo.wrappedValue.dismiss()
            onOkCallback?(value)
        }
    }
    var body: some View {
        VStack(alignment: .trailing, spacing: 12) {
            HStack {
                Text(title)
                    .font(.title.bold())
                Spacer()
            }
            TextField(hint, text: $value) { isEditing in
                //
            } onCommit: {
                okClick()
            } //edit
            .keyboardType(keyboardType)
            .onAppear {
                value = initialValue
            }
            Text(self.descriptionProc?(self.value) ?? "")
            HStack(alignment: .center, spacing: 12) {
                Button( okButtonTitle?(value) ?? "OK") {
                    okClick()
                } //ok
                .disabled( !( validationProc?(value) ?? true ) )
                .padding()
                Button("Cancel") {
                    self.premo.wrappedValue.dismiss()
                } //canc
                .padding()
            } //hs
            .font(.headline.bold())
        } //vs
    } //body
} //str
