//
//  ImageStorageManager.swift
//  ByteCoinNew
//
//  Created by Egor Tushev on 21.02.2022.
//

import UIKit
import CryptoKit

final class ImageStorageManager {
    private lazy var cacheDirectory: URL = {
        guard let dir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            fatalError()
        }
        return URL(fileURLWithPath: dir, isDirectory: true)
    }()
    
    func saveImage(_ image: UIImage?, by id: String) {
        guard let data = image?.jpegData(compressionQuality: 0.9) else {
            fatalError()
        }
        
        let hash = generateFileName(by: id)
        
        let imageUrl = cacheDirectory.appendingPathComponent(hash).appendingPathExtension(".jpg")
        do {
            try data.write(to: imageUrl, options: .atomic)
        } catch {
            print("Error saving image: \(error)")
        }
    }
    
    func getImage(by id: String) -> UIImage? {
        let hash = generateFileName(by: id)
        
        let imageUrl = cacheDirectory.appendingPathComponent(hash).appendingPathExtension(".jpg")
        do {
            let data = try Data(contentsOf: imageUrl)
            let image = UIImage(data: data)
            return image
        } catch {
            print("Error loading image: \(error)")
            return nil
        }
    }
    
    private func generateFileName(by id: String) -> String {
        let digest = SHA256.hash(data: id.data(using: .utf8)!)
        let hash = digest.map { String(format: "%02X", $0) }.joined()
        return hash
    }
}
