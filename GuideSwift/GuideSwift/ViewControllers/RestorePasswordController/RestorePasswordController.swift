//
//  RestorePasswordController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 20.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class RestorePasswordController: BaseController, UITextFieldDelegate {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var restoreButton: UIButton!
    
    @IBAction func restorePassword(_ sender: AnyObject) {
        errorLabel.text = nil
        
        guard let email = emailTextField.text else { return }
        
        view.endEditing(true)
        
        ProgressController.show()
        Graph.restorePassword(withEmail: email) { (object, error) in
            ProgressController.hide()
            
            guard let err = error else {
                self.performSegue(withIdentifier: "ResetPassword", sender: nil)
                return
            }
            self.errorLabel.text = err.localizedFailureReason
        }
    }
    
    @IBAction func textDidChange(_ sender: UITextField) {
        restoreButton.isEnabled = (emailTextField.text ?? "").isEmpty == false
    }
    
    // MARK:- UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
