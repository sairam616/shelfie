//
//  LoginView.swift
//  shelfie
//
//  Created by Luiz Fernando Reis on 2022-03-25.
//

import SwiftUI
import Firebase

struct LoginView: View {
    @State private var email  = ""
    @State private var password  = ""
    @State private var showingAlert = false
    @State private var alertmessage = ""
    
    @FocusState private var focusedField: Field?
    
    enum Field: Hashable {
        case emailField
        case passwordField
    }
    
    var body: some View {
        ZStack{
            Image("bg").resizable().edgesIgnoringSafeArea(.all)
            
            VStack{
                Spacer()
                
                Image("logoShelfieWhite").resizable().scaledToFit()
                Text("Build your collection in a snap!")
                    .font(.custom("Avenir-Black", size: sf.h * 0.04))
                    .fixedSize(horizontal: false, vertical: true)
                
                VStack(alignment: .leading, spacing: sf.h * 0.005){
                    Text("Email").font(.custom("Avenir", size: sf.h * 0.03))
                    TextField("", text: $email)
                        .textContentType(.emailAddress)
                        .focused($focusedField, equals: .emailField)
                        .submitLabel(.next)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(email.isEmpty ? .black.opacity(0.5) : .black, lineWidth: 1)
                                .background(RoundedRectangle(cornerRadius: 30).fill(Color("TxtFieldBlue")))
                        )
                        .onSubmit {
                            focusedField = .passwordField
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            focusedField = .emailField
                        }
                    
                    Text("Password").font(.custom("Avenir", size: sf.h * 0.03))
                    TextField("", text: $password)
                        .textContentType(.emailAddress)
                        .focused($focusedField, equals: .passwordField)
                        .submitLabel(.done)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .disableAutocorrection(true)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(password.isEmpty ? .black.opacity(0.5) : .black, lineWidth: 1)
                                .background(RoundedRectangle(cornerRadius: 30).fill(Color("TxtFieldBlue")))
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            focusedField = .passwordField
                        }
                }.padding().frame(width: sf.w * 0.75)
                
                NavigationLink {
                    MainView()
                } label: {
                    Image("getStartedButton")
                }
                NavigationLink {
                    MainView()
                }
            label: {
                ButtonView(text: "LOGIN"){
                    print("Inside login Function!!!!--------")
                    Auth.auth().addStateDidChangeListener { auth, user in
                        if user != nil {
                            print("---------User Exists-------")
                            guard //These have to be true
                                email.count > 0,
                                password.count > 0
                            else {
                                showingAlert = true
                                alertmessage = "Fill in the Credentials"
                              return
                            }
                        
                            Auth.auth().signIn(withEmail: email, password: password) { user, error in
                                if let error = error, user == nil {
                                    print("Signin Failed");
                                    showingAlert = true
                                    alertmessage = "Invalid Credentials"
                                    return
                                }
                                print("Signin Success");
                                MainView()
                            }
                        }
                        else{
                            showingAlert = true
                            alertmessage = "Please sign-up to continue"
                            return
                        }
                    }
                }.padding()
                .alert(alertmessage, isPresented: $showingAlert) {
                            Button("OK", role: .cancel) { }
                        }
            }
                
                Spacer()
                
                HStack{
                    Text("Not registered yet?").font(.custom("Avenir", size: sf.h * 0.025))
                    NavigationLink {
                        RegisterView()
                    } label: {
                        Text("Sign Up!").font(.custom("Avenir", size: sf.h * 0.025)).foregroundColor(Color("LinkBlue"))
                    }
                }
                
                
                
                Spacer()
                
            }
            .padding()
            .frame(maxWidth: sf.w)
        }
        .foregroundColor(.white)
        .navigationBarHidden(true)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
