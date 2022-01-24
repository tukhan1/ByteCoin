//
//  CoinManager.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 01.10.2021.
//

import Foundation
import UIKit

protocol CoinManagerDelegate: AnyObject {
    func didUpdatePrice(from: CoinModel)
    func didFailWithError(_ error: NWError)
}

enum NWError: String, Error {
    case invalidURL = "Something wrong with URL"
    case unableToComplite = "Received ERROR"
    case invalidData = "Something wrong with Data"
}

private struct CoinData: Decodable {
    var assetIdQuote: String
    var rate: Double
    
    enum CodingKeys: String, CodingKey {
            case assetIdQuote = "asset_id_quote"
            case rate
        }
}

class CoinManager {
    let currenciesArray: [Currency] = [
        Currency(image: UIImage(systemName: "rublesign.square"), designation: "RUB", title: "Российский рубль"),
        Currency(image: UIImage(systemName: "dollarsign.square"), designation: "USD", title: "Американский доллар"),
        Currency(image: UIImage(systemName: "eurosign.square"), designation: "EUR", title: "Евро"),
        Currency(image: UIImage(systemName: "sterlingsign.square"), designation: "GBP", title: "Британский фунт стерлинга"),
        Currency(image: UIImage(systemName: "yensign.square"), designation: "JPY", title: "Японская иена"),
        Currency(image: UIImage(systemName: "francsign.square"), designation: "CHF", title: "Швейцарский франк")
    ]
    
    let cryptoCurrencies: [String] = ["BTC", "ETH", "LTC", "DOGE", "BNB", "BCH"]
    
    private static let baseURL = "https://rest.coinapi.io/v1/exchangerate/"
    private static let apiKey = /*"759E9A9B-E140-465D-B47B-90DF2EAA17FC"*/ "D209ABE8-CFA8-44F7-9E19-42CC3E665B24" /*"7EF6C5DA-C57D-44C1-BE2B-777B3B9C7332"*/
    
    func getCoinPrice(for currency: String, to crypto: String = "BTC" , completed: @escaping (Result<CoinModel, NWError>) -> Void) {
        let urlCoin = "\(CoinManager.baseURL + crypto)/\(currency)?apikey=\(CoinManager.apiKey)"
        
        if let url = URL(string: urlCoin) {
            let urlSession = URLSession(configuration: .default)
            let task = urlSession.dataTask(with: url) { data, response, error in
                if let _ = error {
                    completed(.failure(.unableToComplite))
                    return
                }
                guard let safeData = data else {
                    completed(.failure(.invalidData))
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(CoinData.self, from: safeData)
                    let currency = decodedData.assetIdQuote
                    let price = decodedData.rate
                    completed(.success(CoinModel(currency: currency, price: price)))
                }
                catch {
                    completed(.failure(.invalidData))
                }
            }
            task.resume()
        } else {
            completed(.failure(.invalidURL))
            return
        }
    }
}
