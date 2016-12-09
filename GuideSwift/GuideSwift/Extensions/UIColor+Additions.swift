//
//  UIColor+Additions.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

extension UIColor {
    class func hexColor(_ hexColor: Int) -> UIColor {
        let r: CGFloat = (CGFloat((hexColor & 0xFF0000) >> 16)) / 255.0
        let g: CGFloat = (CGFloat((hexColor & 0xFF00) >> 8)) / 255.0
        let b: CGFloat = CGFloat(hexColor & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}

