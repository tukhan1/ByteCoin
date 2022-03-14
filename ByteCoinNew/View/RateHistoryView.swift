//
//  RateHistoryView.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 09.02.2022.
//

import UIKit
import SnapKit

class RateHistoryView: UIView {
    var historyData: [[HistoryData]] = []
    var currency: String = ""
    
    let tableView: UITableView = UITableView(frame: .zero, style: .plain)
    
    private let headerView: UIView = UIView(frame: .zero)
    
    func commonInit() {
        configureView()
        makeConstraints()
        tableView.dataSource = self
        tableView.register(RateHisroryVCCell.self)
    }
    
    func updateUI(with data: [[HistoryData]], for currency: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.historyData = data
            self.currency = currency
            self.tableView.reloadData()
        }
    }
    
    private func configureView() {
        self.addSubview(tableView)
        self.backgroundColor = .white
        tableView.backgroundColor = .white
    }

    private func makeConstraints() {
        tableView.snp.makeConstraints { maker in
            maker.top.equalTo(self.snp.top)
            maker.left.equalTo(self.snp.left)
            maker.right.equalTo(self.snp.right)
            maker.bottom.equalTo(self.snp.bottom)
        }
    }
}

extension RateHistoryView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyData[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return historyData[section][0].timeOpen.getDate()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return historyData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(type: RateHisroryVCCell.self, for: indexPath)
        cell.configuration(date: historyData[indexPath.section][indexPath.row].timeOpen,
                           rate: historyData[indexPath.section][indexPath.row].rateOpen,
                           designation: currency)
        return cell
    }
}

private class RateHisroryVCCell: UITableViewCell, TableCell {
    static let identifier = "\(RateHisroryVCCell.self)"
    
    private let timeLabel: UILabel = UILabel(frame: .zero)
    private let coinRateLabel: UILabel = UILabel(frame: .zero)
    private let currencyDesignationLabel: UILabel = UILabel(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configuration(date: Date, rate: Double, designation: String) {
        timeLabel.text = date.getTime()
        coinRateLabel.text = String(format: "%.2f", rate)
        currencyDesignationLabel.text = designation
    }
    
    private func configureView() {
        contentView.addSubview(timeLabel)
        contentView.addSubview(coinRateLabel)
        contentView.addSubview(currencyDesignationLabel)
        
        timeLabel.textAlignment = .left
        coinRateLabel.textAlignment = .right
        currencyDesignationLabel.textAlignment = .left
    }
    
    private func makeConstraints() {
        timeLabel.snp.makeConstraints { maker in
            maker.top.equalTo(contentView.snp.top)
            maker.left.equalTo(contentView.snp.left).offset(10.0)
            maker.centerY.equalTo(contentView.snp.centerY)
            maker.width.equalTo(contentView.snp.width).multipliedBy(0.2)
        }
        coinRateLabel.snp.makeConstraints { maker in
            maker.left.equalTo(timeLabel.snp.right).offset(10.0)
            maker.centerY.equalTo(contentView.snp.centerY)
        }
        currencyDesignationLabel.snp.makeConstraints { maker in
            maker.right.equalTo(contentView.snp.right).inset(10.0)
            maker.left.equalTo(coinRateLabel.snp.right).offset(10.0)
            maker.centerY.equalTo(contentView.snp.centerY)
            maker.width.equalTo(50.0)
        }
    }
}

private extension Date {
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
