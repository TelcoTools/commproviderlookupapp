//
//  TextFieldWithDoneButton.swift
//  commproviderlookup
//
//  Created by Yannick McCabe-Costa on 10/10/2024.
//

import Foundation
import SwiftUI
import UIKit

struct TextFieldWithDoneButton: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var isNumeric: Bool // New parameter to determine keyboard type

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: TextFieldWithDoneButton

        init(parent: TextFieldWithDoneButton) {
            self.parent = parent
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }

        @objc func dismissKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.delegate = context.coordinator
        textField.keyboardType = isNumeric ? .numberPad : .default // Set appropriate keyboard type
        
        // Toolbar with "Done" button
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: context.coordinator, action: #selector(Coordinator.dismissKeyboard))
        toolbar.items = [UIBarButtonItem.flexibleSpace(), doneButton]
        textField.inputAccessoryView = toolbar
        
        // Set height and other properties
        textField.setContentHuggingPriority(.defaultHigh, for: .vertical)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 40).isActive = true  // Fixed height

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
}
