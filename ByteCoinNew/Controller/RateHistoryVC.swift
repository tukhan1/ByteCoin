//
//  RateHistoryVC.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 27.01.2022.
//

import UIKit

class RateHistoryVC: UIViewController {
    var currency = "RUB"
    var cryptoCurrency = "BTC"
    var date: String = ""
    
    private let rateHistoryView: RateHistoryView = RateHistoryView(frame: UIScreen.main.bounds)
    private let coinManager: CoinProtocol
    
    init(coinManager: CoinProtocol) {
        self.coinManager = coinManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateHistoryPricePerHour()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    private func updateHistoryPricePerHour() {
        coinManager.getHistoryPricePerHour(for: cryptoCurrency,
                                              to: currency,
                                              timeEnd: date) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                switch result {
                case .success(let history):
                    let data = self.sortDataByDate(history)
                    self.rateHistoryView.updateUI(with: data.reversed(), for: self.currency)
                case .failure(let error):
                    self.didFailWithError(error)
                }
            }
        }
    }
    
    private func sortDataByDate(_ data: [HistoryData]) -> [[HistoryData]] {
        var array: [[HistoryData]] = []
        var prevDate: String = ""
        data.forEach { rate in
            if rate.timeOpen.getDate() != prevDate {
                prevDate = rate.timeOpen.getDate()
                array.append([])
            }
            array[array.count - 1].append(HistoryData(timeOpen: rate.timeOpen, rateOpen: rate.rateOpen))
        } //split
        return array
    }
    
    private func didFailWithError(_ error: NWError) {
            let alert = UIAlertController(title: "Error", message: error.rawValue, preferredStyle: .alert)
            let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
            alert.addAction(action)
        
            self.present(alert, animated: true, completion: nil)
    }
    
    @objc func backButtonClicked() {
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}

private extension RateHistoryVC {
    func configure() {
        view.addSubview(rateHistoryView)
        rateHistoryView.commonInit()
        
        self.title = "\(currency)/\(cryptoCurrency)"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.backButtonClicked))

        rateHistoryView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }

        rateHistoryView.tableView.delegate = self
    }
}

extension RateHistoryVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
