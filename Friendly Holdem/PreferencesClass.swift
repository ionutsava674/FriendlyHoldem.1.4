//
//  PreferencesClass.swift
//  Tab Extractor
//
//  Created by Ionut on 25.06.2021.
//

import Foundation
import SwiftUI

enum GlobalPreferences {
    static let skipWelcomeScreen = P<Bool>(name: "skipWelcome", defaultValue: false)
    
    struct P<T> {
        let name: String
        let defaultValue: T
    } //str
}
typealias GlopOld = GlobalPreferences

class GlobalPreferences2: ObservableObject {
    @AppStorage("skipWelcome") var skipWelcome = false
    
    static let global = GlobalPreferences2()
    
    func restoreDefaults() -> Void {
        skipWelcome = false
    } //func
} //class
