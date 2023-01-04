//
//  HighlightedText.swift
//  RegistrationApp
//
//  Created by Кирилл Коновалов on 02.01.2023.
//

import SwiftUI
import MaterialComponents.MaterialTextControls_OutlinedTextFieldsTheming
import IQKeyboardManagerSwift

struct HighlightedText: View {
    let text: String
    let matching: String
    let matchingColor: Color
    var matching2 = ""
    let color: Color
    var isUnderline = false

    init(_ text: String, matching: String, matchingColor: Color, color: Color, isUnderline: Bool = false, matching2: String = "") {
        self.text = text
        self.matching = matching
        self.color = color
        self.matchingColor = matchingColor
        self.isUnderline = isUnderline
        self.matching2  = matching2
    }

    var body: some View {
        var tagged = text.replacingOccurrences(of: self.matching, with: "<SPLIT>>\(self.matching)<SPLIT>")
        
        if (matching2 != "") {
            tagged = tagged.replacingOccurrences(of: self.matching2, with: "<SPLIT>>\(self.matching2)<SPLIT>")
        }
        
        let split = tagged.components(separatedBy: "<SPLIT>")
        return split.reduce(Text("")) { (a, b) -> Text in
            guard !b.hasPrefix(">") else {
                if(isUnderline) {
                    return a + Text(b.dropFirst()).foregroundColor(matchingColor).underline()
                } else {
                    return a + Text(b.dropFirst()).foregroundColor(matchingColor).fontWeight(.medium)
                }
            }
            return a + Text(b).foregroundColor(color)
        }
    }
}




struct UIOutlinedTextField: UIViewRepresentable {
    func updateUIView(_ uiView: MDCOutlinedTextField, context: Context) {
        // nothing
        uiView.text = text
        uiView.isSecureTextEntry = isSecureEntry
        if self.secureNeeded {
            let eyeIcon = UIImageView(image: UIImage(named: isSecureEntry ? "password_show" : "password_hide"))
            uiView.trailingView = eyeIcon
            uiView.trailingViewMode = .whileEditing
            eyeIcon.isUserInteractionEnabled = true
        }
        
        if (isError) {
            uiView.setOutlineColor(UIColor.red, for: .normal)
            uiView.setFloatingLabelColor(UIColor.red, for: .normal)
            //uiView.containerRadius = 8
            uiView.setOutlineColor(UIColor.red, for: .editing)
            uiView.setFloatingLabelColor(UIColor.red, for: .editing)
            //uiView.label.text = errorText
        } else {
            uiView.label.text = label
            uiView.label.font = UIFont(name: "WorldClass-Regular", size: 16)
            //uiView.containerRadius = 8
            uiView.setOutlineColor(UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1), for: .normal)
            uiView.setFloatingLabelColor(UIColor(red: 185/255, green: 185/255, blue: 186/255, alpha: 1), for: .normal)
            uiView.setOutlineColor(UIColor(red: 185/255, green: 185/255, blue: 186/255, alpha: 1), for: .editing)
            uiView.setFloatingLabelColor(UIColor(red: 185/255, green: 185/255, blue: 186/255, alpha: 1), for: .editing)
        }
    }
    
    var placeholder: String
    var label: String
    var tmpText = ""
    var secureNeeded: Bool
    var keyboardType: UIKeyboardType
    @Binding var text: String
    @Binding var isError: Bool
    @Binding var errorText: String
    @Binding var keyboardShow: Bool
    var scrollHeight = 10.0
    @Binding var isSecureEntry: Bool
    
    init(_ title: String, text: Binding<String>, label: String, isSecureEntry: Binding<Bool>, secureNeeded: Bool, isError: Binding<Bool>, scrollHeight: Double, errorText: Binding<String>, keyboardShow: Binding<Bool>, keyboardType: UIKeyboardType = .default) {
        self.placeholder = title
        self._text = text
        self.label = label
        self._isSecureEntry = isSecureEntry
        self._isError = isError
        self._errorText = errorText
        self._keyboardShow = keyboardShow
        tmpText = text.wrappedValue
        self.scrollHeight = scrollHeight
        self.secureNeeded = secureNeeded
        self.keyboardType = keyboardType
        print(isSecureEntry)
    }
    
    func makeUIView(context: Context) -> MDCOutlinedTextField {
        let textField = MDCOutlinedTextField()

        textField.keyboardType = keyboardType
        textField.label.text = label
        textField.placeholder = placeholder
        print(self.isSecureEntry)
        textField.isSecureTextEntry = self.isSecureEntry
        
        textField.leadingAssistiveLabel.text = ""
        //textField.containerRadius = 8
        textField.keyboardDistanceFromTextField = CGFloat(self.scrollHeight)
        textField.setOutlineColor(UIColor(red: 232/255, green: 232/255, blue: 232/255, alpha: 1), for: .normal)
        textField.setOutlineColor(UIColor(red: 185/255, green: 185/255, blue: 186/255, alpha: 1), for: .editing)
        textField.setFloatingLabelColor(UIColor(red: 185/255, green: 185/255, blue: 186/255, alpha: 1), for: .normal)
        textField.setNormalLabelColor(UIColor(red: 185/255, green: 185/255, blue: 186/255, alpha: 1), for: .normal)
        textField.font = UIFont(name: "WorldClass-Regular", size: 16)
        
        if self.secureNeeded {
            let eyeIcon = UIImageView(image: UIImage(named: isSecureEntry ? "password_show" : "password_hide"))
            textField.trailingView = eyeIcon
            textField.trailingViewMode = .whileEditing
            eyeIcon.isUserInteractionEnabled = true
        }
        
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange(_:)), for: .editingChanged)
        textField.delegate = context.coordinator
        textField.sizeToFit()
        
        return textField
    }
    
    func tap() {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator($text, $keyboardShow)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var text: Binding<String>
        var keybordShow: Binding<Bool>
        var isSecureEntry = false
        
        init(_ text: Binding<String>, _ keybordShow: Binding<Bool>) {
            self.text = text
            self.keybordShow = keybordShow
        }
        
        // Update model.text when textField.text is changed
        @objc func textFieldDidChange(_ textField: UITextField) {
            self.text.wrappedValue = textField.text ?? ""
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            
            // prevent backspace clearing the password
            if (range.location > 0 && range.length == 1 && string.count == 0) {
                // iOS is trying to delete the entire string
                textField.text = newString
                self.text.wrappedValue = textField.text ?? ""
                
                return false
            }
            
            // prevent typing clearing the pass
            if range.location == textField.text?.count {
                textField.text = newString
                self.text.wrappedValue = textField.text ?? ""
                
                return false
            }
            
            self.text.wrappedValue = textField.text ?? ""
            
            return true
        }
        
        // Example UITextFieldDelegate method
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            keybordShow.wrappedValue = false
            return true
        }
        
        @objc func changeIcon(_ value: Bool) {
            
        }
    }
}
