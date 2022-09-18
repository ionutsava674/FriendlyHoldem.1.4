//
//  InterText.swift
//  CardPlay
//
//  Created by Ionut on 06.12.2021.
//

import SwiftUI

struct InterText: View, ExpressibleByStringLiteral, ExpressibleByStringInterpolation {
    struct StringInterpolation: StringInterpolationProtocol {
        var output: Text
        init(literalCapacity: Int, interpolationCount: Int) {
            //output.rese
            output = Text("")
        } //init
        mutating func appendInterpolation(_ other: Text) {
            output = output + other
        } //func
        mutating func appendInterpolation(_ param: CustomStringConvertible) {
            output = output + Text( param.description)
        } //func
        mutating func appendLiteral(_ literal: StringLiteralType) {
            output = output + Text( literal)
        } //func
    } //n str
    let description: Text
    init(stringInterpolation: StringInterpolation) {
        description = stringInterpolation.output
    } //init
    init(stringLiteral value: StringLiteralType) {
        description = Text(value)
    } //init
    var body: some View {
        description
    }
}
