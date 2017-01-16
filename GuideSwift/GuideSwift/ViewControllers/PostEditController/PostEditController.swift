//
//  PostEditController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 28.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class PostEditController: BaseController, UITextViewDelegate {
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var updateButton: UIBarButtonItem!
    @IBOutlet weak var placeholder: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var textView: UITextView!

    var post: EGFPost?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.layoutIfNeeded()
        textView.text = post?.desc
        textViewDidChange(textView)
    }

    @IBAction func updatePost(_ sender: AnyObject) {
        errorLabel.text = nil
        view.endEditing(true)

        guard let postId = post?.id, let desc = textView.text else { return }

        ProgressController.show()
        Graph.updateObject(withId: postId, parameters: ["desc": desc]) { (_, error) in
            ProgressController.hide()

            if let err = error {
                self.errorLabel.text = err.localizedFailureReason
            } else {
                _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }

    fileprivate func updateSendButton() {
        updateButton.isEnabled = !textView.text.isEmpty && textView.text != post?.desc
    }

    // MARK: - UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: 1000))
        let newHeight = min(100, max(50, size.height))

        if newHeight != textViewHeight.constant {
            textViewHeight.constant = newHeight
            view.layoutIfNeeded()
            textView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        }
        placeholder.isHidden = !textView.text.isEmpty
        updateSendButton()
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
