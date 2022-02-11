//
//  MockCoinManager.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 11.02.2022.
//

import Foundation

class MockCoinManager: CoinProtocol {
    
    let cryptoCurrencies = ["BTC"]
    
    func getCurrencies(completion: @escaping (Result<[Currency], NWError>) -> Void) {
        let a = 1
        let b = 2
        if b < a {
            completion(.failure(NWError.unableToComplete))
        } else {
            completion(.success([Currency(designation: "BUB", name: "Buble", imageUrl: URL(string: "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.freeiconspng.com%2Fimg%2F35409&psig=AOvVaw3ZPcLtCUdefAG82wLmo3IH&ust=1644662371795000&source=images&cd=vfe&ved=0CAsQjRxqFwoTCJCnx_u69_UCFQAAAAAdAAAAABAu"))]))
        }
    }
    
    func getCoinPrice(for currency: String, to crypto: String, completion: @escaping (Result<CoinModel, NWError>) -> Void) {
        let a = 1
        let b = 2
        if b > a {
            completion(.failure(NWError.invalidURL))
        } else {
            completion(.success(CoinModel(date: "2018-03-09T23:34:52.5800000Z", currency: "Buble", price: 1337.77)))
        }
    }
    
    func getHistoryPricePerHour(for coin: String, to currency: String, timeEnd: String, completion: @escaping (Result<[HistoryData], NWError>) -> Void) {
        let a = 1
        let b = 2
        if b < a {
//            completion(.failure(NWError.invalidData))
        } else {
            completion(.success([HistoryData(timeOpen: Date(), rateOpen: 133777.77)]))
        }
    }
}
