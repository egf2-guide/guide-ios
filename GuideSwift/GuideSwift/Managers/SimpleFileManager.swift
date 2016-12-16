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
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).last!.appendingPathComponent("EGF2Images")
    }()
    
    init() {
        try? FileManager.default.createDirectory(at: cachesURL, withIntermediateDirectories: false, attributes: nil)
    }
    
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
        
        func handle(data: Data?, isCached: Bool) {
            if let imageData = data, let image = UIImage(data: imageData) {
                DispatchQueue.main.async { completion(image, isCached) }
                
                if !isCached {
                    try? imageData.write(to: localURL)
                }
            }
            else {
                DispatchQueue.main.async { completion(nil, isCached) }
            }
        }
        
        if doesFileExist(withUrl: localURL) {
            DispatchQueue.global().async {
                handle(data: self.fileData(withUrl: localURL), isCached: true)
            }
        }
        else {
            let configuration = URLSessionConfiguration.default
            configuration.urlCache = nil
            configuration.httpCookieStorage = nil
            let session = URLSession(configuration: configuration)
            // TODO use URLSession.shared
            session.dataTask(with: url, completionHandler: {(data, response, error) in
                DispatchQueue.global().async {
                    handle(data: data, isCached: false)
                }
            }).resume()
        }
    }
    
    func deleteAllFiles() {
        try? FileManager.default.removeItem(at: cachesURL)
        try? FileManager.default.createDirectory(at: cachesURL, withIntermediateDirectories: false, attributes: nil)
    }
}
