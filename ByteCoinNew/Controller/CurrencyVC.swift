//
//  CurrencyVC.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 24.01.2022.
//

import UIKit
import SnapKit

class CurrencyVC: UIViewController {
    
    private let coinManager: CoinProtocol
    private var currencies: [Currency] = []
    private var allCurrencies: [Currency] = []
    private var currenciesView: CurrenciesView = CurrenciesView(frame: UIScreen.main.bounds)
    
    init(coinManager: CoinProtocol) {
        self.coinManager = coinManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currenciesView.textField.text = ""
        currencies = allCurrencies
        currenciesView.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(currenciesView)
        configure()
        updateCurrencies()
        
        currenciesView.tableView.register(CurrencyViewCell.self)
        currenciesView.textField.delegate = self
    }
    
    private func updateCurrencies() {
        coinManager.getCurrencies { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let newCureencies):
                DispatchQueue.main.async {
                    self.currencies = newCureencies
                    self.allCurrencies = newCureencies
                    self.currenciesView.tableView.reloadData()
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
}

private extension CurrencyVC {
    func configure() {
        currenciesView.commonInit()
        currenciesView.tableView.delegate = self
        currenciesView.tableView.dataSource = self
        currenciesView.tableView.tableFooterView = UIView(frame: .zero)
        currenciesView.textField.delegate = self
    }
}

extension CurrencyVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text ?? ""
        let newText = text.replacingCharacters(in: Range(range, in: text)!, with: string)
        
        if newText.isEmpty {
            currencies = allCurrencies
        } else {
            currencies = allCurrencies.filter { currency in
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

// MARK: - Table view delegate & data source

extension CurrencyVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let nextVC = CoinRateVC(coinManager: self.coinManager)
        nextVC.currency = currencies[indexPath.row].designation
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(type: CurrencyViewCell.self, for: indexPath)
        
        let currencyForRow = currencies[indexPath.row]
        cell.configuration(imageUrl: currencyForRow.imageUrl, designation: currencyForRow.designation, title: currencyForRow.name)
        return cell
    }
}

private class CurrencyViewCell: UITableViewCell, TableCell {
    static let identifier = "\(CurrencyViewCell.self)"
    private var imageUrl: URL?
    private let currencyImageView: UIImageView = UIImageView(image: .add)
    private let currencyNameLabel: UILabel = UILabel(frame: .zero)
    private let currencyDesignation: UILabel = UILabel(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureView()
        makeConstraints()
    }
    
    private func configureView() {
        contentView.addSubview(currencyImageView)
        contentView.addSubview(currencyNameLabel)
        contentView.addSubview(currencyDesignation)
        
        currencyImageView.tintColor = UIColor(named: "Title Color")
        currencyDesignation.tintColor = UIColor(named: "Title Color")
        currencyDesignation.textAlignment = .center
        currencyNameLabel.tintColor = UIColor(named: "Title Color")
        currencyNameLabel.textAlignment = .left
    }
    
    private func makeConstraints() {
        currencyImageView.snp.makeConstraints { maker in
            maker.left.equalTo(contentView.snp.left).offset(20.0)
            maker.centerY.equalTo(contentView.snp.centerY)
            maker.width.equalTo(contentView.snp.height).multipliedBy(0.9)
            maker.height.equalTo(contentView.snp.height).multipliedBy(0.9)
        }
        currencyDesignation.snp.makeConstraints { maker in
            maker.left.equalTo(currencyImageView.snp.right).offset(5.0)
            maker.centerY.equalTo(contentView.snp.centerY)
            maker.width.equalTo(50.0)
        }
        currencyNameLabel.snp.makeConstraints { maker in
            maker.left.equalTo(currencyDesignation.snp.right).offset(5.0)
            maker.right.equalTo(contentView.snp.right).inset(20.0)
            maker.centerY.equalTo(contentView.snp.centerY)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configuration(imageUrl: URL? ,designation: String, title: String) {
        DispatchQueue.global().async {
            do {
                if let url = imageUrl {
                    let data = try Data(contentsOf: url)
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        if url == self.imageUrl {
                            self.currencyImageView.image = UIImage(data: data)
                        }
                    }
                }
            }
            catch {
                print(error)
            }
        }
        self.imageUrl = imageUrl
        self.currencyNameLabel.text = title
        self.currencyDesignation.text = designation
    }
}
