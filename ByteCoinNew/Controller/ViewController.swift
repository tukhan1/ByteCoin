//
//  ViewController.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 01.10.2021.
//

import UIKit

class ViewController: UIViewController {
    
    var coinManager = CoinManager()
    
    
    @IBOutlet weak var bitcoinLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var valuePicker: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        coinManager.delegate = self
        valuePicker.dataSource = self
        valuePicker.delegate = self
    }
    
    
}

//MARK: - UIPickerViewDataSource, UIPickerViewDelegate

extension ViewController: UIPickerViewDataSource, UIPickerViewDelegate  {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return coinManager.currancyArrey.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return coinManager.currancyArrey[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let currancy = coinManager.currancyArrey[row]
        coinManager.getCoinPrice(for : currancy)
    }
}


//MARK: - CoinManagerDelegate

extension ViewController: CoinManagerDelegate {
    func didFailWithError(error: Error) {
        print(error)
    }
    
    func didUpdatePrice(from: CoinModel) {
        DispatchQueue.main.async{
            self.bitcoinLabel.text = from.priceString
            self.valueLabel.text = from.currancy
        }
    }
}



