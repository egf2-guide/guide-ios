//
//  LoginController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class LoginController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func login(_ sender: AnyObject) {
        errorLabel.text = nil
        
        guard let email = emailTextField.text, let password = passwordTextField.text, email.isEmpty == false, password.isEmpty == false else {
            errorLabel.text = "Enter email and password"
            return
        }
        Graph.login(withEmail: email, password: password) { (object, error) in
            if let err = error {
                self.errorLabel.text = err.localizedFailureReason
            }
            else {
                self.getUserObject()
            }
        }
    }
    
    func getUserObject() {
        Graph.userObject { (object, error) in
            if let err = error {
                self.errorLabel.text = "Can't get user. \(err.localizedDescription)"
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
