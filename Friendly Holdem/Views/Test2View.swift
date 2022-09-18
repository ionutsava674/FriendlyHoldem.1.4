//
//  Test2View.swift
//  CardPlay
//
//  Created by Ionut on 10.07.2022.
//

import SwiftUI

struct Test2View: View {

    @State private var totch = 0
    @State private var rad: Bool = false
    @Namespace var tnsid
    var body: some View {
        VStack {
            /*
            Text("\(totch)")
                //.matchedGeometryEffect(id: "lalala", in: tnsid)
                .id("lalala\(self.totch)")
                //.font(.system(size: 160))
                .transition(.asymmetric(
                    insertion: .scale(scale: 10.0).animation(.easeOut(duration: 1.0) ).applyReduceMotion(reduceMotion: rad, allowFade: true),
                    removal: .identity ) )
             */
            JumpingText(text: "\(self.totch)", uniqueId: "lalala")
                .id("lalala")
            Button("inc") {
                self.totch += 5
            }
            Button("rad: \(self.rad.description)") {
                self.rad.toggle()
            }
        } //vs
    } //body
} //str

struct Test2View_Previews: PreviewProvider {
    static var previews: some View {
        Test2View()
    }
}
