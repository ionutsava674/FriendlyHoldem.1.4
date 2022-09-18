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
typealias Glop = GlobalPreferences

