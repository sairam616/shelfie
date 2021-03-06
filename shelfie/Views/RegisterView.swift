//
//  RegisterView.swift
//  shelfie
//
//  Created by Ramy Anber on 2022-03-25.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var didScreenLoad: Bool = false
    let usersRef = Database.database().reference(withPath: "signeduser")
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var email: String = ""
    @State var password: String = ""
    @State var confirmPassword: String = ""
    @State private var showingAlert = false
    @State private var alertmessage = ""
    var body: some View {
        ZStack{
            Image("bg").resizable().edgesIgnoringSafeArea(.all)
            
            VStack{
                Spacer()
                
                ZStack{
                    Image("logoShelfieWhite")
                        .resizable().scaledToFit()
                        .frame(width: sf.w * 0.5)
                    
                    Button(action: {self.presentationMode.wrappedValue.dismiss()}) {
                        Image(systemName: "chevron.backward")
                            .font(.largeTitle.bold())
                            .opacity(didScreenLoad ? 1 : 0)
                            .rotationEffect(.degrees(didScreenLoad ? 0 : -90))
                            .animation(.spring().delay(0.2), value: didScreenLoad)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                Spacer()
                Text("Sign Up")
                    .font(.custom("Avenir-Black", size: sf.h * 0.04))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: sf.h * 0.005){
                    HStack{
                        VStack(alignment: .leading, spacing: sf.h * 0.005){
                            Text("First Name").font(.custom("Avenir", size: sf.h * 0.03))
                            CustomTextField(value: $firstName, roundedCorners: 30, textColor: .white, shadowRadius: 5, fontSize: sf.h * 0.05, padding: 0)
                                .frame(height: sf.h * 0.065)
                        }
                        Spacer()
                        VStack(alignment: .leading, spacing: sf.h * 0.005){
                            Text("Last Name").font(.custom("Avenir", size: sf.h * 0.03))
                            CustomTextField(value: $lastName, roundedCorners: 30, textColor: .white, shadowRadius: 5, fontSize: sf.h * 0.05, padding: 0)
                                .frame(height: sf.h * 0.065)
                        }
                    }
                    Text("Email").font(.custom("Avenir", size: sf.h * 0.03))
                    CustomTextField(value: $email, roundedCorners: 30, textColor: .white, shadowRadius: 5, fontSize: sf.h * 0.05)
                        .frame(height: sf.h * 0.065)
                    Text("Password").font(.custom("Avenir", size: sf.h * 0.03))
                    CustomTextField(value: $password, roundedCorners: 30, textColor: .white, shadowRadius: 5, fontSize: sf.h * 0.05)
                        .frame(height: sf.h * 0.065)
                    Text("Confirm Password").font(.custom("Avenir", size: sf.h * 0.03))
                    CustomTextField(value: $confirmPassword, roundedCorners: 30, textColor: .white, shadowRadius: 5, fontSize: sf.h * 0.05)
                        .frame(height: sf.h * 0.065)
                }.padding()
                
                Spacer()
                Spacer()
                
                NavigationLink {
                    MainView()
                } label: {
                    ButtonView(text: "SIGN UP"){
                        guard //These have to be true
                            firstName.count > 0,
                            lastName.count > 0,
                            email.count > 0,
                            password.count >= 6,
                            confirmPassword.count >= 6
                        else {
                            showingAlert = true
                            if(password.count < 6)
                            {
                                alertmessage = "Password must be greater then 6 charecters"
                                return
                            }
                            if(confirmPassword != password)
                            {
                                alertmessage = "The passwords must match"
                                return
                            }
                            alertmessage = "Fill all the Fields"
                          return
                        }
                        Auth.auth().addStateDidChangeListener { auth, user in
                            if user != nil {
                                print("-------------USER SIGNUP-----------")
                            }
                            
                        }
                        Auth.auth().fetchSignInMethods(forEmail: email, completion: {
                            (providers, error) in

                            if let error = error {
                                print(error.localizedDescription)
                                return
                            } else if let providers = providers {
                                print(providers)
                                showingAlert = true
                                alertmessage = "User already exists"
                                return
                            }
                            Auth.auth().createUser(withEmail: email, password: password) { user, error in
                                if(error != nil)
                                {
                                    print("*****----***Error creating user***",error)
                                }
                                print("----------User Created------",user)
                                let userDetails = User(firstname: firstName, lastname: lastName, email: email);
                                print("************ ",email)
                                let userRef = self.usersRef.child(firstName)
                                
                                userRef.setValue(userDetails.toUserObject())
                                
                                let db = Firestore.firestore()
                                db.collection("userdetails").document(email).setData(["firstname":firstName,"lastname":lastName])
                                showingAlert = true
                                alertmessage = "Signup Successfully"
                            }
                        })   
                    }.padding()
                    .alert(alertmessage, isPresented: $showingAlert) {
                                    Button("OK", role: .cancel) { }
                                }
                }
            }
            .foregroundColor(.white)
            .navigationBarHidden(true)
            .onAppear {
                didScreenLoad.toggle()
            }
        }
    }
}
    struct RegisterView_Previews: PreviewProvider {
        static var previews: some View {
            RegisterView()
        }
    }
