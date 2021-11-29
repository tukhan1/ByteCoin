//
//  CoinModel.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 04.10.2021.
//

import Foundation

struct CoinModel {
    let currancy: String
    let price: Double
    
    var priceString: String {
        return String(format: "%.2f", price)
    }
}



