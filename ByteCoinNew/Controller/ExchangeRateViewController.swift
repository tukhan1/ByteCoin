//
//  ViewController.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 01.10.2021.
//

import UIKit

class ExchangeRateViewController: UIViewController {
    
    private let coinManager = CoinManager()
    var currency: String = ""
    private let timer = MyTimer()
    private var cryptoCyrrency = "BTC"
    
    @IBOutlet private var bitcoinLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!
    @IBOutlet private var cryptoPicker: UIPickerView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.valueLabel.text = currency
        updateCurrentCoinPrice()
        timer.updateCoinPriceEvery(seconds: 60) { [weak self] in
            self?.updateCurrentCoinPrice()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cryptoPicker.delegate = self
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
}

//MARK: - UIPickerViewDataSource, UIPickerViewDelegate

extension ExchangeRateViewController: UIPickerViewDataSource, UIPickerViewDelegate  {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coinManager.cryptoCurrencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return coinManager.cryptoCurrencies[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        cryptoCyrrency = coinManager.cryptoCurrencies[row]
        updateCurrentCoinPrice()
        timer.updateCoinPriceEvery(seconds: 60) { [weak self] in
            self?.updateCurrentCoinPrice()
        }
    }
}

//MARK: - CoinManagerDelegate

extension ExchangeRateViewController: CoinManagerDelegate {
    func didFailWithError(_ error: NWError) {
        print(error.rawValue)
    }
    
    private func stringFrom(price: Double) -> String {
        return String(format: "%.2f", price)
    }
    
    func didUpdatePrice(from dataModel: CoinModel) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else {
                return
            }
            self.bitcoinLabel.text = self.stringFrom(price: dataModel.price)
        }
    }
}
