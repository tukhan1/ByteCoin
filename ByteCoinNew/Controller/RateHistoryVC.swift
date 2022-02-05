//
//  RateHistoryVC.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 27.01.2022.
//

import UIKit
import SnapKit

class RateHistoryVC: UIViewController {
    
    private let coinManager = CoinManager()
    var currency = "RUB"
    var cryptoCurrency = "BTC"
    var date = ""
    private var historyData: [TimeseriesData] = []
    
    private let tableView: UITableView = UITableView(frame: .zero, style: .plain)
    private let headerView: UIView = UIView(frame: .zero)
    private let cancelButton: UIButton = UIButton(frame: .zero)
    private let titleLabel: UILabel = UILabel(frame: .zero)
    private let imageForButton: UIImageView = UIImageView(frame: .zero)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(date)
        coinManager.historyPricePerHourFor(cryptocurrency: cryptoCurrency, to: currency, timeStart: CoinModel.dateDayBefore(date), timeEnd: date) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let history):
                self.historyData = history.reversed()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "\(currency)/\(cryptoCurrency)"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.backButtonClicked))
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { maker in
            maker.top.equalTo(view.snp.top)
            maker.left.equalTo(view.snp.left)
            maker.right.equalTo(view.snp.right)
            maker.bottom.equalTo(view.snp.bottom)
        }
        view.backgroundColor = .white
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(RateHisroryVCCell.self)
    }
    
    @objc func backButtonClicked() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}

extension RateHistoryVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return historyData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(type: RateHisroryVCCell.self, for: indexPath)
        cell.configuration(time: historyData[indexPath.row].timeOpen,
                           rate: historyData[indexPath.row].rateOpen,
                           designation: currency)
        return cell
    }
}

private class RateHisroryVCCell: UITableViewCell, TableCell {
    static let identifier = "\(RateHisroryVCCell.self)"
    
    private let timeLabel: UILabel = UILabel(frame: .zero)
    private let dateLabel: UILabel = UILabel(frame: .zero)
    private let viewForTime: UIView = UIView(frame: .zero)
    private let coinRateLabel: UILabel = UILabel(frame: .zero)
    private let currencyDesignationLabel: UILabel = UILabel(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(viewForTime)
        viewForTime.addSubview(timeLabel)
        viewForTime.addSubview(dateLabel)
        contentView.addSubview(coinRateLabel)
        contentView.addSubview(currencyDesignationLabel)
        
        viewForTime.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        coinRateLabel.translatesAutoresizingMaskIntoConstraints = false
        currencyDesignationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        viewForTime.snp.makeConstraints { maker in
            maker.left.equalTo(contentView.snp.left).offset(10.0)
            maker.centerY.equalTo(contentView.snp.centerY)
            maker.width.equalTo(contentView.snp.width).multipliedBy(0.3)
        }
        timeLabel.snp.makeConstraints { maker in
            maker.height.equalTo(viewForTime.snp.height).multipliedBy(0.5)
            maker.top.equalTo(viewForTime.snp.top)
            maker.left.equalTo(viewForTime.snp.left)
            maker.right.equalTo(viewForTime.snp.right)
        }
        dateLabel.snp.makeConstraints { maker in
            maker.height.equalTo(viewForTime.snp.height).multipliedBy(0.5)
            maker.bottom.equalTo(viewForTime.snp.bottom)
            maker.top.equalTo(timeLabel.snp.bottom)
            maker.left.equalTo(viewForTime.snp.left)
            maker.right.equalTo(viewForTime.snp.right)
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
        dateLabel.textAlignment = .center
        dateLabel.adjustsFontSizeToFitWidth = true
        timeLabel.textAlignment = .center
        coinRateLabel.textAlignment = .right
        currencyDesignationLabel.textAlignment = .left
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configuration(time: String, rate: Double, designation: String) {
        timeLabel.text = time.components(separatedBy: "T")[0]
        dateLabel.text = time.components(separatedBy: "T")[1].components(separatedBy: ".")[0]
        coinRateLabel.text = String(format: "%.2f", rate)
        currencyDesignationLabel.text = designation
    }
}
