//
//  groupedAsync.swift
//  CardPlay
//
//  Created by Ionut on 23.09.2021.
//

import Foundation

class GroupedAsync {
    private var itemsCount: Int = 0
    private var doneCount: Int = 0
    private var onFinish: (() -> Void)?
    
    func setOnFinish(onFinish: @escaping () -> Void) -> Void {
        self.onFinish = onFinish
    }
    func asyncInMain(deadline: DispatchTime, work: @escaping () -> Void) -> Void {
        itemsCount += 1
        DispatchQueue.main.asyncAfter(deadline: deadline) {
            self.doneCount += 1
            work()
            if self.itemsCount == self.doneCount {
                //print("done")
                self.onFinish?()
            }
        }
    } //func
    /*
    deinit {
        print("imout")
    }
 */
} //ga
