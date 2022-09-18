//
//  OptionalExtension.swift
//  CardPlay
//
//  Created by Ionut on 26.11.2021.
//

import Foundation
import SwiftUI
import CoreMedia

extension Optional/* where Wrapped: CustomStringConvertible*/ {
    var toStringOptional: String? {
        if let unwrapped = self {
            return "\(unwrapped)"
        }
        return nil
    } //func
} //ext
