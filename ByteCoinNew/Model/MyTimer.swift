//
//  MyTimer.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 18.01.2022.
//

import Foundation

class MyTimer {
    private var timer = Timer()
    
    func updateCoinPriceEvery(seconds: Double, with closure: @escaping () -> Void) {
        timer.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: true) { _ in
            closure()
        }
    }
    
    deinit {
        timer.invalidate()
    }
}
