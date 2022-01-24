//
//  CurrencyVC.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 24.01.2022.
//

import Foundation
import UIKit

class CurrencyVC: UIViewController {
    
    private let coinManager: CoinManager = CoinManager()
    
    private let headerView: UIView = UIView(frame: .zero)
    private let titleLabel: UILabel = UILabel(frame: .zero)
    private let tableView: UITableView = UITableView(frame: .zero, style: .plain)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(headerView)
        headerView.addSubview(titleLabel)
        view.addSubview(tableView)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: headerView.topAnchor),
            view.leftAnchor.constraint(equalTo: headerView.leftAnchor),
            view.rightAnchor.constraint(equalTo: headerView.rightAnchor),
            headerView.heightAnchor.constraint(equalTo: tableView.heightAnchor, multiplier: 0.2),
            headerView.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -20.0),
            view.leftAnchor.constraint(equalTo: tableView.leftAnchor),
            view.rightAnchor.constraint(equalTo: tableView.rightAnchor),
            view.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            headerView.safeAreaLayoutGuide.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: 0.0),
            headerView.safeAreaLayoutGuide.leftAnchor.constraint(equalTo: titleLabel.leftAnchor, constant: 0.0),
            headerView.safeAreaLayoutGuide.rightAnchor.constraint(equalTo: titleLabel.rightAnchor, constant: 0.0)
        ])
        
        view.backgroundColor = UIColor(named: "Background Color")
        headerView.backgroundColor = .white
        tableView.backgroundColor = .white
        
        titleLabel.font = UIFont.systemFont(ofSize: 25.0)
        titleLabel.textColor = UIColor(named: "Title Color")
        titleLabel.text = "Currencies"
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        tableView.register(CurrencyViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView(frame: .zero)
    }
}

// MARK: - Table view delegate & data source

extension CurrencyVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let nextVC = CoinRateVC()
        nextVC.currency = coinManager.currenciesArray[indexPath.row].designation
        
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinManager.currenciesArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(type: CurrencyViewCell.self, for: indexPath)
        
        let currencyForRow = coinManager.currenciesArray[indexPath.row]
        cell.configuration(image: currencyForRow.image,designation: currencyForRow.designation , title: currencyForRow.title)
        
        return cell
    }
}

private class CurrencyViewCell: UITableViewCell, TableCell {
    static let identifier = "\(CurrencyViewCell.self)"
    
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
        
        NSLayoutConstraint.activate([
            currencyImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20.0),
            currencyImageView.widthAnchor.constraint(equalToConstant: 40.0),
            currencyImageView.heightAnchor.constraint(equalToConstant: 40.0),
            currencyImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            currencyImageView.rightAnchor.constraint(equalTo: currencyDesignation.leftAnchor, constant: 0.0),
            
            currencyDesignation.widthAnchor.constraint(equalToConstant: 50.0),
            currencyDesignation.rightAnchor.constraint(equalTo: currencyNameLabel.leftAnchor, constant: 0.0),
            currencyDesignation.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            currencyNameLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20.0),
            
            currencyNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        currencyImageView.tintColor = UIColor(named: "Title Color")
        currencyDesignation.tintColor = UIColor(named: "Title Color")
        currencyDesignation.textAlignment = .center
        currencyNameLabel.tintColor = UIColor(named: "Title Color")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configuration(image: UIImage?, designation: String, title: String) {
        currencyImageView.image = image
        currencyDesignation.text = designation
        currencyNameLabel.text = title
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
