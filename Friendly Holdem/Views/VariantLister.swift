//
//  VariantLister.swift
//  CardPlay
//
//  Created by Ionut on 24.06.2022.
//

import SwiftUI

struct GSPLister: View {
    var gspVariants: [GameStartParameters]
    var onClick: ((GameStartParameters) -> Void)?
    //let columns:[GridItem] = Array(repeating: GridItem(.flexible(minimum: 10, maximum: 800), spacing: 10, alignment: .leading) , count: 2)
    func composedText( c: ChipsCountType, s: ChipsCountType, b: ChipsCountType, m: ChipsCountType) -> InterText {
        let i1 = Text("\(c)").font(.body.bold())
        let i2 = Text("\(s)").font(.body.bold())
        let i3 = Text("\(b)").font(.body.bold())
        let i4 = Text("\(m)").font(.body.bold())
        let r = InterText("""
starting with \(i1) chips,
small and big of:  \(i2) and \(i3),
and minimum raise of  \(i4).
""")
        return r
        //return t1 + i1 + t2 + i2 + t3 + i3 + t4 + i4 + t5
    } //func
    @ViewBuilder func composedText3( index: Int, c: ChipsCountType, s: ChipsCountType, b: ChipsCountType, m: ChipsCountType) -> some View {
        let tc: Text = Text("\(c)").font(.body.bold())
        let ts: Text = Text("\(s)").font(.body.bold())
        let tb: Text = Text("\(b)").font(.body.bold())
        let tm: Text = Text("\(m)").font(.body.bold())
        VStack(alignment: .leading, spacing: 1) {
            //Text( String.localizedStringWithFormat(NSLocalizedString("Proposal %lld:", comment: ""), index))
            Text( "Proposal \("\(index)"):")
            //Text("each player starts with ") + Text("\(c)").font(.body.bold()) + Text(" chips")
            Text("each player starts with \( tc ) chips")
            //Text("small and big blind:  ") + Text("\(s)").font(.body.bold()) + Text(" and ") + Text("\(b)").font(.body.bold())
            Text("small and big blind:  \( ts ) and \( tb ),")
            //Text("and minimum raise of  ") + Text("\(m)").font(.body.bold())
            Text("and minimum raise of  \( tm )")
        } //vs
        .accessibilityElement(children: .combine)
    } //func
    func composedText2( index: Int, c: ChipsCountType, s: ChipsCountType, b: ChipsCountType, m: ChipsCountType) -> InterText {
        let i1 = Text("\(c)").font(.body.bold())
        let i2 = Text("\(s)").font(.body.bold())
        let i3 = Text("\(b)").font(.body.bold())
        let i4 = Text("\(m)").font(.body.bold())
        let r = InterText( """
Proposal \(index):
each player starts with \(i1) chips,
small and big blind:  \(i2) and \(i3),
and minimum raise of  \(i4).
""")
        return r
        //return t1 + i1 + t2 + i2 + t3 + i3 + t4 + i4 + t5
    } //func
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            if !gspVariants.isEmpty {
                Text("Select from below a game structure that has been proposed")
                    .font(.headline)
                    .padding(4)
            } //if
        VStack(alignment: .leading, spacing: 10) {
            ForEach( Array( gspVariants.enumerated()), id: \.element.self) { (index, variant) in
            //ForEach( gspVariants, id: \.self) { variant in
                composedText3( index: index + 1, c: variant.startChips, s: variant.smallBlind, b: variant.bigBlind, m: variant.minRaiseAmount)
                    .padding(8)
                    .overlay(content: {
                        RoundedRectangle(cornerRadius: 4, style: .circular)
                            .stroke( .secondary, lineWidth: 1)
                    })
                    //.background(.red)
                    .background(Color(UIColor.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 4, style: .circular) )
                    // .border(Color(UIColor.opaqueSeparator))
                    //.border( .secondary)
                    .accessibilityAddTraits(.isButton)
                    .onTapGesture {
                        onClick?(variant)
                    }
                    //.padding(.horizontal, 4)
            } //fe
        } //vs
        } //vs
    } //body
} //str
