//
//  CurrenciesView.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 09.02.2022.
//

import UIKit
import SnapKit

class CurrenciesView: UIView {
    var currencies: [Currency] = []
    var allCurrencies: [Currency] = []
    
    let tableView: UITableView = UITableView(frame: .zero, style: .plain)
    let textField: UITextField = UITextField(frame: .zero)
    
    private let headerView: UIView = UIView(frame: .zero)
    private let titleLabel: UILabel = UILabel(frame: .zero)
    private let viewForTextField: UIView = UIView(frame: .zero)
    
    private var observers: [NSObjectProtocol] = []
    private var bottomConstraint: Constraint?
    
    func commonInit() {
        configureView()
        makeConstraints()
        addObservers()
        tableView.dataSource = self
        tableView.register(CurrencyViewCell.self)
    }
    
    func updateUI(with currencies: [Currency]) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.currencies = currencies
            self.allCurrencies = currencies
            
            self.tableView.reloadData()
        }
    }
    
    func updateUI() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.textField.text = ""
            self.currencies = self.allCurrencies
            
            self.tableView.reloadData()
        }
    }
    
    private func configureView() {
        self.addSubview(headerView)
        headerView.addSubview(titleLabel)
        self.addSubview(viewForTextField)
        viewForTextField.addSubview(textField)
        self.addSubview(tableView)
        
        textField.layer.cornerRadius = 10.0
        textField.backgroundColor = .lightGray
        textField.placeholder = "Tap to search"
        textField.textAlignment = .center
        viewForTextField.backgroundColor = .white
        self.backgroundColor = .white
        headerView.backgroundColor = .white
        tableView.backgroundColor = .white
        
        titleLabel.font = UIFont.systemFont(ofSize: 25.0)
        titleLabel.textColor = UIColor(named: "Title_Color")
        titleLabel.text = "Currencies"
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
    }
    
    private func makeConstraints() {
        headerView.snp.makeConstraints { maker in
            maker.left.equalTo(self.snp.left)
            maker.right.equalTo(self.snp.right)
            maker.top.equalTo(self.snp.top)
            maker.height.equalTo(self.snp.height).multipliedBy(0.1)
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
            maker.left.equalTo(self.snp.left)
            maker.right.equalTo(self.snp.right)
            bottomConstraint = maker.bottom.equalTo(self.snp.bottom).constraint
        }
    }
    
    private func addObservers() {
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
    }
    
    private func changeBottomConstraintUseKeyboard(rect: CGRect) {
        UIView.animate(withDuration: 0.25, animations: {
            self.bottomConstraint?.update(offset: -rect.height)
            self.layoutIfNeeded()
        })
    }
}

//MARK: - TableViewDataSourse

extension CurrenciesView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(type: CurrencyViewCell.self, for: indexPath)
        
        let currencyForRow = currencies[indexPath.row]
        cell.configuration(imageUrl: currencyForRow.imageUrl, designation: currencyForRow.designation, title: currencyForRow.name)
        return cell
    }
}

//MARK: - CurrencyViewCell

private class CurrencyViewCell: UITableViewCell, TableCell {
    static let identifier = "\(CurrencyViewCell.self)"
    
    private static let imageStorageManager = ImageStorageManager()
    
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
        loadImageWith(imageUrl)
        
        self.imageUrl = imageUrl
        self.currencyNameLabel.text = title
        self.currencyDesignation.text = designation
    }
    
    private func loadImageWith(_ imageUrl: URL?) {
        guard let url = imageUrl else { return }
        
        if let image = ImageStorageManager.cache.object(forKey: url as NSURL) {
            currencyImageView.image = image
        } else {
            DispatchQueue.global().async {
                if let image = Self.imageStorageManager.getImage(by: url.absoluteString) {
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else {return}
                        ImageStorageManager.cache.setObject(image, forKey: url as NSURL)
                        self.currencyImageView.image = image
                    }
                } else {
                    do {
                        let data = try Data(contentsOf: url)
                        if let image = UIImage(data: data) {
                            if url == self.imageUrl {
                                DispatchQueue.main.async { [weak self] in
                                    guard let self = self else {return}
                                    Self.imageStorageManager.saveImage(image, by: url.absoluteString)
                                    ImageStorageManager.cache.setObject(image, forKey: url as NSURL)
                                    self.currencyImageView.image = image
                                }
                            }
                        }
                    } catch {
                        print("Error loading image from NW: \(error)")
                        return
                    }
                }
            }
        }
    }
}
