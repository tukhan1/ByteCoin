//
//  MyTimer.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 18.01.2022.
//

import Foundation

class MyTimer {
    private var closure: () -> Void
    private var seconds: Double
    private var workItem: DispatchWorkItem?
    
    init (seconds: Double, closure: @escaping () -> Void) {
        self.seconds = seconds
        self.closure = closure
    }
    
    deinit {
        self.workItem?.cancel()
    }
    
    func performAction() {
        workItem = DispatchWorkItem { [weak self] in
            self?.closure()
            self?.performAction()
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + seconds, execute: workItem!)
    }
}
