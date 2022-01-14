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
    private var timer = Timer()
    private var cryptoCyrrency: String? = nil
    
    @IBOutlet private var bitcoinLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!
    @IBOutlet var cryptoPicker: UIPickerView!
    
    override func viewWillAppear(_ animated: Bool) {
        self.valueLabel.text = currency
        
        timer.invalidate()
        updateCurrentCoinPrice()

        timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(updateCurrentCoinPrice), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coinManager.delegate = self
        cryptoPicker.delegate = self
    }
    
    @objc func updateCurrentCoinPrice() {
        coinManager.getCoinPrice(for: currency, to: cryptoCyrrency) {[weak self] result in
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
        timer.invalidate()
        cryptoCyrrency = coinManager.cryptoCurrencies[row]
        updateCurrentCoinPrice()
        
        timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(updateCurrentCoinPrice), userInfo: nil, repeats: true)
    }
}

//MARK: - CoinManagerDelegate

extension ExchangeRateViewController: CoinManagerDelegate {
    func didFailWithError(_ error: Error) {
        print(error)
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
