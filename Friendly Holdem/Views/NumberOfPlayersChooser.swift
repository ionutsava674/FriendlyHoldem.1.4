//
//  NumberOfPlayersChooser.swift
//  CardPlay
//
//  Created by Ionut on 17.06.2022.
//

import SwiftUI

struct NumberOfPlayersChooser: View {
    let title: String
    @Binding var isPresented: Bool
    var onSelected: ((Int) -> Void)?
    let nsID: Namespace.ID

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(title)
                .font(.title)
                .matchedGeometryEffect(id: "dialogTitle", in: self.nsID)
                .padding()
            Text("How many players?")
                .font(.headline)
            HStack(alignment: .center, spacing: 10) {
                ForEach(2..<9, id: \.self) { nop in
                    Button("\(nop)", action: {
                        self.isPresented = false
                        self.onSelected?(nop)
                    }) //btn
                } //fe
                Button("Cancel") {
                    self.isPresented = false
                } //btn
            } //hs
            .font(.headline)
        } //vs
    } //body
} //str

