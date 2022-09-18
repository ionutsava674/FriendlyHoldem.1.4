//
//  StringExtension.swift
//  CardPlay
//
//  Created by Ionut on 11.12.2021.
//

import SwiftUI

extension Optional where Wrapped == String {
    func toTextOptional() -> Text? {
        if let w = self {
            return Text( w)
        }
        return nil
    } //func
    func toTextOptional(format: String) -> Text? {
        if let w = self {
            return Text( String.localizedStringWithFormat(format, w) )
        }
        return nil
    } //func
} //ext

extension String {
    static let newLine = "\r\n"
    func toText() -> Text {
        Text(self)
    }
} //ext
