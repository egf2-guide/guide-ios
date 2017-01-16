//
//  Array+Additions.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 29.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import Foundation

extension Array where Element : Equatable {

    mutating func remove(_ object: Element) {
        for i in 0..<count {
            if object == self[i] {
                remove(at: i)
                break
            }
        }
    }
}
