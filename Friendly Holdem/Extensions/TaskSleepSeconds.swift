//
//  TaskSleepSeconds.swift
//  CardPlay
//
//  Created by Ionut on 13.08.2022.
//

import Foundation

extension Task where Success == Never, Failure == Never {
    static func sleep( milliSeconds: Double) async throws -> Void {
        let duration = UInt64(milliSeconds * 1_000_000)
        try await Task.sleep(nanoseconds: duration)
    } //func
    static func sleep( seconds: Double) async throws -> Void {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    } //func
} //ext
