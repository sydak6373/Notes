//
//  ViewController.swift
//  Notes
//
//  Created by JoyDev on 14.11.2023.
//

import UIKit
import SnapKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, InputValidationDelegate {
    
    var textFieldValues: [TextFieldValue] = []
    
    enum TextFieldValue {
            case login(String)
            case email(String)
            case password(String)
    }
    
    let segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Вход", "Регистрация"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .yellow
        return segmentedControl
    }()
    
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor(red: 241/255, green: 235/255, blue: 228/255, alpha: 1)
        return tableView
    }()

    private var selectedOption: Option = .login
        
    let button: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .yellow
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.black, for: .normal)
        
        return button
            
    }()
    
    let switchView: UISwitch = {
        let switchView = UISwitch()
        return switchView
    }()

    let switchLabel: UILabel = {
        let label = UILabel()
        label.text = "Согласен с правилами"
        label.numberOfLines = 0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        if let login = UserDefaults.standard.string(forKey: "login") {
               textFieldValues.append(.login(login))
           }
           if let email = UserDefaults.standard.string(forKey: "email") {
               textFieldValues.append(.email(email))
           }
           if let password = UserDefaults.standard.string(forKey: "password") {
               textFieldValues.append(.password(password))
           }
        InputValidation.shared.delegate = self
        tableView.reloadData()
        
    }
    
    func showError(_ message: String) {
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true, completion: nil)
    }

    private func configureView() {
        view.backgroundColor = UIColor(red: 241/255, green: 235/255, blue: 228/255, alpha: 1)
        
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(button)
        

        segmentedControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(80)
            make.width.equalTo(200)
            make.height.equalTo(35)
        }

        tableView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(segmentedControl.snp.bottom).offset(40)
            make.width.equalTo(250)
            make.height.equalTo(200)
            
        }
        
        button.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(50)
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(30)
        }
        
        button.addTarget(self, action: #selector(buttonPressed(_:)), for: .touchUpInside)
        
        switchView.addTarget(self, action: #selector(switchViewValueChanged(_:)), for: .valueChanged)
        switchView.onTintColor = .yellow
        validateButtonAvailability()

        
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        tableView.separatorStyle = .none
        tableView.clipsToBounds = false
        tableView.delegate = self
        tableView.dataSource = self
        updateTable()
        
    }

    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        updateTable()
    }
    
    @objc func switchViewValueChanged(_ sender: UISwitch) {
        validateButtonAvailability()
    }
    

    @objc func buttonPressed(_ sender: UIButton) {
            switch selectedOption {
            case .login:
                if let loginCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? InputCell,
                let passwordCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? InputCell,
                let login = loginCell.textField.text, let password = passwordCell.textField.text {
                            
                        guard let savedLogin = UserDefaults.standard.string(forKey: "login"),
                        let savedPassword = UserDefaults.standard.string(forKey: "password") else {
                                self.showError("The log-in information is incorrect.")
                                return
                            }

                            if login == savedLogin, password == savedPassword {
                                let notesViewController = NotesViewController()
                                self.present(notesViewController, animated: true, completion: nil)
                            } else {
                                self.showError("The log-in information is incorrect.")
                            }
                        }
                
                break
                
            case .registration:
                // Validate and save registration data
                if let loginCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? InputCell,
                   let emailCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)) as? InputCell,
                   let passwordCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? InputCell,
                   let repeatPasswordCell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? InputCell,
                   let login = loginCell.textField.text,
                   let email = emailCell.textField.text,
                   let password = passwordCell.textField.text,
                   let repeatedPassword = repeatPasswordCell.textField.text {
                    if InputValidation.shared.validateAndSaveData(login: login, email: email, password: password, repeatedPassword: repeatedPassword) {
                        textFieldValues.removeAll { $0.isLogin || $0.isEmail || $0.isPassword }
                        textFieldValues.append(.login(login))
                        textFieldValues.append(.email(email))
                        textFieldValues.append(.password(password))
                        UserDefaults.standard.set(login, forKey: "login")
                        UserDefaults.standard.set(email, forKey: "email")
                        UserDefaults.standard.set(password, forKey: "password")
                        
                        let notesViewController = NotesViewController()
                        present(notesViewController, animated: true, completion: nil)
                    }
                }
            }
            
            UserDefaults.standard.synchronize()
            tableView.reloadData()
    }
        

    func validateButtonAvailability() {
        if switchView.isOn {
            button.isEnabled = true
            button.alpha = 1.0
        } else {
            button.isEnabled = false
            button.alpha = 0.5
        }
    }
    
    
        
    func agreeView(){
        view.addSubview(switchView)
        view.addSubview(switchLabel)
        
        switchLabel.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(5)
            make.width.equalTo(100)
            make.left.equalToSuperview().offset(50)
        }
        
        switchView.snp.makeConstraints { make in
            make.top.equalTo(tableView.snp.bottom).offset(5)
            make.right.equalToSuperview().offset(-50)
        }
    }

    func updateTable() {
            let selectedIndex = segmentedControl.selectedSegmentIndex
            
            switch selectedIndex {
            case 0:
                button.setTitle("Вход", for: .normal)
                selectedOption = .login
                switchLabel.removeFromSuperview()
                switchView.removeFromSuperview()
                button.isEnabled = true
                button.alpha = 1.0
                
                
            case 1:
                switchView.isOn = false
                button.isEnabled = false
                button.alpha = 0.5
                agreeView()
                button.setTitle("Регистрация", for: .normal)
                selectedOption = .registration
                
                
            default:
                break
            }
            
            UserDefaults.standard.synchronize()
            
            tableView.reloadData()
        
        }

    // UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedOption == .login ? 2 : 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = InputCell(style: .default, reuseIdentifier: nil)
        
        if selectedOption == .login {
            if indexPath.row == 0 {
                cell.identifier = "login"
                cell.textField.placeholder = "Логин"
            } else if indexPath.row == 1 {
                cell.identifier = "password"
                cell.textField.placeholder = "Пароль"
            }
        } else if selectedOption == .registration {
            switch indexPath.row {
            case 0:
                cell.identifier = "login"
                cell.textField.placeholder = "Логин"
            case 1:
                cell.identifier = "email"
                cell.textField.placeholder = "E-mail"
            case 2:
                cell.identifier = "password"
                cell.textField.placeholder = "Пароль"
            case 3:
                cell.identifier = "repeatPassword"
                cell.textField.placeholder = "Повторить пароль"
            default:
                break
            }
        }
        
        if let textFieldValue = textFieldValues.first(where: { $0.identifier == cell.identifier }) {
            cell.textField.text = textFieldValue.text
        }
        
        cell.layer.cornerRadius = 5
        cell.layer.borderWidth = 3
        cell.layer.borderColor = UIColor.gray.cgColor
        cell.contentView.backgroundColor = .white
        cell.textField.backgroundColor = .white

        return cell
    }
    
    

}

enum Option {
    case login
    case registration
}



extension ViewController.TextFieldValue {
    var isLogin: Bool {
        if case .login(_) = self {
            return true
        } else {
            return false
        }
    }
    
    var isEmail: Bool {
        if case .email(_) = self {
            return true
        } else {
            return false
        }
    }
    
    var isPassword: Bool {
        if case .password(_) = self {
            return true
        } else {
            return false
        }
    }
    
    var text: String {
        switch self {
        case .login(let text):
            return text
        case .email(let text):
            return text
        case .password(let text):
            return text
        }
    }
    
    var identifier: String {
        switch self {
        case .login:
            return "login"
        case .email:
            return "email"
        case .password:
            return "password"
        }
    }
}
