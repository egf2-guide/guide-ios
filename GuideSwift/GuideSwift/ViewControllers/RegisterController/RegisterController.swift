//
//  RegisterController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class RegisterController: BaseController, UITextFieldDelegate {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!

    fileprivate let birthDatePicker = UIDatePicker()
    fileprivate var birthDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        birthDatePicker.datePickerMode = .date
        birthDatePicker.addTarget(self, action: #selector(birthDatePickerDidChange(_:)), for: .valueChanged)
        dobTextField.inputView = birthDatePicker
        dobTextField.inputAccessoryView = toolbar(withButtonTitle: "Done", selector: #selector(didPressDoneButton))
    }

    @IBAction func register(_ sender: AnyObject) {
        errorLabel.text = nil

        guard let firstName = firstNameTextField.text,
            let lastName = lastNameTextField.text,
            let password = passwordTextField.text,
            let email = emailTextField.text,
            let date = birthDate,
            firstName.isEmpty == false,
            lastName.isEmpty == false,
            password.isEmpty == false,
            email.isEmpty == false else {
            errorLabel.text = "All fields are required"
            return
        }
        ProgressController.show()
        Graph.register(withFirstName: firstName, lastName: lastName, email: email, dateOfBirth: date, password: password) { (_, error) in
            if let err = error {
                self.errorLabel.text = err.localizedFailureReason
                ProgressController.hide()
            } else {
                self.getUserObject()
            }
        }
    }

    fileprivate func getUserObject() {
        Graph.userObject { (_, error) in
            if let err = error {
                self.errorLabel.text = "Can't get user. \(err.localizedDescription)"
            } else {
                self.dismiss(animated: true, completion: nil)
            }
            ProgressController.hide()
        }
    }

    func didPressDoneButton() {
        view.endEditing(true)
    }

    @IBAction func birthDatePickerDidChange(_ sender: UIDatePicker) {
        updateBirthDate(withDate: sender.date)
    }

    fileprivate func updateBirthDate(withDate date: Date) {
        birthDate = date
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateStyle = .medium
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dobTextField.text = dateFormatter.string(from: date)
    }

    // MARK: - UITextFieldDelegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === dobTextField {
            birthDatePicker.date = birthDate ?? Date()
        }
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === dobTextField {
            updateBirthDate(withDate: birthDatePicker.date)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
