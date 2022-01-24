//
//  CoinRateVC.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 24.01.2022.
//

import Foundation
import UIKit

class CoinRateVC: UIViewController {
    
    private let coinManager = CoinManager()
    var currency: String = "USD"
    private let timer = MyTimer()
    private var cryptoCyrrency = "BTC"
    
    private let coinRateView: UIView = UIView(frame: .zero)
    private let coinPickerView: UIPickerView = UIPickerView(frame: .zero)
    private let coinImageView: UIImageView = UIImageView(frame: .zero)
    private let coinLabel: UILabel = UILabel(frame: .zero)
    private let currencyDesignation: UILabel = UILabel(frame: .zero)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.coinLabel.text = currency
        updateCurrentCoinPrice()
        timer.updateCoinPriceEvery(seconds: 60) { [weak self] in
            self?.updateCurrentCoinPrice()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coinPickerView.delegate = self
        
        view.addSubview(coinRateView)
        coinRateView.addSubview(coinImageView)
        coinRateView.addSubview(coinLabel)
        coinRateView.addSubview(currencyDesignation)
        view.addSubview(coinPickerView)
        
        coinRateView.translatesAutoresizingMaskIntoConstraints = false
        coinImageView.translatesAutoresizingMaskIntoConstraints = false
        coinLabel.translatesAutoresizingMaskIntoConstraints = false
        currencyDesignation.translatesAutoresizingMaskIntoConstraints = false
        coinPickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            coinRateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coinRateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            coinRateView.widthAnchor.constraint(equalToConstant: view.frame.size.width / 1.3),
            coinRateView.heightAnchor.constraint(equalToConstant: 100.0),
            coinImageView.leftAnchor.constraint(equalTo: coinRateView.leftAnchor, constant: 10.0),
            coinImageView.centerYAnchor.constraint(equalTo: coinRateView.centerYAnchor),
            coinImageView.widthAnchor.constraint(equalToConstant: 80.0),
            coinImageView.heightAnchor.constraint(equalToConstant: 80.0),
            coinLabel.leftAnchor.constraint(equalTo: coinImageView.rightAnchor, constant: 20.0),
            coinLabel.centerYAnchor.constraint(equalTo: coinRateView.centerYAnchor),
            currencyDesignation.leftAnchor.constraint(equalTo: coinLabel.rightAnchor, constant: 20.0),
            currencyDesignation.rightAnchor.constraint(equalTo: coinRateView.rightAnchor, constant: -10.0),
            currencyDesignation.widthAnchor.constraint(equalToConstant: 50),
            currencyDesignation.centerYAnchor.constraint(equalTo: coinRateView.centerYAnchor),
            
            coinPickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            coinPickerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            coinPickerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            coinPickerView.topAnchor.constraint(equalTo: coinRateView.bottomAnchor, constant: 20)
        ])
        
        view.backgroundColor = UIColor(named: "Background Color")
        coinRateView.backgroundColor = UIColor(named: "Title Color")
        
        coinImageView.image = UIImage(systemName: "bitcoinsign.circle.fill")
        coinLabel.textAlignment = .center
        coinLabel.numberOfLines = 0
        currencyDesignation.text = currency
        coinLabel.textColor = UIColor(named: "Icon Color")
        currencyDesignation.textColor = UIColor(named: "Icon Color")
        coinImageView.tintColor = UIColor(named: "Icon Color")
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

extension CoinRateVC: UIPickerViewDelegate ,UIPickerViewDataSource {
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

extension CoinRateVC: CoinManagerDelegate {
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
            self.coinLabel.text = self.stringFrom(price: dataModel.price)
        }
    }
}
