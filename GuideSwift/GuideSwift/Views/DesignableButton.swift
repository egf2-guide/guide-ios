//
//  DesignableButton.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableButton: UIButton {

    @IBInspectable var backgroundNormalColor: UIColor? {
        didSet {
            if let color = backgroundNormalColor {
                setBackgroundImage(UIImage.image(withColor: color), for: .normal)
            }
        }
    }

    @IBInspectable var backgroundDisableColor: UIColor? {
        didSet {
            if let color = backgroundDisableColor {
                setBackgroundImage(UIImage.image(withColor: color), for: .disabled)
            }
        }
    }

    @IBInspectable var backgroundHighlightColor: UIColor? {
        didSet {
            if let color = backgroundHighlightColor {
                setBackgroundImage(UIImage.image(withColor: color), for: .highlighted)
            }
        }
    }

    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
}
