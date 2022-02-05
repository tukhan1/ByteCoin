//
//  CurrencyVC.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 24.01.2022.
//

import UIKit
import SnapKit

class CurrencyVC: UIViewController {
    
    private let coinManager: CoinManager = CoinManager()
    private var bottomConstraint: Constraint?
    private var currencies: [Currency] = []
    private var allCurrencies: [Currency] = []
    private var observers: [NSObjectProtocol] = []
    
    private let headerView: UIView = UIView(frame: .zero)
    private let titleLabel: UILabel = UILabel(frame: .zero)
    private let tableView: UITableView = UITableView(frame: .zero, style: .plain)
    private let viewForTextField: UIView = UIView(frame: .zero)
    private let textField: UITextField = UITextField(frame: .zero)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currencies = allCurrencies
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coinManager.getCurrencies { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let cur):
                self.currencies = cur
                self.allCurrencies = cur
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure(let e):
                print(e)
            }
        }
        
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        view.addSubview(viewForTextField)
        viewForTextField.addSubview(textField)
        view.addSubview(tableView)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        viewForTextField.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.snp.makeConstraints { maker in
            maker.left.equalTo(view.snp.left)
            maker.right.equalTo(view.snp.right)
            maker.top.equalTo(view.snp.top)
            maker.height.equalTo(view.snp.height).multipliedBy(0.1)
        }
        titleLabel.snp.makeConstraints { maker in
            maker.centerX.equalTo(headerView.snp.centerX)
            maker.width.equalTo(headerView.snp.width).multipliedBy(0.5)
            maker.bottom.equalTo(headerView.snp.bottom).inset(5.0)
        }
        viewForTextField.snp.makeConstraints { maker in
            maker.top.equalTo(headerView.snp.bottom)
            maker.left.equalTo(headerView.snp.left)
            maker.right.equalTo(headerView.snp.right)
            maker.height.equalTo(50.0)
        }
        textField.snp.makeConstraints { maker in
            maker.top.equalTo(viewForTextField.snp.top).offset(5.0)
            maker.left.equalTo(viewForTextField.snp.left).offset(20.0)
            maker.right.equalTo(viewForTextField.snp.right).inset(20.0)
            maker.bottom.equalTo(viewForTextField.snp.bottom).inset(5.0)
        }
        tableView.snp.makeConstraints { maker in
            maker.top.equalTo(viewForTextField.snp.bottom)
            maker.left.equalTo(view.snp.left)
            maker.right.equalTo(view.snp.right)
            self.bottomConstraint = maker.bottom.equalTo(view.snp.bottom).constraint
        }
        
        textField.layer.cornerRadius = 10.0
        textField.backgroundColor = .lightGray
        textField.placeholder = "Tap to search"
        textField.textAlignment = .center
        viewForTextField.backgroundColor = .white
        view.backgroundColor = .white
        headerView.backgroundColor = .white
        tableView.backgroundColor = .white
        
        titleLabel.font = UIFont.systemFont(ofSize: 25.0)
        titleLabel.textColor = UIColor(named: "Title_Color")
        titleLabel.text = "Currencies"
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        tableView.register(CurrencyViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: .zero)
        
        observers.append(NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: OperationQueue.main) { [weak self] notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                    let keyboardRect = keyboardFrame.cgRectValue
                    self?.changeBottomConstraintUseKeyboard(rect: keyboardRect)
                }
            })
        
        observers.append(NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: OperationQueue.main) { [weak self] notification in
                self?.changeBottomConstraintUseKeyboard(rect: CGRect.zero)
            })
        
        textField.delegate = self
    }
    
    private func changeBottomConstraintUseKeyboard(rect: CGRect) {
        UIView.animate(withDuration: 0.25, animations: {
            self.bottomConstraint?.update(offset: -rect.height)
            self.view.layoutIfNeeded()
        })
    }
}

extension CurrencyVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            if text.count != 0 {
                currencies = currencies.filter({ currency in
                    currency.name.contains(text)
                })
                tableView.reloadData()
            } else {
                currencies = allCurrencies
                tableView.reloadData()
            }
        }
        return true
    }
}

// MARK: - Table view delegate & data source

extension CurrencyVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let nextVC = CoinRateVC()
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
    private var imageUrl: String?
    private let currencyImageView: UIImageView = UIImageView(image: .add)
    private let currencyNameLabel: UILabel = UILabel(frame: .zero)
    private let currencyDesignation: UILabel = UILabel(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(currencyImageView)
        contentView.addSubview(currencyNameLabel)
        contentView.addSubview(currencyDesignation)
        
        currencyImageView.translatesAutoresizingMaskIntoConstraints = false
        currencyNameLabel.translatesAutoresizingMaskIntoConstraints = false
        currencyDesignation.translatesAutoresizingMaskIntoConstraints = false
        
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
        
        currencyImageView.tintColor = UIColor(named: "Title Color")
        currencyDesignation.tintColor = UIColor(named: "Title Color")
        currencyDesignation.textAlignment = .center
        currencyNameLabel.tintColor = UIColor(named: "Title Color")
        currencyNameLabel.textAlignment = .left
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configuration(imageUrl: String ,designation: String, title: String) {
        DispatchQueue.global().async {
            do {
                if let url = URL(string: imageUrl) {
                    let data = try Data(contentsOf: url)
                    DispatchQueue.main.async {
                        if imageUrl == self.imageUrl {
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
        self.currencyDesignation.adjustsFontSizeToFitWidth = true
    }
}

protocol TableCell: AnyObject {
    static var identifier: String { get }
}

extension UITableView {
    func register<T: TableCell>(_ type: T.Type) {
        self.register(type, forCellReuseIdentifier: type.identifier)
    }
    
    func dequeueReusableCell<T: TableCell>(type: T.Type, for indexPath: IndexPath) -> T {
        self.dequeueReusableCell(withIdentifier: type.identifier, for: indexPath) as! T
    }
}
