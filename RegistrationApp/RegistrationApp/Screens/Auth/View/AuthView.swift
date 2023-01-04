//
//  RegistrationView.swift
//  RegistrationApp
//
//  Created by Кирилл Коновалов on 02.01.2023.
//

import SwiftUI

struct RegistrationView: View {
    @Binding var registration: Bool
    @State var loading: Bool = false
    @State var auth: Bool = false
    
    @StateObject private var viewModel: AuthViewModel = AuthViewModel.instance
    @State private var isSecurePasswordEntry = true
    @State private var tapRegister: Bool = false
    @State private var error: Bool = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            formView
        }
        .padding(EdgeInsets(top: 25, leading: 16, bottom: 0, trailing: 16))
        .navigationBarHidden(true)
        .environmentObject(viewModel)
        .onDisappear {
            viewModel.email = ""
            viewModel.emailLogin = ""
            viewModel.password = ""
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
            
            if !registration && error {
                Text("Неверный логин или пароль")
                    .font(.custom("WorldClass-Regular", size: 14))
                    .foregroundColor(Color.red)
            }

            buttonView
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
        NavigationLink(isActive: $auth) {
            ProfileView()
        } label: {
            Button {
                loading = true
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                    if registration {
                        viewModel.addToDo(email: viewModel.email, password: viewModel.password)
                        UserDefaults.standard.set(viewModel.email, forKey: "email")
                        UserDefaults.standard.set(true, forKey: "auth")
                        auth.toggle()
                    } else {
                        error = viewModel.login(email: viewModel.emailLogin, password: viewModel.password)
                        if !error {
                            UserDefaults.standard.set(viewModel.emailLogin, forKey: "email")
                            UserDefaults.standard.set(true, forKey: "auth")
                            auth.toggle()
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
                        Text(registration ?  "Зарегистрироваться" : "Войти")
                            .foregroundColor(Color.white)
                    }

                    Spacer()
                }
                .padding([.top, .bottom], 14)
                .background(viewModel.formIsValid ? Color.black : Color.secondary)
                .cornerRadius(100)
            }
            .disabled(!viewModel.formIsValid)
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
                    .font(.custom("WorldClass-Regular", size: 14))
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