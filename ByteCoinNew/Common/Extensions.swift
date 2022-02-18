//
//  Extensions.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 17.02.2022.
//

import Foundation

extension Date {
    func getDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: self)
    }

    func getTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: self)
    }
}

extension String {
    func getNDaysBefore(N number: Double) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.confirmToApiFormat()
        
        if let date = dateFormatter.date(from: self) {
            let nDaysBefore = date.addingTimeInterval(-86400.0 * number)
            return dateFormatter.string(from: nDaysBefore)
        } else {
            return "There was an error decoding the string"
        }
    }

    func transformStringToDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.confirmToApiFormat()
        
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return Date()
        }
    }
}

extension DateFormatter {
    func confirmToApiFormat() {
        self.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'"
        self.timeZone = TimeZone(secondsFromGMT: 0)
    }
}
