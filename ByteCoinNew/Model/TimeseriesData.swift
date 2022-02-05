//
//  TimeseriesData.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 04.02.2022.
//

import Foundation

struct TimeseriesData: Decodable {
    var timeOpen: String
    var rateOpen: Double
    
    enum CodingKeys: String, CodingKey {
        case timeOpen = "time_open"
        case rateOpen = "rate_open"
    }
}
