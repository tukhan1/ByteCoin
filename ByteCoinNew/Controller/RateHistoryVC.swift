//
//  RateHistoryVC.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 27.01.2022.
//

import UIKit
import SnapKit

class RateHistoryVC: UIViewController {

    private let coinManager: CoinProtocol
    var currency = "RUB"
    var cryptoCurrency = "BTC"
    var date: String = ""
    private var historyData: [HistoryData] = []
    
    init(coinManager: CoinProtocol) {
        self.coinManager = coinManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let rateHistoryView: RateHistoryView = RateHistoryView(frame: UIScreen.main.bounds)
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.addSubview(rateHistoryView)
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print(date)
        updateHistoryPricePerHour()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "\(currency)/\(cryptoCurrency)"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.backButtonClicked))

        rateHistoryView.tableView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func updateHistoryPricePerHour() {
        coinManager.getHistoryPricePerHour(for: cryptoCurrency,
                                              to: currency,
                                              timeEnd: date) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let history):
                DispatchQueue.main.async {
                    self.historyData = history.reversed()
                    self.rateHistoryView.tableView.reloadData()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Error", message: error.rawValue, preferredStyle: .alert)
                    let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }

    @objc func backButtonClicked() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}

private extension RateHistoryVC {
    func configure() {
        rateHistoryView.configureView()
        rateHistoryView.makeConstraints()
        rateHistoryView.tableView.delegate = self
        rateHistoryView.tableView.dataSource = self
        rateHistoryView.tableView.register(RateHisroryVCCell.self)
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
        cell.configuration(date: historyData[indexPath.row].timeOpen,
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
        configureView()
        makeConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configuration(date: Date, rate: Double, designation: String) {
        timeLabel.text = getTime(date)
        dateLabel.text = getDate(date)
        coinRateLabel.text = String(format: "%.2f", rate)
        currencyDesignationLabel.text = designation
    }
    private func getTime(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
    private func getDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }

    private func configureView() {
        contentView.addSubview(viewForTime)
        viewForTime.addSubview(timeLabel)
        viewForTime.addSubview(dateLabel)
        contentView.addSubview(coinRateLabel)
        contentView.addSubview(currencyDesignationLabel)
        
        dateLabel.textAlignment = .center
        dateLabel.adjustsFontSizeToFitWidth = true
        timeLabel.textAlignment = .center
        coinRateLabel.textAlignment = .right
        currencyDesignationLabel.textAlignment = .left
    }

    private func makeConstraints() {
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
    }
}
