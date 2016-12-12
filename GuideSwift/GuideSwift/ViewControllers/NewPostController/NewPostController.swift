//
//  NewPostController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 12.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class NewPostController: BaseController, UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var textViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIBarButtonItem!
    @IBOutlet weak var placeholder: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageButton: UIButton!
    fileprivate var postImage: UIImage?
    fileprivate var currentUserId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Graph.userObject { (object, error) in
            self.currentUserId = (object as? EGFUser)?.id
        }
    }
    
    @IBAction func createPost(_ sender: AnyObject) {
        errorLabel.text = nil
        
        guard let userId = currentUserId, let image = postImage, let imageData = UIImageJPEGRepresentation(image, 0.75),
            let desc = textView.text, !desc.isEmpty else { return }
        
        Graph.uploadImage(withData: imageData, title: "Photo", mimeType: "image/jpeg", kind: "photo") { (object, error) in
            if let file = object as? EGFFile, let fileId = file.id {
                Graph.createObject(withParameters: ["image":fileId, "desc": desc], forSource: userId, onEdge: "posts") { (object, error) in
                    if let _ = object as? EGFPost {
                        _ = self.navigationController?.popViewController(animated: true)
                    }
                    else {
                        self.show(error: error)
                    }
                }
            }
            else {
                self.show(error: error)
            }
        }
    }
    
    @IBAction func imageButtonDidTouchUp(_ sender: AnyObject) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.addAction(UIAlertAction(title: "Take Photo", style: .default) { (action) in
            self.getImage(withSource: .camera)
        })
        controller.addAction(UIAlertAction(title: "From Camera Roll", style: .default) { (action) in
            self.getImage(withSource: .photoLibrary)
        })
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    fileprivate func getImage(withSource sourceType: UIImagePickerControllerSourceType) {
        let controller = UIImagePickerController()
        controller.sourceType = sourceType
        controller.delegate = self
        controller.allowsEditing = true
        present(controller, animated: true, completion: nil)
    }
    
    fileprivate func show(error: NSError?) {
        if let err = error {
            self.errorLabel.text = err.localizedFailureReason
        }
        else {
            self.errorLabel.text = "An unknown error"
        }
    }
    
    fileprivate func updateSendButton() {
        sendButton.isEnabled = postImage != nil && !textView.text.isEmpty
    }
    
    // MARK:- UITextViewDelegate
    func textViewDidChange(_ textView: UITextView) {
        let size = textView.sizeThatFits(CGSize(width: textView.frame.size.width, height: 1000))
        let newHeight = min(100, max(50, size.height))
        
        if (newHeight != textViewHeight.constant) {
            textViewHeight.constant = newHeight
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
    
    // MARK:- UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) { () -> Void in
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage,
            let rect = info[UIImagePickerControllerCropRect] as? NSValue,
            let imageRef = image.cgImage?.cropping(to: rect.cgRectValue) else { return }
            
            let cropImage = UIImage(cgImage: imageRef)
            let maxWidth = self.view.frame.size.width - 40
            let imageRatio = cropImage.size.width / cropImage.size.height
            self.imageWidth.constant = min(maxWidth, cropImage.size.width)
            self.imageHeight.constant = self.imageWidth.constant / imageRatio
            self.imageButton.setImage(cropImage, for: .normal)
            self.imageButton.setTitle(nil, for: .normal)
            
            let imageMaxSize: CGFloat = 800
            
            if cropImage.size.width > imageMaxSize || cropImage.size.height > imageMaxSize {
                let w = min(imageMaxSize, cropImage.size.width)
                let h = w / imageRatio
                
                if let cropImageRef = cropImage.cgImage?.cropping(to: CGRect(x: 0, y: 0, width: w, height: h)) {
                    self.postImage = UIImage(cgImage: cropImageRef)
                }
            }
            else {
                self.postImage = cropImage
            }
            self.updateSendButton()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
