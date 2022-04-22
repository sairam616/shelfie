//
//  CustomTabBar.swift
//  shelfie
//
//  Created by Luiz Fernando Reis on 2022-03-25.
//

import SwiftUI
import PhotosUI
import Firebase

struct CustomTabBar: View {
    
    @StateObject var viewRouter: ViewRouter
    @State var selectedTab = 0
    let tabs = ["Full View", "List View"]
    @State var showPopUp = false
    @State var home = HomeView()
    @State var collection = CollectionView()
    @State var watchlist = WatchlistView()
    @State var settings = SettingView()
    @State var isPickerShowing = false
    @State var inputImage : UIImage?
    @State private var imgToFirebase: UIImage?
    @State private var imgFromFirebase: UIImage?
    
    let tempimg = UIImage(named: "")
    
    
    var imgPicker = UIImagePickerController()
    var imgRef : StorageReference {
        return Storage.storage().reference().child("Images")
    }
    let filename = "Images/profilepic.png"
    var body: some View {
        GeometryReader { geometry in
            ZStack{
                Image("bg")
                    .resizable()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack{
                        Spacer()
                        Image("logoShelfieWhite")
                            .resizable()
                            .scaledToFit()
                        Button {
                            isPickerShowing = true
                        } label: {
                            ProfilePicture(profilepic: self.inputImage)
                                .scaleEffect(1.3)
                                .padding(.trailing)
                        }
                    }
                    .frame(maxHeight: geometry.size.height * 0.08)
                    .padding(.vertical)
                    Group{
                        if viewRouter.currentPage == .collection {
                            Text("Your Virtual Shelf")
                                .font(.custom("Avenir-Black", size: sf.h * 0.04))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Tabs(tabs: .constant(tabs), selection: $selectedTab) {title, isSelected in
                                Text(title)
                                    .frame(maxWidth: sf.w * 0.5)
                            }
                            .scaleEffect(0.6)
                        }
                        if viewRouter.currentPage == .watchlist {
                            Text("Your Watchlist")
                                .font(.custom("Avenir-Black", size: sf.h * 0.04))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Tabs(tabs: .constant(tabs), selection: $selectedTab) {title, isSelected in
                                Text(title)
                                    .frame(maxWidth: sf.w * 0.5)
                            }
                            .scaleEffect(0.6)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    ScrollView(.vertical, showsIndicators: false){
                        switch viewRouter.currentPage {
                        case .home:
                            home
                        case .collection:
                            collection
                        case .watchlist:
                            watchlist
                        case .settings:
                            settings
                        }
                    }.padding(.horizontal)
                    ZStack {
                        if showPopUp {
                            PlusMenu(widthAndHeight: geometry.size.width/7)
                                .offset(y: -geometry.size.height/6)
                        }
                        HStack {
                            TabBarIcon(viewRouter: viewRouter, assignedPage: .home, width: geometry.size.width/5, height: geometry.size.height/28, systemIconName: "house.fill", tabName: "Home")
                            TabBarIcon(viewRouter: viewRouter, assignedPage: .collection, width: geometry.size.width/5, height: geometry.size.height/28, systemIconName: "heart.fill", tabName: "Collection")
                            ZStack {
                                Circle()
                                    .foregroundColor(Color("BtnPurple"))
                                    .frame(width: geometry.size.width/6.5, height: geometry.size.width/6.5)
                                    .shadow(radius: 4)
                                Circle()
                                    .frame(width: geometry.size.width/8, height: geometry.size.width/8)
                                    .shadow(radius: 4)
                                LinearGradient(colors: [Color("BtnPurple"), Color("bgSearchTxtField")], startPoint: .top, endPoint: .bottom)
                                    .mask {
                                        Image(systemName: "plus.circle.fill")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: geometry.size.width/7 , height: geometry.size.width/7)
                                            .rotationEffect(Angle(degrees: showPopUp ? 180 : 0))
                                    }
                            }
                            .offset(y: -geometry.size.height/8/2)
                            .onTapGesture {
                                withAnimation {
                                    showPopUp.toggle()
                                }
                            }
                            TabBarIcon(viewRouter: viewRouter, assignedPage: .watchlist, width: geometry.size.width/5, height: geometry.size.height/28, systemIconName: "eyes", tabName: "Watchlist")
                            TabBarIcon(viewRouter: viewRouter, assignedPage: .settings, width: geometry.size.width/5, height: geometry.size.height/28, systemIconName: "gearshape.fill", tabName: "Account")
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height/8)
                        .background(LinearGradient(colors: [Color("NavBarTop"), Color("NavBarBottom")], startPoint: .top, endPoint: .bottom).shadow(radius: 2))
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .onChange(of: inputImage) { _ in loadImage() }
        .sheet(isPresented: $isPickerShowing) {
            ImagePicker(image: $inputImage)
        }
        .navigationBarHidden(true)
    }
    func loadImage() {
        print("---------Inside LoadImage------")
        guard let inputImage = inputImage else { return }
        imgToFirebase = inputImage
        uploadToFirebase(self)
        downloadFromFirebase(self)
    }
    
    func uploadToFirebase(_ sender: Any) {
        //MARK: - Upload our image to Firebase
        print("---------Inside Upload------")
        if(imgToFirebase != nil) {
            print("------------------inside not null---------------")
            //MARK: - If image view is not nil, and upload button pressed change status label text
            
            //MARK: - If image view has an image, continue, if not return this function
            guard let image = imgToFirebase else {
                return
            }
            
            //MARK: - Compress image selected to jpeg data to begin upload process
            guard let imageData = image.jpegData(compressionQuality: 1) else {
                return
            }
            
            //MARK: - Save image under our firebase ref location
            let uploadRef = imgRef.child(filename)
            
            let uploadTask = uploadRef.putData(imageData, metadata: nil) { (metadata, error) in
                //MARK: - Once upload is complete, print information on upload, and update status label
                if error == nil && metadata != nil {
                    
                }
            }
            
            //MARK: - Observe progress of upload, until is finished uploading
            uploadTask.observe(.progress) { (snapshot) in
                print(snapshot.progress ?? "No More Progress")
            }
            
            //MARK: - Resume upload until it is finished
            uploadTask.resume()
        }
    }
    
    func downloadFromFirebase(_ sender: Any) {
        //MARK: - Download our image from Firebase
        print("---------Inside Download------")
        
        //MARK: - We need to download image as a set size, first get a reference to our image on storage
        let downloadRef = imgRef.child(filename)
        
        let downloadTask = downloadRef.getData(maxSize: 1*4048*4048) { (data, error) in
            //MARK: - Download task, download data and create UIImage
            if let data = data {
                let image = UIImage(data: data)
                self.imgFromFirebase = image
                print("------------------inside Image---------------")
            }
        }
        //MARK: - Observe download progress
        downloadTask.observe(.progress) { (snapshot) in
            print(snapshot.progress ?? "No More Progress")
        }
        
        //MARK: - Download the image
        downloadTask.resume()
    }
}



struct CustomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabBar(viewRouter: ViewRouter())
            .preferredColorScheme(.dark)
    }
}

struct PlusMenu: View {
    
    let widthAndHeight: CGFloat
    
    var body: some View {
        HStack(spacing: 50) {
            ZStack {
                Circle()
                    .fill(AngularGradient(colors: [Color("BtnPurple"), Color("bgButton")], center: .bottom))
                    .frame(width: widthAndHeight, height: widthAndHeight)
                Image(systemName: "camera.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(15)
                    .frame(width: widthAndHeight, height: widthAndHeight)
            }
            ZStack {
                Circle()
                    .fill(AngularGradient(colors: [Color("BtnPurple"), Color("bgButton")], center: .bottom))
                    .frame(width: widthAndHeight, height: widthAndHeight)
                Image(systemName: "folder.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(15)
                    .frame(width: widthAndHeight, height: widthAndHeight)
            }
        }
        .transition(.scale)
    }
}

struct TabBarIcon: View {
    
    @StateObject var viewRouter: ViewRouter
    let assignedPage: Page
    
    let width, height: CGFloat
    let systemIconName, tabName: String
    
    var body: some View {
        VStack {
            if (viewRouter.currentPage == assignedPage) {
                LinearGradient(colors: [Color("AccentColorTop"), Color("AccentColorBottom")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .mask {
                        Image(systemName: systemIconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: width, height: height)
                            .padding(.top, 10)
                        //                        Text(tabName)
                        //                            .font(.footnote)
                    }
            } else {
                LinearGradient(colors: [Color("NavUnselected"), Color("placeHolderCol")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .mask {
                        Image(systemName: systemIconName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: width, height: height)
                            .padding(.top, 10)
                        //                        Text(tabName)
                        //                            .font(.footnote)
                    }
            }
            
            Spacer()
        }
        .padding(.horizontal, -4)
        .onTapGesture {
            viewRouter.currentPage = assignedPage
        }
    }
}
