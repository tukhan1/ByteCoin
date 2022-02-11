//
//  CoinRateVC.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 24.01.2022.
//

import Foundation
import UIKit

class CoinRateVC: UIViewController {
    
    private let coinManager: CoinProtocol
    var currency: String = "USD" {
        willSet(newCurrency) {
            self.coinRateView.currency = newCurrency
        }
    }
    var date: String = ""
    private var cryptoCyrrency = "BTC"
    private var cryptoCurrencies: [String] = []
    private lazy var timer = MyTimer(seconds: 60) { [weak self] in
        self?.updateCurrentCoinPrice()
    }
    private let coinRateView: CoinRateView = CoinRateView(frame: UIScreen.main.bounds)
    
    init(coinManager: CoinProtocol) {
        self.coinManager = coinManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.addSubview(coinRateView)
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        coinRateView.coinLabel.text = currency
        updateCurrentCoinPrice()
        timer.performAction()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.cryptoCurrencies = coinManager.cryptoCurrencies
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(showHistory))
        coinRateView.coinView.addGestureRecognizer(gesture)
    }
    
    func updateCurrentCoinPrice() {
        coinManager.getCoinPrice(for: currency, to: cryptoCyrrency) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let data):
                self.didUpdatePrice(from: data)
            case .failure(let error):
                self.didFailWithError(error)
            }
        }
    }
    
    private func didFailWithError(_ error: NWError) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: error.rawValue, preferredStyle: .alert)
            let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func didUpdatePrice(from dataModel: CoinModel) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.coinRateView.coinLabel.text = String(format: "%.2f", dataModel.price)
            self.date = dataModel.date
        }
    }
    
    @objc func showHistory (_ sender: UITapGestureRecognizer) {
        let rateHistoryVC = RateHistoryVC(coinManager: self.coinManager)
        rateHistoryVC.currency = self.currency
        rateHistoryVC.cryptoCurrency = self.cryptoCyrrency
        rateHistoryVC.date = self.date
        let nextVC = UINavigationController(rootViewController: rateHistoryVC)
        navigationController?.present(nextVC, animated: true, completion: nil)
    }
}

private extension CoinRateVC {
    func configure() {
        coinRateView.configureView()
        coinRateView.makeConstraints()
        
        coinRateView.coinPickerView.delegate = self
        
    }
}

extension CoinRateVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return cryptoCurrencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return cryptoCurrencies[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        cryptoCyrrency = cryptoCurrencies[row]
        updateCurrentCoinPrice()
    }
}
