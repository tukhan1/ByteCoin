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
    var date: String = ""
    private var cryptoCyrrency = "BTC"
    private lazy var timer = MyTimer(seconds: 60) { [weak self] in
        self?.updateCurrentCoinPrice()
    }
    
    private let coinRateView: UIView = UIView(frame: .zero)
    private let viewForPicker: UIView = UIView(frame: .zero)
    private let coinPickerView: UIPickerView = UIPickerView(frame: .zero)
    private let coinImageView: UIImageView = UIImageView(frame: .zero)
    private let coinLabel: UILabel = UILabel(frame: .zero)
    private let currencyDesignation: UILabel = UILabel(frame: .zero)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.coinLabel.text = currency
        updateCurrentCoinPrice()
        timer.performAction()
    }
    
    @objc func showHistory (_ sender: UITapGestureRecognizer) {
        let rateHistoryVC = RateHistoryVC()
        rateHistoryVC.currency = self.currency
        rateHistoryVC.cryptoCurrency = self.cryptoCyrrency
        rateHistoryVC.date = self.date
        let nextVC = UINavigationController(rootViewController: rateHistoryVC)
        navigationController?.present(nextVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coinPickerView.delegate = self
        
        let touchForHestory = UITapGestureRecognizer(target: self, action: #selector(showHistory))

        coinRateView.addGestureRecognizer(touchForHestory)
        
        view.addSubview(coinRateView)
        coinRateView.addSubview(coinImageView)
        coinRateView.addSubview(coinLabel)
        coinRateView.addSubview(currencyDesignation)
        view.addSubview(viewForPicker)
        viewForPicker.addSubview(coinPickerView)
        
        coinRateView.translatesAutoresizingMaskIntoConstraints = false
        coinImageView.translatesAutoresizingMaskIntoConstraints = false
        coinLabel.translatesAutoresizingMaskIntoConstraints = false
        currencyDesignation.translatesAutoresizingMaskIntoConstraints = false
        viewForPicker.translatesAutoresizingMaskIntoConstraints = false
        coinPickerView.translatesAutoresizingMaskIntoConstraints = false
        
        // view.userInteractionEnabled = true
        coinRateView.snp.makeConstraints { maker in
            maker.centerX.equalTo(view.snp.centerX)
            maker.centerY.equalTo(view.snp.centerY)
            maker.right.equalTo(currencyDesignation.snp.right).offset(10.0)
            maker.height.equalTo(coinImageView.snp.height).offset(10.0)
        }
        coinImageView.snp.makeConstraints { maker in
            maker.left.equalTo(coinRateView.snp.left).offset(10.0)
            maker.centerY.equalTo(coinRateView.snp.centerY)
            maker.width.equalTo(view.snp.height).multipliedBy(0.1)
            maker.height.equalTo(coinImageView.snp.width)
        }
        coinLabel.snp.makeConstraints { maker in
            maker.centerY.equalTo(coinRateView.snp.centerY)
            maker.width.greaterThanOrEqualTo(view.snp.width).multipliedBy(0.2)
            maker.left.equalTo(coinImageView.snp.right).offset(10.0)
        }
        currencyDesignation.snp.makeConstraints { maker in
            maker.left.equalTo(coinLabel.snp.right).offset(10.0)
            maker.right.equalTo(coinRateView.snp.right).inset(10.0)
            maker.width.equalTo(50.0)
            maker.centerY.equalTo(coinRateView.snp.centerY)
        }
        viewForPicker.snp.makeConstraints { maker in
            maker.top.equalTo(coinRateView.snp.bottom).offset(10.0)
            maker.left.equalTo(view.snp.left)
            maker.right.equalTo(view.snp.right)
            maker.bottom.equalTo(view.snp.bottom)
        }
        coinPickerView.snp.makeConstraints { maker in
            maker.top.equalTo(viewForPicker.snp.top)
            maker.bottom.equalTo(viewForPicker.safeAreaLayoutGuide.snp.bottom)
            maker.left.equalTo(view.snp.left)
            maker.right.equalTo(view.snp.right)
        }
        
        view.backgroundColor = UIColor(named: "Background_Color")
        viewForPicker.backgroundColor = UIColor(named: "Background_Color")
        coinRateView.backgroundColor = UIColor(named: "Title_Color")
        
        coinImageView.image = UIImage(systemName: "bitcoinsign.circle.fill")
        coinLabel.textAlignment = .center
        coinLabel.numberOfLines = 0
        currencyDesignation.text = currency
        coinLabel.textColor = UIColor(named: "Icon_Color")
        currencyDesignation.textColor = UIColor(named: "Icon_Color")
        coinImageView.tintColor = UIColor(named: "Icon_Color")
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
            self.date = dataModel.date
        }
    }
}

extension CoinRateVC: UIPickerViewDelegate, UIPickerViewDataSource {
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
    }
}
