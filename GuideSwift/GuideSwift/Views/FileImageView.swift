//
//  FileImageView.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 16.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class FileImageView: UIImageView {
    
    fileprivate var indicator: UIActivityIndicatorView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = UIColor.hexColor(0x5E66B1)
        addSubview(indicator)
        addConstraint(NSLayoutConstraint(item: indicator, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: indicator, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    var file: EGFFile? {
        didSet {
            image = nil
            indicator.stopAnimating()
            
            guard let theFile = file else { return }
            
            indicator.startAnimating()

            SimpleFileManager.shared.image(withFile: theFile) { [weak self] (image, fromCache) in
                
                guard let strongSelf = self else { return }
                
                // We must be ensure we show appropriate image
                if theFile !== strongSelf.file { return }
                
                strongSelf.image = image
                strongSelf.indicator.stopAnimating()
                
                guard let _ = image else { return }
                
                if !fromCache {
                    strongSelf.alpha = 0
                    
                    UIView.animate(withDuration: 0.3, animations: {
                        strongSelf.alpha = 1
                    }) { (finished) in
                        strongSelf.alpha = 1
                    }
                }
            }
        }
    }
}
