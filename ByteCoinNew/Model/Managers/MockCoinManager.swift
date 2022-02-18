//
//  MockCoinManager.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 11.02.2022.
//

import Foundation

class SuccessMockCoinManager: CoinProtocol {
    
    let cryptoCurrencies = ["BTC", "ETH"]
    
    func getCurrencies(completion: @escaping (Result<[Currency], NWError>) -> Void) {
        let path = "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.freeiconspng.com%2Fimg%2F35409&psig=AOvVaw3ZPcLtCUdefAG82wLmo3IH&ust=1644662371795000&source=images&cd=vfe&ved=0CAsQjRxqFwoTCJCnx_u69_UCFQAAAAAdAAAAABAu"
        completion(.success([Currency(designation: "BUB", name: "Buble", imageUrl: URL(string: path))]))
    }
    
    func getCoinPrice(for currency: String, to crypto: String, completion: @escaping (Result<CoinModel, NWError>) -> Void) {
        
        completion(.success(CoinModel(date: "2018-03-09T23:34:52.5800000Z", currency: "Buble", price: 1337.77)))
    }
    
    func getHistoryPricePerHour(for coin: String,
                                to currency: String,
                                timeEnd: String,
                                completion: @escaping (Result<[HistoryData], NWError>) -> Void) {
        completion(.success([HistoryData(timeOpen: Date(), rateOpen: 133777.77)]))
    }
}

class FailureMockCoinManager: CoinProtocol {
    
    let cryptoCurrencies = ["BTC"]
    
    func getCurrencies(completion: @escaping (Result<[Currency], NWError>) -> Void) {
        completion(.failure(NWError.unableToComplete))
    }
    
    func getCoinPrice(for currency: String, to crypto: String, completion: @escaping (Result<CoinModel, NWError>) -> Void) {
        completion(.failure(NWError.invalidURL))
    }
    
    func getHistoryPricePerHour(for coin: String,
                                to currency: String,
                                timeEnd: String,
                                completion: @escaping (Result<[HistoryData], NWError>) -> Void) {
        completion(.failure(NWError.invalidURL))
    }
}

