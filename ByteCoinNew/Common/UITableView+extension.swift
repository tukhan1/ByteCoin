//
//  UITableView+extension.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 09.02.2022.
//

import UIKit

protocol TableCell: AnyObject {
    static var identifier: String { get }
}

extension UITableView {
    func register<T: TableCell>(_ type: T.Type) {
        self.register(type, forCellReuseIdentifier: type.identifier)
    }
    
    func dequeueReusableCell<T: TableCell>(type: T.Type, for indexPath: IndexPath) -> T {
        self.dequeueReusableCell(withIdentifier: type.identifier, for: indexPath) as! T
    }
}
