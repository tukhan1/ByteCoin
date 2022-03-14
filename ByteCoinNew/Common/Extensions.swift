//
//  Extensions.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 17.02.2022.
//

import Foundation

extension DateFormatter {
    static let apiFormat: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        return dateFormatter
    }()
}
