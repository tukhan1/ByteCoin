//
//  CoinModel.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 12.01.2022.
//

import Foundation

struct CoinModel {
    let date: String
    let currency: String
    let price: Double
    
    static func dateDayBefore(_ value: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let date = dateFormatter.date(from: value) {
            let dayBefore = date.addingTimeInterval(-86400.0)
            return dateFormatter.string(from: dayBefore)
        } else {
            return "There was an error decoding the string"
        }
    }
}
