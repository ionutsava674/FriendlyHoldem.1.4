//
//  PaddedButton.swift
//  CardPlay
//
//  Created by Ionut on 24.12.2021.
//

import SwiftUI

struct PaddedButton:View {
    var text: String
    var internalPadding: CGFloat?
    var onClick: (() -> Void)?
    
    var body: some View {
        Button(action: {
            onClick?()
        }, label: {
            Text(text)
                .padding( .all, internalPadding)
        })
    } //body
} //str

struct PaddedButton_Previews: PreviewProvider {
    static var previews: some View {
        PaddedButton(text: "hello button", onClick: nil)
    }
}
