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
    private var cryptoCyrrency = "BTC"
    
    @IBOutlet private var bitcoinLabel: UILabel!
    @IBOutlet private var valueLabel: UILabel!
    @IBOutlet private var cryptoPicker: UIPickerView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.valueLabel.text = currency
        
        updateCurrentCoinPrice()
        
        setTimer(on: 60.0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        stopTimer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cryptoPicker.delegate = self
    }
    
    @objc func updateCurrentCoinPrice() {
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
    
//MARK: - Timer actions
    
    func setTimer(on seconds: Double) {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(updateCurrentCoinPrice), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer.invalidate()
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
        setTimer(on: 60.0)
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
