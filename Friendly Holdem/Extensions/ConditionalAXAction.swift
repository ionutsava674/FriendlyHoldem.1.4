//
//  ConditionalAXAction.swift
//  Friendly Holdem
//
//  Created by Ionut on 18.09.2022.
//

import SwiftUI

extension View {
    @ViewBuilder
    func conditionalAddAction( ifHas actionType: PokerPlayerAction.ActionType, in actionMenu: [(PokerPlayerAction, (() -> Void))]) -> some View {
        let found = actionMenu.first(where: { (action, closure) in
            action.type == actionType
        })
                                      if let (realAction, realClosure) = found {
            self
                                              .accessibilityAction(named: Text( realAction.displayName() ), realClosure)
        } else {
            self
        }
    } //func
    
    @ViewBuilder func conditionalAxContent( _ condition: Bool, key: AccessibilityCustomContentKey, contentValue: Text) -> some View {
        if condition {
            self
                .accessibilityCustomContent( key, contentValue)
        } else {
                    self
                }
    } //func
    @ViewBuilder func conditionalAxValue( _ condition: Bool, valueDescription: Text) -> some View {
        if condition {
            self.accessibilityValue(valueDescription)
        } else {
            self
        }
    } //func
    @ViewBuilder func conditionalAxAction( condition: Bool, named: Text, _ closure: @escaping () -> Void) -> some View {
        if condition {
            self
                .accessibilityAction( named: named, closure)
        }
        else {
            self
        }
    }
} //ext
