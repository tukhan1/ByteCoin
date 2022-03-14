//
//  CoinManager.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 01.10.2021.
//

import Foundation

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

private struct Image: Decodable {
    let designation: String
    let imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case designation = "asset_id"
        case imageUrl = "url"
    }
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

private struct TimeseriesData: Decodable {
    var timeOpen: String
    var rateOpen: Double
    
    enum CodingKeys: String, CodingKey {
        case timeOpen = "time_open"
        case rateOpen = "rate_open"
    }
}

class CoinService: CoinProtocol {
    let cryptoCurrencies: [String] = ["BTC", "ETH", "LTC", "BNB", "BCH", "DOGE"]
    
    private let networkManager: NetworkManager
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }

    func getCurrencies(completion: @escaping (Result<[Currency], NWError>) -> Void) {
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        var currencies: [Value] = []
        var images: [Image] = []
        var error: NWError? = nil
        
        fatchCurrencies { result in
            defer { semaphore.signal() }
            switch result {
            case.success(let newCurrencies):
                currencies = newCurrencies.filter { $0.isCrypto == 0 }
            case.failure(let e):
                error = e
            }
        }
        getImagesForCurrencies { result in
            defer { semaphore.signal() }
            switch result {
            case.success(let newImages):
                images = newImages
            case.failure(let e):
                error = e
            }
        }
        
        DispatchQueue.global().async {
            semaphore.wait()
            semaphore.wait()
            
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(self.margeImagesAndCurrency(images: images, currencies: currencies)))
            }
        }
    }
    
    private func fatchCurrencies(completion: @escaping (Result<[Value], NWError>) -> Void) {
        let path = "/v1/assets"
        networkManager.request(withUrl: path, completion: completion)
    }
    
    private func getImagesForCurrencies(size: Int = 10, completion: @escaping (Result<[Image], NWError>) -> Void) {
        let path = "/v1/assets/icons/\(size)"
        networkManager.request(withUrl: path, completion: completion)
    }
    
    private func margeImagesAndCurrency(images: [Image], currencies: [Value]) -> [Currency] {
        var values: [Currency] = []
        for currency in currencies {
            for image in images {
                if currency.designation == image.designation {
                    values.append(Currency(designation: currency.designation,
                                           name: currency.name,
                                           imageUrl: URL(string: image.imageUrl)))
                }
            }
        }
        return values
    }
    
    func getCoinPrice(for currency: String,
                      to crypto: String = "BTC",
                      completion: @escaping (Result<CoinModel, NWError>) -> Void) {
        let path = "/v1/exchangerate/\(crypto)/\(currency)"
        networkManager.request(withUrl: path) { (result: Result<CoinData, NWError>) in
            switch result {
            case .success(let newCoinData):
                completion(.success(CoinModel(date: newCoinData.time,
                                              currency: newCoinData.assetIdQuote,
                                              price: newCoinData.rate)))
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }
    
    func getHistoryPricePerHour(for coin: String,
                                to currency : String,
                                timeEnd: String,
                                completion: @escaping (Result<[HistoryData], NWError>) -> Void) {
        
        let nDaysBefore = timeEnd.getNDaysBefore(N: 4)
        
        let path = "/v1/exchangerate/\(coin)/\(currency)/history?period_id=1HRS&time_start=\(nDaysBefore)&time_end=\(timeEnd)"
        networkManager.request(withUrl: path) { (result: Result<[TimeseriesData], NWError>) in
            switch result {
            case .success(let data):
                var history: [HistoryData] = []
                data.forEach { item in
                    let timeOpen = item.timeOpen.transformStringToDate()
                    history.append(HistoryData(timeOpen: timeOpen, rateOpen: item.rateOpen))
                }
                completion(.success(history))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

private extension String {
    func getNDaysBefore(N number: Double) -> String {
        let dateFormatter = DateFormatter.apiFormat
        
        if let date = dateFormatter.date(from: self) {
            let nDaysBefore = date.addingTimeInterval(-86400.0 * number)
            return dateFormatter.string(from: nDaysBefore)
        } else {
            return "There was an error decoding the string"
        }
    }

    func transformStringToDate() -> Date {
        let dateFormatter = DateFormatter.apiFormat
        
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return Date()
        }
    }
}
