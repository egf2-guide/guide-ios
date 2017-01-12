//
//  ResendEmailVerificationController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 10.01.17.
//  Copyright © 2017 eigengraph. All rights reserved.
//

import UIKit

class ResendEmailVerificationController: BaseController {
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func resendEmailVerification(_ sender: AnyObject) {
        errorLabel.text = nil
        
        ProgressController.show()
        Graph.resendEmailVerification { (_, error) in
            ProgressController.hide()
            
            if let err = error {
                self.errorLabel.text = err.localizedFailureReason
            }
            else {
                let title = "Email has been successfully sent"
                let message = "Please check your email"
                let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
                    _ = self.navigationController?.popToRootViewController(animated: true)
                })
                controller.addAction(ok)
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
}
