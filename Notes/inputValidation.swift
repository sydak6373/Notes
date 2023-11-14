//
//  inputValidation.swift
//  Notes
//
//  Created by JoyDev on 14.11.2023.
//

import UIKit
import SnapKit

protocol InputValidationDelegate: AnyObject {
    func showError(_ message: String)
}

class InputValidation {
    
    static let shared = InputValidation()
    
    weak var delegate: InputValidationDelegate?
    
    private init() {}
    
    public func validateAndSaveData(login: String, email: String?, password: String, repeatedPassword: String?) -> Bool {
        // Проверка логина и пароля
        guard !login.isEmpty, !password.isEmpty else {
            delegate?.showError("Fields login or password are not filled")
            return false
        }
        
        // Для регистрации
        if let email = email, let repeatedPassword = repeatedPassword{
            guard emailIsValid(email) else {
                delegate?.showError("Email is not valid")
                return false
            }
            guard passwordIsValid(password) else {
                delegate?.showError("Password should be at least 8 characters, contain at least one uppercase letter, one lowercase letter, and one number.")
                return false
            }
            guard password == repeatedPassword else {
                delegate?.showError("Passwords do not match each other")
                return false
            }
        }
        return true
    }
    
    
    func emailIsValid(_ email: String) -> Bool {
        let emailRegExp: String = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegExp)
        return emailTest.evaluate(with: email)
    }
    
    
    func passwordIsValid(_ password: String) -> Bool {
        let passwordRegExp: String = "^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}$"
        let passwordTest = NSPredicate(format:"SELF MATCHES %@", passwordRegExp)
        return passwordTest.evaluate(with: password)
    }
}
