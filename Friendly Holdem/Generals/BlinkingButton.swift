//
//  BlinkingButton.swift
//  CardPlay
//
//  Created by Ionut on 27.09.2021.
//

import SwiftUI

struct BlinkingButton: View {
    @State private var flashing = false
    
    var back1: Color = Color( red: 0.7, green: 0, blue: 0)
        var back2: Color = .orange
    var fore1: Color = .white
    var fore2: Color = .black
    var animDuration: Double = 1
    var autoStart = true
    
    var body: some View {
        Button("Take action") {
            flashing.toggle()
        }
        .padding(8)
        .font(.largeTitle)
        //.animation( nil)
        .foregroundColor(.white)
        //.colorMultiply( foreColors[ curColorIndex])
        .colorMultiply( flashing ? fore2 : fore1)
        .background( flashing ? back2 : back1)
        //.background( colors[ curColorIndex])
        .animation( flashing ?
                    Animation.easeInOut(duration: animDuration).repeatForever( autoreverses:  true)
                    : .default, value: flashing)
        .clipShape(
            RoundedRectangle(cornerRadius: 10)
        )
        .onAppear {
            flashing = autoStart
        }
        //.animation( nil)
    } //body
} //str
