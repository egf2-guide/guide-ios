//
//  UserController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class UserController: BaseController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    fileprivate var currentUserObject: EGFUser?
    fileprivate var changedUserObject: EGFUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Graph.userObject { (object, _) in
            guard let user = object as? EGFUser else { return }
            self.firstNameTextField.text = user.name?.given
            self.lastNameTextField.text = user.name?.family
            self.setCurrentUser(user)
        }
    }
    
    fileprivate func setCurrentUser(_ user: EGFUser) {
        currentUserObject = user
        changedUserObject = user.copyGraphObject()
        userDataDidUpdate()
    }
    
    @IBAction func save(_ sender: AnyObject) {
        guard let changedUser = changedUserObject, let id = changedUser.id else { return }
        view.endEditing(true)
        
        Graph.updateObject(withId: id, object: changedUser) { (object, error) in
            guard let user = object as? EGFUser else { return }
            self.setCurrentUser(user)
        }
    }
    
    @IBAction func textDidChange(_ sender: UITextField) {
        userDataDidUpdate()
    }
    
    fileprivate func userDataDidUpdate() {
        guard let currentUser = currentUserObject, let changedUser = changedUserObject else { return }
        
        if changedUser.name == nil {
            changedUser.name = EGFHumanName()
        }
        changedUser.name?.given = firstNameTextField.text
        changedUser.name?.family = lastNameTextField.text
        saveButton.isEnabled = !currentUser.isEqual(graphObject: changedUser)
    }
}

