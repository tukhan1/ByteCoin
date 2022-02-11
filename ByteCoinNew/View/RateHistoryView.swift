//
//  RateHistoryView.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 09.02.2022.
//

import UIKit

class RateHistoryView: UIView {
    
    private let headerView: UIView = UIView(frame: .zero)
    let tableView: UITableView = UITableView(frame: .zero, style: .plain)
    
    func configureView() {
        self.addSubview(tableView)
        self.backgroundColor = .white
        tableView.backgroundColor = .white
    }

    func makeConstraints() {
        tableView.snp.makeConstraints { maker in
            maker.top.equalTo(self.snp.top)
            maker.left.equalTo(self.snp.left)
            maker.right.equalTo(self.snp.right)
            maker.bottom.equalTo(self.snp.bottom)
        }
    }
}
