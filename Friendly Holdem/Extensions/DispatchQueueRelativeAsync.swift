//
//  DispatchQueueExtension.swift
//  CardPlay
//
//  Created by Ionut on 03.07.2022.
//

import Foundation

extension DispatchQueue {
    func relativeAsync( after interval: TimeInterval, code: @escaping () -> Void) -> Void {
        asyncAfter(deadline: .now() + interval, execute: code)
    } //func
} //ext
