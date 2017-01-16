//
//  EGFHumanName+Additions.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 13.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import Foundation

extension EGFHumanName {

    func fullName() -> String? {
        var fullName = ""

        if let value = family {
            fullName = value
        }
        if let value = given {
            fullName += fullName.isEmpty ? value : " " + value
        }
        return fullName.isEmpty ? nil : fullName
    }
}
