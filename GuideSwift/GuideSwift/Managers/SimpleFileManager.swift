//
//  SimpleFileManager.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 13.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class SimpleFileManager {
    static let shared = SimpleFileManager()
    lazy var cachesURL : URL = {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).last!
    }()
    
    fileprivate func doesFileExist(withUrl url: URL) -> Bool {
        do {
            return try url.checkResourceIsReachable()
        }
        catch {
            return false
        }
    }
    
    fileprivate func fileData(withUrl url: URL) -> Data? {
        do {
            return try Data(contentsOf: url)
        }
        catch {
            return nil
        }
    }
    
    func image(withFile file: EGFFile, completion: @escaping (_ image: UIImage?, _ fromCache: Bool) -> Void) {
        guard let urlString = file.url, let fileId = file.id, let url = URL(string: urlString) else {
            completion(nil, false)
            return
        }
        let localURL = cachesURL.appendingPathComponent(fileId)

        if doesFileExist(withUrl: localURL) {
            if let imageData = fileData(withUrl: localURL), let image = UIImage(data: imageData) {
                completion(image, true)
            }
            else {
                completion(nil, true)
            }
        }
        else {
            URLSession.shared.dataTask(with: url, completionHandler: {(data, response, error) in
                if let imageData = data, let image = UIImage(data: imageData) {
                    DispatchQueue.main.async { completion(image, false) }
                    DispatchQueue.global().async {
                        try? imageData.write(to: localURL)
                    }
                }
                else {
                    DispatchQueue.main.async { completion(nil, false) }
                }
            }).resume()
        }
    }
}
