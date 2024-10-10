//
//  KeyboardToolbarHelper.swift
//  commproviderlookup
//
//  Created by Yannick McCabe-Costa on 10/10/2024.
//

import Foundation
import SwiftUI
import UIKit

struct KeyboardToolbarHelper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        
        // Add the toolbar with "Done" button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: viewController, action: #selector(viewController.dismissKeyboard))
        ]
        
        UITextField.appearance().inputAccessoryView = toolbar
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

}

extension UIViewController {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
