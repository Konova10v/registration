//
//  IntroView.swift
//  RegistrationApp
//
//  Created by Кирилл Коновалов on 02.01.2023.
//


import SwiftUI

struct IntroView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .edgesIgnoringSafeArea(.all)

                PlayerView()
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()
                    Text("Здравствуйте!")
                        .font(Font.bold(size: 40))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.white)
                    Spacer()

                    VStack(spacing: 16) {
                        VStack(spacing: 24) {
                            NavigationLink(destination: RegistrationView(registration: .constant(true))) {
                                Text("Начать")
                                    .font(Font.bold(size: 16))
                                    .frame(width: Screen.width - 48,
                                           height: 48,
                                           alignment: .center)
                                    .foregroundColor(Color.black)
                                    .background(Color.white)
                                    .cornerRadius(100)
                            }

                            NavigationLink(destination: RegistrationView(registration: .constant(false))) {
                                VStack {
                                    Text("У вас уже есть аккаунт?")
                                        .font(Font.medium(size: 14))
                                        .foregroundColor(Color.init(hex: "B9B9BA"))

                                    Text("Войти")
                                        .font(Font.bold(size: 14))
                                        .foregroundColor(Color.white)
                                }
                            }

                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden()
    }
}


struct IntroView_Previews: PreviewProvider {
    static var previews: some View {
        IntroView()
    }
}

