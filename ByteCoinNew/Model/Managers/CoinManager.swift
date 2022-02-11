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

class CoinManager: CoinProtocol {
    
    let cryptoCurrencies: [String] = ["BTC", "ETH", "LTC", "DOGE", "BNB", "BCH"]
    
    private static let baseURL = "https://rest.coinapi.io"
    private static var apiKey: String = ""
    
    init(apiKey: String) {
        Self.apiKey = apiKey
    }
    
    //MARK: - Fetching data

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
        let url = "/v1/assets"
        request(withUrl: url, completion: completion)
    }
    
    private func getImagesForCurrencies(size: Int = 25, completion: @escaping (Result<[Image], NWError>) -> Void) {
        let url = "/v1/assets/icons/\(size)"
        request(withUrl: url, completion: completion)
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
    
    func getCoinPrice(for currency: String, to crypto: String = "BTC", completion: @escaping (Result<CoinModel, NWError>) -> Void) {
        let urlCoin = "/v1/exchangerate/\(crypto)/\(currency)"
        request(withUrl: urlCoin) { (result: Result<CoinData, NWError>) in
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
        
        let url = "/v1/exchangerate/\(coin)/\(currency)/history?period_id=1HRS&time_start=\(getDayBefore(timeEnd))&time_end=\(timeEnd)"
        request(withUrl: url) { [weak self] (result: Result<[TimeseriesData], NWError>) in
            guard let self = self else { return }
            var history: [HistoryData] = []
            switch result {
            case .success(let data):
                data.forEach { ex in
                    let timeOpen = self.transformStringToDate(ex.timeOpen)
                    history.append(HistoryData(timeOpen: timeOpen, rateOpen: ex.rateOpen))
                }
                completion(.success(history))
            case .failure(let e):
                completion(.failure(e))
            }
        }
    }
    
    private func request<T: Decodable>(withUrl url: String, completion: @escaping (Result<T, NWError>) -> Void) {
        if let requestUrl = URL(string: "\(CoinManager.baseURL)".appending(url)) {
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "GET"
            request.addValue(CoinManager.apiKey, forHTTPHeaderField: "X-CoinAPI-Key")
            
            // Perform request
            let urlSession = URLSession(configuration: .default)
            let task = urlSession.dataTask(with: request as URLRequest) { data, response, error in
                if let _ = error {
                    completion(.failure(.unableToComplete))
                    return
                }
                guard let safeData = data else {
                    completion(.failure(.invalidData))
                    return
                }
                do {
                    let decoder = JSONDecoder()
                    let decodedData = try decoder.decode(T.self, from: safeData)
                    let data = decodedData
                    completion(.success(data))
                } catch {
                    completion(.failure(.invalidData))
                }
            }
            task.resume()
        } else {
            completion(.failure(.invalidURL))
            return
        }
    }
    
    //MARK: - transform Date
    
    private func transformStringToDate(_ str: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        if let date = dateFormatter.date(from: str) {
            return date
        }
        return Date()
    }
    
    private func getDayBefore(_ value: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSS'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let date = dateFormatter.date(from: value) {
            let dayBefore = date.addingTimeInterval(-86400.0)
            return dateFormatter.string(from: dayBefore)
        } else {
            return "There was an error decoding the string"
        }
    }
}
