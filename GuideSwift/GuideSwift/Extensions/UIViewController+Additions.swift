//
//  UIViewController+Additions.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 26.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showConfirm(withTitle title: String, message: String, action confirmAction: @escaping () -> Void) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Yes", style: .default) { (action) -> Void in
            confirmAction()
        }
        controller.addAction(alertAction)
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(controller, animated: true, completion: nil)
    }
    
    func showAlert(withTitle title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(controller, animated: true, completion: nil)
    }
}
