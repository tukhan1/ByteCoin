//
//  NetworkManager.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 15.02.2022.
//

import Foundation

class NetworkManager {
    private let baseUrl: URL
    private let apiKey: String
    
    init (baseUrl: URL, apiKey: String) {
        self.baseUrl = baseUrl
        self.apiKey = apiKey
    }
    
    func request<T: Decodable>(withUrl url: String, completion: @escaping (Result<T, NWError>) -> Void) {
        if let requestUrl =  URL(string: url, relativeTo: baseUrl) {
            var request = URLRequest(url: requestUrl)
            request.httpMethod = "GET"
            request.addValue(apiKey, forHTTPHeaderField: "X-CoinAPI-Key")
            
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
}
