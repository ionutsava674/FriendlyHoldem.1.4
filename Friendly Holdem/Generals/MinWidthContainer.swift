//
//  MinWidthContainer.swift
//  CardPlay
//
//  Created by Ionut on 12.12.2021.
//

import SwiftUI

struct LeastWidthContainer<ContentType: View>: View {
    let content: (CGFloat?) -> ContentType
    @State private var leastWidth: CGFloat? = nil
    //@StateObject private var valueContainer: LeastWidthValueContainer = LeastWidthValueContainer()
    
    var body: some View {
        Group {
            content(leastWidth)
        } //gr
        .frame(width: leastWidth)
        .background(GeometryReader { geo in
            Color.clear
                .preference(key: LeastWidthKey.self, value: geo.size.width)
        }) //bg
        .onPreferenceChange(LeastWidthKey.self, perform: { changedValue in
            self.leastWidth = changedValue
            // self.valueContainer.width = changedValue
        }) //prefCh
    } //body
} //str
class LeastWidthValueContainer: ObservableObject {
    var width: CGFloat = 0
} //cl
extension View {
    func fitToWidth(_ leastWidth: CGFloat?) -> some View {
        return self
            .frame(maxWidth: leastWidth == nil ? nil : .infinity)
    }
}
struct LeastWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        let nv = nextValue()
        print(value, nv)
        //value = nv
        value = max( value, nv)
    } //func
} //str

