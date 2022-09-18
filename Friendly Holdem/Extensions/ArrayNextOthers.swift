//
//  ArrayExtension.swift
//  CardPlay
//
//  Created by Ionut on 10.11.2021.
//

import Foundation
import CoreText
import SwiftUI

extension Array {
    public func nextOthers( ofFirst predicate: (Element) throws -> Bool, includeAtEnd: Bool) rethrows -> [Element]? {
        guard let idx = try firstIndex(where: predicate) else {
            return nil
        } //gua
        return nextOthers( ofi: idx, includeAtEnd: includeAtEnd)
    } //func
    private func nextOthers( ofi arrayIndex: Index, includeAtEnd: Bool) -> [Element]? {
        guard indices.contains( arrayIndex) else {
            return nil
        }
        var rv = Array( self[ arrayIndex + 1 ..< endIndex])
        let stop = includeAtEnd ? arrayIndex + 1 : arrayIndex
        rv.append( contentsOf: Array( self[ startIndex ..< stop]))
        return rv
    } //func
    public func cycleFrom( first predicate: (Element) throws -> Bool)rethrows -> [Element]? {
        guard let idx = try firstIndex(where: predicate) else {
            return nil
        } //gua
        return cycleFrom( arrayIdx: idx)
    } //func
    public func cycleFrom( arrayIdx: Index) -> [Element]? {
        guard indices.contains( arrayIdx) else {
            return nil
        }
        var rv = Array(self[ arrayIdx ..< endIndex])
        rv.append(contentsOf: Array(self[ startIndex ..< arrayIdx]))
        return rv
    } //func
} //ext
