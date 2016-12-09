//
//  BaseController.swift
//  GuideSwift
//
//  Created by LuzanovRoman on 09.12.16.
//  Copyright © 2016 eigengraph. All rights reserved.
//

import UIKit

class BaseController: UIViewController {
    
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
}
