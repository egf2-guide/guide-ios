//
//  BaseController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class BaseController: UIViewController {

    @IBOutlet weak var buttomOffset: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func observe(eventName name: NSNotification.Name, withSelector selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let barButton = UIBarButtonItem()
        barButton.title = ""
        navigationController?.navigationBar.topItem?.backBarButtonItem = barButton
    }

    func toolbar(withButtonTitle title: String?, selector: Selector) -> UIToolbar {
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let button = UIBarButtonItem(title: title, style: .plain, target: self, action: selector)
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
        button.tintColor = UIColor.hexColor(0x5E66B1)
        toolbar.items = [space, button]
        return toolbar
    }

    fileprivate func valuesOf(notification: Notification) -> (keyboardHeight: CGFloat, duration: Double)? {
        guard let keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height else { return nil }
        guard let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue else { return nil }
        return (keyboardHeight, duration)
    }

    func keyboardWillShow(_ notification: Notification) {
        guard let constraint = buttomOffset, let values = valuesOf(notification: notification) else { return }
        constraint.constant = values.keyboardHeight
        UIView.animate(withDuration: values.duration) { self.view.layoutIfNeeded() }
    }

    func keyboardWillHide(_ notification: Notification) {
        guard let constraint = buttomOffset, let values = valuesOf(notification: notification) else { return }
        constraint.constant = 0
        UIView.animate(withDuration: values.duration) { self.view.layoutIfNeeded() }
    }
}
