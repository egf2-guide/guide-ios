//
//  ResetPasswordController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 20.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class ResetPasswordController: BaseController, UITextFieldDelegate {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var tokenTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var resetButton: UIButton!

    @IBAction func changePassword(_ sender: AnyObject) {
        errorLabel.text = nil

        guard let token = tokenTextField.text, let password = passwordTextField.text, let confirm = confirmTextField.text else { return }

        if password != confirm {
            errorLabel.text = "New password and confirm password does not match"
            return
        }
        view.endEditing(true)

        ProgressController.show()
        Graph.resetPassword(withToken: token, newPassword: password) { (_, error) in
            ProgressController.hide()

            if let err = error {
                self.errorLabel.text = err.localizedFailureReason
            } else {
                let title = "Password has been succesfully changed"
                let message = "Please use your new password to login"
                let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default, handler: { (_) -> Void in
                    _ = self.navigationController?.popToRootViewController(animated: true)
                })
                controller.addAction(ok)
                self.present(controller, animated: true, completion: nil)
            }
        }
    }

    @IBAction func textDidChange(_ sender: UITextField) {
        resetButton.isEnabled = !(tokenTextField.text ?? "").isEmpty &&
            !(passwordTextField.text ?? "").isEmpty &&
            !(confirmTextField.text ?? "").isEmpty
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
