//
//  ProgressController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 13.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class ProgressController: UIViewController {
    static fileprivate var counter = 0
    static fileprivate var controller: ProgressController = {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProgressController") as! ProgressController
    }()
    
    class func show() {
        counter += 1
        
        guard let topController = topController() else { return }
        
        if controller.view.superview == nil {
            topController.view.addSubview(controller.view)
            controller.view.alpha = 0
        }
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [.beginFromCurrentState], animations: {
            controller.view.alpha = 1
        }, completion: nil)
    }
    
    class func hide() {
        if counter > 0 {
            counter -= 1
        }
        if counter == 0 && controller.view.superview != nil {
            UIView.animate(withDuration: 0.25, delay: 0.0, options: [.beginFromCurrentState], animations: { () -> Void in
                controller.view.alpha = 0
            }) { (finished) -> Void in
                if counter == 0 {
                    controller.view.removeFromSuperview()
                }
            }
        }
    }
    
    fileprivate class func topController() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}
