//
//  CoinManager.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 01.10.2021.
//

import Foundation
import UIKit

enum NWError: String, Error {
    case invalidURL = "Something wrong with URL"
    case unableToComplite = "Received ERROR"
    case invalidData = "Something wrong with Data"
}

private struct CoinData: Decodable {
    var time: String
    var assetIdQuote: String
    var rate: Double
    
    enum CodingKeys: String, CodingKey {
        case time
        case assetIdQuote = "asset_id_quote"
        case rate
    }
}

private struct Image: Decodable {
    let designation: String
    let imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case designation = "asset_id"
        case imageUrl = "url"
    }
}

private struct Value: Decodable {
    var designation: String
    var name: String
    var isCrypto: Int
    
    enum CodingKeys: String, CodingKey {
        case designation = "asset_id"
        case name
        case isCrypto = "type_is_crypto"
    }
}

class CoinManager {
    private var rateHistory: [TimeseriesData] = []
    private var currencies: [Value] = []
    private var images: [Image] = []
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)

    let cryptoCurrencies: [String] = ["BTC", "ETH", "LTC", "DOGE", "BNB", "BCH"]
    
    private static let baseURL = "https://rest.coinapi.io" // /v1/exchangerate/
    private static let apiKey = /*"92143236-BED0-4E67-9FA1-C8E0FB161020" */ "759E9A9B-E140-465D-B47B-90DF2EAA17FC" /*"D209ABE8-CFA8-44F7-9E19-42CC3E665B24" "7EF6C5DA-C57D-44C1-BE2B-777B3B9C7332"*/
    
    private func request<T: Decodable>(data t: [T].Type, withUrl url: String, completed: @escaping (Result<[T], NWError>) -> Void) {
        if let requestUrl = URL(string: "\(CoinManager.baseURL)".appending(url)) {
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "GET"
            request.addValue(CoinManager.apiKey, forHTTPHeaderField: "X-CoinAPI-Key")
            
            // Perform request
            let urlSession = URLSession(configuration: .default)
            let task = urlSession.dataTask(with: request as URLRequest) { data, response, error in
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
                    let decodedData = try decoder.decode(t, from: safeData)
                    let data = decodedData
                    completed(.success(data))
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
    
    private func fatchCurrencies(completed: @escaping (Result<[Value], NWError>) -> Void) {
        let url = "/v1/assets"
        request(data: [Value].self, withUrl: url) { result in
            switch result {
            case(.success(let data)):
                completed(.success(data))
            case(.failure(let e)):
                completed(.failure(e))
            }
        }
    }
    
    private func getImagesForCurrencies(size: Int = 25, completed: @escaping (Result<[Image], NWError>) -> Void) {
        request(data: [Image].self, withUrl: "/v1/assets/icons/\(size)") { result in
            switch result {
            case(.success(let data)):
                completed(.success(data))
            case(.failure(let e)):
                completed(.failure(e))
            }
        }
    }
    
    private func removeСryptoFrom(data: [Value]) -> [Value] {
        var notCrypto: [Value] = []
        for currncy in data {
            if currncy.isCrypto == 0 {
                notCrypto.append(currncy)
            }
        }
        return notCrypto
    }
    
    private func margeImagesAndCurrency(images: [Image], currencies: [Value]) -> [Currency] {
        var values: [Currency] = []
        for currency in currencies {
            for image in images {
                if currency.designation == image.designation {
                    values.append(Currency(designation: currency.designation,
                                           name: currency.name,
                                           imageUrl: image.imageUrl))
                }
            }
        }
        return values
    }
    
    func getCurrencies(completed: @escaping (Result<[Currency], NWError>) -> Void) {
        DispatchQueue.global().async {
            self.fatchCurrencies { [weak self] result in
                guard let self = self else {
                    completed(.failure(NWError.unableToComplite))
                    return
                }
                switch result {
                case.success(let values):
                    self.currencies = values
                    self.semaphore.signal()
                case.failure(_):
                    completed(.failure(NWError.unableToComplite))
                    self.semaphore.signal()
                }
            }
        }
        DispatchQueue.global().async {
            self.getImagesForCurrencies { [weak self] result in
                guard let self = self else {
                    completed(.failure(NWError.unableToComplite))
                    return
                }
                switch result {
                case.success(let images):
                    self.images = images
                case.failure(_):
                    completed(.failure(NWError.unableToComplite))
                }
            }
        }
        semaphore.wait()
        currencies = removeСryptoFrom(data: currencies)
        completed(.success(self.margeImagesAndCurrency(images: self.images, currencies: self.currencies)))
    }
    
    func getCoinPrice(for currency: String, to crypto: String = "BTC" , completed: @escaping (Result<CoinModel, NWError>) -> Void) {
        
        let urlCoin = "\(CoinManager.baseURL)/v1/exchangerate/\(crypto)/\(currency)?apikey=\(CoinManager.apiKey)"

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
                    let time = decodedData.time
                    let currency = decodedData.assetIdQuote
                    let price = decodedData.rate
                    completed(.success(CoinModel(date: time, currency: currency, price: price)))
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
    
    func historyPricePerHourFor(cryptocurrency coin: String, to currency : String, timeStart: String, timeEnd: String, completed: @escaping (Result<[TimeseriesData], NWError>) -> Void) {
        let url = "/v1/exchangerate/\(coin)/\(currency)/history?period_id=1HRS&time_start=\(timeStart)&time_end=\(timeEnd)"
        
        request(data: [TimeseriesData].self, withUrl: url) { result in
            switch result {
            case(.success(let data)):
                completed(.success(data))
            case(.failure(let e)):
                completed(.failure(e))
            }
        }
    }
}
