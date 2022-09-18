//
//  CustomAlignments.swift
//  CardPlay
//
//  Created by Ionut on 24.12.2021.
//

import SwiftUI

extension HorizontalAlignment {
    enum LeadingAlignInForm: AlignmentID {
        static func defaultValue( in dim: ViewDimensions) -> CGFloat {
            return dim[.leading]
        } //func
    } //enum
    enum TrailingAlignInForm: AlignmentID {
        static func defaultValue( in dim: ViewDimensions) -> CGFloat {
            return dim[.trailing]
        } //func
    } //enum
    static let leadingAlignInForm = HorizontalAlignment(LeadingAlignInForm.self)
    static let trailingAlignInForm = HorizontalAlignment(TrailingAlignInForm.self)
} //ext
