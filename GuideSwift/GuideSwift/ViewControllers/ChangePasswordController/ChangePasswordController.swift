//
//  ChangePasswordController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 20.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class ChangePasswordController: BaseController, UITextFieldDelegate {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var changeButton: UIBarButtonItem!

    @IBAction func changePassword(_ sender: AnyObject) {
        errorLabel.text = nil

        guard let old = oldPassword.text, let new = newPassword.text, let confirm = confirmPassword.text else { return }

        if new != confirm {
            errorLabel.text = "New password and confirm password does not match"
            return
        }
        view.endEditing(true)

        ProgressController.show()
        Graph.change(oldPassword: old, withNewPassword: new) { (_, error) in
            ProgressController.hide()

            if let err = error {
                self.errorLabel.text = err.localizedFailureReason
            } else {
                let controller = UIAlertController(title: "Success", message: "Password has been changed", preferredStyle: .alert)
                let ok = UIAlertAction(title: "Ok", style: .default, handler: { (_) -> Void in
                    _ = self.navigationController?.popViewController(animated: true)
                })
                controller.addAction(ok)
                self.present(controller, animated: true, completion: nil)
            }
        }
    }

    @IBAction func textDidChange(_ sender: UITextField) {
        changeButton.isEnabled = !(oldPassword.text ?? "").isEmpty &&
            !(newPassword.text ?? "").isEmpty &&
            !(confirmPassword.text ?? "").isEmpty
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
