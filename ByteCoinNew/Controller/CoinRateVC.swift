//
//  CoinRateVC.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 24.01.2022.
//

import UIKit

class CoinRateVC: UIViewController {
    var date: String = ""
    var currency: String = "USD" {
        willSet(newCurrency) {
            self.coinRateView.currency = newCurrency
        }
    }

    private var cryptoCyrrency = "BTC"
    private var cryptoCurrencies: [String] = []
    private let coinService: CoinProtocol

    private let coinRateView: CoinRateView = CoinRateView(frame: UIScreen.main.bounds)

    private lazy var timer = MyTimer(seconds: 60) { [weak self] in
        self?.updateCurrentCoinPrice()
    }
    
    init(coinService: CoinProtocol) {
        self.coinService = coinService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        view.addSubview(coinRateView)
        configure()
        coinRateView.coinLabel.text = currency
        updateCurrentCoinPrice()
        timer.performAction()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.cryptoCurrencies = coinService.cryptoCurrencies
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(pushToNextVC))
        coinRateView.coinView.addGestureRecognizer(gesture)
    }
    
    @objc func pushToNextVC (_ sender: UITapGestureRecognizer) {
        let rateHistoryVC = RateHistoryVC(coinService: self.coinService)
        rateHistoryVC.currency = self.currency
        rateHistoryVC.cryptoCurrency = self.cryptoCyrrency
        rateHistoryVC.date = self.date
        let nextVC = UINavigationController(rootViewController: rateHistoryVC)
        navigationController?.present(nextVC, animated: true, completion: nil)
    }
    
    func updateCurrentCoinPrice() {
        coinService.getCoinPrice(for: currency, to: cryptoCyrrency) { [weak self] result in
            DispatchQueue.main.async {
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
    
    private func didUpdatePrice(from dataModel: CoinModel) {
            self.coinRateView.coinLabel.text = String(format: "%.2f", dataModel.price)
            self.date = dataModel.date
    }
    
    private func didFailWithError(_ error: NWError) {
            let alert = UIAlertController(title: "Error", message: error.rawValue, preferredStyle: .alert)
            let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
            alert.addAction(action)
        
            self.present(alert, animated: true, completion: nil)
    }
}

private extension CoinRateVC {
    func configure() {
        view.addSubview(coinRateView)
        coinRateView.commonInit()
        
        coinRateView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        
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
