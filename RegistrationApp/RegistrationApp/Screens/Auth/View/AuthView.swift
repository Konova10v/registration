//
//  RegistrationView.swift
//  RegistrationApp
//
//  Created by Кирилл Коновалов on 02.01.2023.
//

import SwiftUI

struct RegistrationView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: AuthViewModel = AuthViewModel.instance
    
    @Binding var registration: Bool
    @State var loading: Bool = false
    @State private var isSecurePasswordEntry = true
    @State private var tapRegister: Bool = false
    @State private var error: String = ""
    @State private var changePassword: Bool = false
    @State private var changePasswordDone: String = ""

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            formView
        }
        .padding(EdgeInsets(top: 25, leading: 16, bottom: 0, trailing: 16))
        .navigationBarHidden(true)
        .environmentObject(viewModel)
        .onAppear(perform: {
            print("test \(viewModel.formIsValid)")
        })
        .onDisappear {
            viewModel.email = ""
            viewModel.emailLogin = ""
            viewModel.password = ""
            
            viewModel.emailPlaceholder = "Введите электронную почту"
            viewModel.emailAlertText = ""
            viewModel.emailAlertShown = false
        }
    }

    // MARK: - Form View
    var formView: some View {
        VStack {
            VStack(alignment: .leading, spacing: 5) {
                UIOutlinedTextField(viewModel.emailPlaceholder,
                                    text: registration ? $viewModel.email : $viewModel.emailLogin,
                                    label: "Электронная почта",
                                    isSecureEntry: Binding.constant(false),
                                    secureNeeded: false,
                                    isError: $viewModel.emailAlertShown,
                                    scrollHeight: 40,
                                    errorText: $viewModel.emailAlertText,
                                    keyboardShow: .constant(false),
                                    keyboardType: .emailAddress)
                
                if viewModel.emailAlertShown {
                    Text(viewModel.emailAlertText)
                        .font(Font.custom("WorldClass-Regular", size: 10))
                        .foregroundColor(Color.red)
                        .padding(.leading, 15)
                }
            }
            .padding([.top, .bottom], 16)

            UIOutlinedTextField(viewModel.passwordPlaceholder,
                                text: $viewModel.password,
                                label: "Пароль",
                                isSecureEntry: $isSecurePasswordEntry,
                                secureNeeded: true,
                                isError: $viewModel.passwordAlertShown,
                                scrollHeight: 40,
                                errorText: $viewModel.passwordAlertText,
                                keyboardShow: .constant(false))

            if !viewModel.passwordIsValid {
                checkPasswordView
            }
            
            if !registration {
                VStack(spacing: 5) {
                    Text(error)
                        .font(.custom("WorldClass-Regular", size: 14))
                        .foregroundColor(Color.red)
                    
                    if error == "Неверный пароль" {
                        Button {
                            changePassword.toggle()
                            viewModel.password = ""
                            error = ""
                        } label: {
                            Text("Хотите изменить пароль?")
                                .font(Font.medium(size: 14))
                                .foregroundColor(Color.init(hex: "B9B9BA"))
                        }
                    }
                }
            }
            
            if changePassword {
                Text("Введите новый пароль")
                    .font(Font.medium(size: 14))
                    .foregroundColor(Color.init(hex: "B9B9BA"))
            }
            
            if changePasswordDone == "Пароль изменен" {
                Text("Пароль успешно изменен")
                    .font(Font.medium(size: 14))
                    .foregroundColor(Color.init(hex: "B9B9BA"))
            }

            VStack {
                if viewModel.formIsValid {
                    buttonView
                } else {
                    HStack {
                        Spacer()

                        if !changePassword {
                            Text(registration ?  "Зарегистрироваться" : "Войти")
                                .foregroundColor(Color.white)
                        } else {
                            Text("Изменить пароль")
                                .foregroundColor(Color.white)
                        }

                        Spacer()
                    }
                    .padding([.top, .bottom], 14)
                    .background(Color.secondary)
                    .cornerRadius(100)
                }
            }
            .padding(.top, 16)
        }
        .padding(EdgeInsets(top: 16, leading: 24, bottom: 16, trailing: 24))
        .background(Color.white)
        .cornerRadius(24)
        .animation(.easeOut(duration: 0.16))
    }

    // MARK: - Check Password View
    var checkPasswordView: some View {
        Group {
            if !viewModel.password.isEmpty {
                CheckPasswordLine(text: "Не менее 6 символов", isDone: viewModel.passwordGreaterSix)
                    .padding(.top, 8)
            }
        }
    }

    // MARK: - Register Button View
    var buttonView: some View {
        Button {
            error = ""
            changePasswordDone = ""
            loading = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                if registration {
                    viewModel.addToDo(email: viewModel.email, password: viewModel.password)
                    UserDefaults.standard.set(viewModel.email, forKey: "email")
                    UserDefaults.standard.set(true, forKey: "auth")
                    appState.modelID = ScreenID.profile
                } else {
                    if !changePassword {
                        error = viewModel.login(email: viewModel.emailLogin, password: viewModel.password)
                        if error == "Успешно" {
                            UserDefaults.standard.set(viewModel.emailLogin, forKey: "email")
                            UserDefaults.standard.set(true, forKey: "auth")
                            appState.modelID = ScreenID.profile
                        }
                    } else {
                        changePasswordDone = viewModel.changePassword(email: viewModel.emailLogin, password: viewModel.password)
                            
                        changePassword = false
                    }
                }
                loading = false
            }
        } label: {
            HStack {
                Spacer()

                if loading {
                    SwiftUI.ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                } else {
                    if !changePassword {
                        Text(registration ?  "Зарегистрироваться" : "Войти")
                            .foregroundColor(Color.white)
                    } else {
                        Text("Изменить пароль")
                            .foregroundColor(Color.white)
                    }
                }
                
                Spacer()
            }
            .padding([.top, .bottom], 14)
            .background(viewModel.formIsValid ? Color.black : Color.secondary)
            .cornerRadius(100)
        }
    }
}


// MARK: - Subviews
private extension RegistrationView {
    // MARK: - Check Password Line
    struct CheckPasswordLine: View {
        let text: String
        let isDone: Bool

        var body: some View {
            HStack(spacing: 8) {
                Image(systemName: isDone ? "circle.circle.fill" : "circle.circle")
                    .resizable()
                    .frame(width: 16, height: 16)

                Text(text)
                    .font(Font.medium(size: 14))
                    .foregroundColor(isDone ? Color.black : Color.secondary)

                Spacer()
            }
        }
    }
}

// MARK: - Previews

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView(registration: .constant(true))
    }
}
