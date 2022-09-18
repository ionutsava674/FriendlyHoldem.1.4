//
//  JumpingTextView.swift
//  Friendly Holdem
//
//  Created by Ionut on 18.09.2022.
//

import SwiftUI

struct JumpingText: View {
    let text: LocalizedStringKey
    let uniqueId: String
    //var animationDuration: Double = 10.0
    var fromScale: Double = 5.0//15.0
    //@State private var needToAnimate = false
    
    var body: some View {
        Text(text)
            //.background(Color.black)
            .onAppear(perform: {
                //self.needToAnimate = true
            })
            .id("\(uniqueId)\(self.text)")
            .transition(.asymmetric(
                insertion: .scale(scale: self.fromScale)
                    //.animation( .easeOut(duration: self.animationDuration))
                    //.applyReduceMotion(reduceMotion: false, allowFade: true)
                ,
                removal: .identity ) )
    } //body
} //str
