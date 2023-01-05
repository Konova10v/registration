//
//  RegistrationViewModel.swift
//  RegistrationApp
//
//  Created by Кирилл Коновалов on 02.01.2023.
//

import Foundation
import CoreData

@objc(UserEntity)
public class UserEntity: NSManagedObject {

}

final class AuthViewModel: ObservableObject {
    static let instance = AuthViewModel()
    private let container: NSPersistentContainer
    @Published var users: [UserEntity] = []
    
    @Published var emailPlaceholder = "Введите электронную почту"
    @Published var emailAlertShown = false
    @Published var emailAlertText = ""
    @Published var email: String = "" {
        didSet { validateEmail() }
    }
    @Published var emailLogin: String = "" {
        didSet { validateEmailLogin() }
    }

    @Published var passwordPlaceholder = "Придумайте пароль"
    @Published var passwordAlertShown = false
    @Published var passwordAlertText = "Введите корректный пароль"
    @Published var password: String = "" {
        didSet { validatePassword() }
    }

    @Published var passwordGreaterSix = false

    @Published var emailIsValid = false
    @Published var passwordIsValid = false

    var formIsValid: Bool {
        emailIsValid && passwordIsValid != false
    }
    
    
    private init() {
        container = NSPersistentContainer(name: "UserData")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Error loading todo: \(error)")
            }
        }
        fetchTodos()
    }
    
    private func fetchTodos() {
        let request = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        
        do {
            users = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching \(error)")
        }
    }
    
    
    func addToDo(email: String, password: String) {
        let newDoTo = UserEntity(context: container.viewContext)
        newDoTo.id = UUID()
        newDoTo.email = email
        newDoTo.password = password
        
        saveData()
    }
    
    func login(email: String, password: String) -> String {
        var loginError: String = ""
        for item in users {
            if item.email == email {
                if item.password == password {
                    loginError = "Успешно"
                } else {
                    loginError = "Неверный пароль"
                }
            } else {
                loginError = "Такого email нет"
            }
        }

        return loginError
    }
    
    func changePassword(email: String, password: String) -> String {
        let changeUser = users.filter { user in
            user.email == email
         }
        
        changeUser.forEach { user in
             container.viewContext.delete(user)
         }
        
        saveData()
        
        addToDo(email: email, password: password)
        
        return "Пароль изменен"
    }
    
    
    private func saveData() {
        do {
            try container.viewContext.save()
            fetchTodos()
        } catch let error {
            print("Error saving. \(error)")
        }
    }
}

// MARK: - Validate
private extension AuthViewModel {
    func validateEmail() {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        if !emailPred.evaluate(with: email) {
            self.emailAlertText = "Введите корректный адрес электронной почты"
            self.emailAlertShown = true
        } else {
            self.emailPlaceholder = "Введите электронную почту"
            self.emailAlertText = ""
            self.emailAlertShown = false
            self.emailIsValid = true
        }
        
        for item in users {
            if item.email == email {
                self.emailAlertText = "Такой email уже есть"
                self.emailAlertShown = true
            }
        }
    }
    
    
    func validateEmailLogin() {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        if !emailPred.evaluate(with: emailLogin) {
            self.emailAlertText = "Введите корректный адрес электронной почты"
            self.emailAlertShown = true
        } else {
            self.emailPlaceholder = "Введите электронную почту"
            self.emailAlertText = ""
            self.emailAlertShown = false
            self.emailIsValid = true
        }
    }
    

    func validatePassword() {
        guard !password.contains(" ") else {
            password = password.trimmingCharacters(in: .whitespaces)
            return
        }
        
        if password == "" {
            passwordAlertShown = false
            passwordPlaceholder = "Придумайте пароль"
        } else {
            passwordGreaterSix = password.count >= 6

            passwordIsValid = passwordGreaterSix
            passwordAlertShown = !passwordIsValid
            passwordPlaceholder = "Пароль"
        }
    }
}
