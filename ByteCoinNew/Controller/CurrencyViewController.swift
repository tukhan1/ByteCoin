//
//  CurrencyViewController.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 13.01.2022.
//

import UIKit

class CurrencyViewController: UITableViewController {
    
    private let cellIdentifier = "currencyCell"
    private let coinManager = CoinManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinManager.currenciesArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let currency = coinManager.currenciesArray[indexPath.row]
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(x: 10, y: 0, width: 50, height: 50)
        imageView.image = currency.image
        cell.addSubview(imageView)
        let designation = UILabel()
        designation.frame = CGRect(x: 60 , y: 0, width: 40, height: 50)
        designation.textAlignment = .center
        designation.text = currency.designation
        cell.addSubview(designation)
        let title = UILabel()
        title.frame = CGRect(x: 110, y: 0, width: 250, height: 50)
        title.text = currency.title
        cell.addSubview(title)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    // MARK: - Segue
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toExchangeRateVC", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toExchangeRateVC" {
            guard let destinationVC = segue.destination as? ExchangeRateViewController else {
                return
            }
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.currency = coinManager.currenciesArray[indexPath.row].designation
            }
        }
    }
}
