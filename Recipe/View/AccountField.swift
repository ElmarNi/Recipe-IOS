//
//  AccountField.swift
//  Recipe
//
//  Created by Elmar Ibrahimli on 14.06.23.
//

import UIKit

class AccountField: UITextField {

    enum FieldType {
        case firstname
        case lastname
        case email
        case username
        case password
        var placeholder: String {
            switch self {
            case .firstname:
                return "Firstname"
            case .lastname:
                return "Lastname"
            case .email:
                return "Email"
            case .username:
                return "Username"
            case .password:
                return "Password"
            }
        }
    }
    
    private let fieldType: FieldType
    init(fieldType: FieldType) {
        self.fieldType = fieldType
        super.init(frame: .zero)
        
        self.backgroundColor = .secondarySystemBackground
        self.layer.cornerRadius = 10
        self.returnKeyType = .done
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        self.placeholder = fieldType.placeholder
        self.leftViewMode = .always
        self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: self.frame.size.height))
        
        switch fieldType {
        case .email:
            self.keyboardType = .emailAddress
            self.textContentType = .emailAddress
        case .password:
            self.textContentType = .oneTimeCode
            self.isSecureTextEntry = true
        default:
            break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
