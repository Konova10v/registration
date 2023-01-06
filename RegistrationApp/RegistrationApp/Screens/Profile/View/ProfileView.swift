//
//  ProfileView.swift
//  RegistrationApp
//
//  Created by Кирилл Коновалов on 02.01.2023.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    
    @State var loading: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Rectangle()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.red,
                                                                     Color.black]),
                                         startPoint: .init(x: 0.5, y: 0),
                                         endPoint: .init(x: 0.5, y: 1)))
                    .frame(width: Screen.width, height: 172, alignment: .top)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        VStack(alignment: .leading, spacing: 8) {
                            HStack() {
                                Text("Профиль")
                                    .font(Font.medium(size: 32))
                                    .foregroundColor(Color.white)
                                    .multilineTextAlignment(.leading)
                                
                                Spacer()
                            }
                            
                            Text(UserDefaults.standard.string(forKey: "email") ?? "")
                                .font(Font.medium(size: 16))
                                .foregroundColor(Color.white)
                                .multilineTextAlignment(.leading)
                        }
                            .padding(.top, 45)
                            .padding([.leading, .trailing, .bottom], 16)
                    )
                
                Spacer()
                
                exitButtonView
                    .padding(.bottom, 50)
            }
            .background(Color.black)
            .edgesIgnoringSafeArea(.all)
        }
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden()
    }
    
    // MARK: - Exit Button View
    var exitButtonView: some View {
        Button {
            loading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                UserDefaults.standard.set(false, forKey: "auth")
                UserDefaults.standard.set("", forKey: "email")
                loading = false
                appState.modelID = ScreenID.intro
            }
        } label: {
            HStack {
                Spacer()
                
                if loading {
                    SwiftUI.ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                } else {
                    Text("Выйти")
                        .foregroundColor(Color.black)
                }
                
                Spacer()
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(100)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
