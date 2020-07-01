//
//  UIViewController+Keyboard.swift
//  pixabay
//
//  Created by Xuwei Liang on 2/7/20.
//  Copyright © 2020 Wisetree Solutions Pty Ltd. All rights reserved.
//

import UIKit

extension UIViewController {

    /// call this method in viewDidLoad to add ability to dismiss keyboard by tapping on viewController
     func enableTapToKeyboardDismiss() {
         let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
         tap.cancelsTouchesInView = false
         view.addGestureRecognizer(tap)
     }
     
     /// method to dismiss keyboard
     @objc func dismissKeyboard() {
         view.endEditing(true)
     }
}
