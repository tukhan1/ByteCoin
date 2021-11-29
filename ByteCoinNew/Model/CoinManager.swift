//
//  CoinManager.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 01.10.2021.
//

protocol CoinManagerDelegate {
    func didUpdatePrice(from: CoinModel)
    func didFailWithError(error: Error)
}


import Foundation
import UIKit

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    let currancyArrey = ["USD", "RUB", "EUR", "CNY", "CHF", "JPY", "KZT"]
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "7EF6C5DA-C57D-44C1-BE2B-777B3B9C7332"
    
    func getCoinPrice(for currancy: String){
        
        
        let urlCoin = "\(baseURL)/\(currancy)?apikey=\(apiKey)"
        
        guard let url = URL(string: urlCoin) else {return}
        let urlSession = URLSession(configuration: .default)
        let task = urlSession.dataTask(with: url){data, response, error in
            if error != nil {
                print(error!)
            }
            
            guard let safeData = data else {return}
            let dataModel = parseJSON(safeData)
            delegate?.didUpdatePrice(from: dataModel!)
            
        }
        task.resume()
    }
    
    func parseJSON (_ coinData: Data) -> CoinModel? {
        do {
            let decoder = JSONDecoder()
            
            let decodedData = try decoder.decode(CoinData.self, from: coinData)
            let currancy = decodedData.asset_id_quote
            let price = decodedData.rate
            return CoinModel(currancy: currancy, price: price)
        }
        catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
}
