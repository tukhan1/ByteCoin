//
//  CurrencyVC.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 24.01.2022.
//

import UIKit
import SnapKit

class CurrencyVC: UIViewController {
    private let coinService: CoinProtocol
    private let currenciesView = CurrenciesView(frame: UIScreen.main.bounds)
    
    init(coinService: CoinProtocol) {
        self.coinService = coinService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currenciesView.updateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        updateCurrencies()
    }
    
    private func updateCurrencies() {
        coinService.getCurrencies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else {
                    return
                }
                switch result {
                case .success(let newCurencies):
                    self.currenciesView.updateUI(with: newCurencies)
                case .failure(let error):
                    self.didFailWithError(error)
                }
            }
        }
    }
    
    private func didFailWithError(_ error: NWError) {
            let alert = UIAlertController(title: "Error", message: error.rawValue, preferredStyle: .alert)
            let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
            alert.addAction(action)
        
            self.present(alert, animated: true, completion: nil)
    }
}

private extension CurrencyVC {
    func configure() {
        view.addSubview(currenciesView)
        
        currenciesView.commonInit()
        
        currenciesView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        
        currenciesView.tableView.delegate = self
        currenciesView.textField.delegate = self
    }
}

extension CurrencyVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text ?? ""
        let newText = text.replacingCharacters(in: Range(range, in: text)!, with: string)
        
        if newText.isEmpty {
            currenciesView.currencies = currenciesView.allCurrencies
        } else {
            currenciesView.currencies = currenciesView.allCurrencies.filter { currency in
                currency.name.lowercased().contains(newText.lowercased())
            }
        }
        currenciesView.tableView.reloadData()
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}

// MARK: - Table view delegate

extension CurrencyVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        pushToNext(viewController: CoinRateVC(coinService: coinService), indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    private func pushToNext(viewController vc: CoinRateVC, _ indexPath: IndexPath) {
        let nextVC = vc
        vc.currency = currenciesView.currencies[indexPath.row].designation
        navigationController?.pushViewController(nextVC, animated: true)
    }
}
