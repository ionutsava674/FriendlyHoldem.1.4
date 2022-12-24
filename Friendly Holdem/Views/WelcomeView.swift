//
//  WelcomeView.swift
//  CardPlay
//
//  Created by Ionut on 20.09.2021.
//

import SwiftUI
import CoreMotion

struct WelcomeView: View {
    //@AppStorage( wrappedValue: Glop.skipWelcomeScreen.defaultValue, Glop.skipWelcomeScreen.name) private var skipWelcome
    @ObservedObject private var glop = GlobalPreferences2.global
    @StateObject private var motion = MotionManager.getInstance

    var whenClickedContinue: (() -> Void)?
    static let bg1: Color = Color.gray.bright(amount: 0.45)
    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            GeometryReader {geo in
                VStack(alignment: .center, spacing: 12) {
                    //Text("\(motion.yaw_y)")
                    Text("Welcome to friendly hold'em.")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                        .padding()
                    Text("Your very accessible game of Texas Hold'em")
                        .font(.title.bold())
                        .multilineTextAlignment(.center)
                        .padding()
                } //vs
                .accessibilityElement(children: .combine)
                .background(Self.bg1)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                //.roundedDoubleBorder(.white, radius: 20, lineWidth: 6, withBackground: .black)
                .overlay(content: {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white, lineWidth: 3)
                })
                .rotation3DEffect(.radians(motion.pitch_x), axis: (x: 1.0, y: 0.0, z: 0.0))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } //geo
            Toggle("Skip this intro from now on", isOn: self.$glop.skipWelcome)
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
        .onAppear {
            motion.registerView()
        } //onapp
        .onDisappear {
            motion.unregisterView()
        }
    } //body
} //str

class MotionManager: ObservableObject {
    static let getInstance = MotionManager()
    
    private let motionManager = CMMotionManager()
    private var registeredViewCount = 0
    @Published var roll_z = 0.0
    @Published var pitch_x = 0.0
    @Published var yaw_y = 0.0
    
    private init () {
        motionManager.deviceMotionUpdateInterval = 1 / 25
    } //init
    func unregisterView() -> Void {
        registeredViewCount -= 1
        print("unreg \(registeredViewCount)")
        guard registeredViewCount == 0 else {
            return
        } //gua
        motionManager.stopDeviceMotionUpdates()
    } //func
    func registerView() -> Void {
        registeredViewCount += 1
        print("reg \(registeredViewCount)")
        guard registeredViewCount == 1 else {
            return
        } //gua
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
            guard let motion = data?.attitude else {
                return
            } //gua
            self?.roll_z = motion.roll
            self?.pitch_x = motion.pitch
            self?.yaw_y = motion.yaw
        } //clo
    } //func
} //cl
