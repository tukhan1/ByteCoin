//
//  CoinProtocol.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 11.02.2022.
//

import Foundation

enum NWError: String, Error {
    case invalidURL = "Something wrong with URL"
    case unableToComplete = "Received ERROR"
    case invalidData = "Something wrong with Data"
}

protocol CoinProtocol {
    var cryptoCurrencies: [String] { get }
    func getCurrencies(completion: @escaping (Result<[Currency], NWError>) -> Void)
    func getCoinPrice(for currency: String, to crypto: String, completion: @escaping (Result<CoinModel, NWError>) -> Void)
    func getHistoryPricePerHour(for coin: String,
                                to currency : String,
                                timeEnd: String,
                                completion: @escaping (Result<[HistoryData], NWError>) -> Void)
}
