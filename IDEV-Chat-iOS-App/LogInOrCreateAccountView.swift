import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

// https://console.firebase.google.com/u/0/

final class FirebaseManager {
    
    public static let shared = FirebaseManager()
    
    public let auth: Auth
    public let storage: Storage
    public let firestore: Firestore
    
    private init() {
        FirebaseApp.configure()
        auth = Auth.auth()
        storage = Storage.storage()
        firestore = Firestore.firestore()
    }
}

struct LogInOrCreateAccountView: View {
    
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    
    @State var shouldShowImagePicker = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Picker(selection: $isLoginMode,
                           label: Text("Picker here")) {
                        Text("Login").tag(true)
                        Text("Create Account").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical, 12)
                    
                    if !isLoginMode {
                        Button {
                            shouldShowImagePicker.toggle()
                        } label: {
                            VStack {
                                if let image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 128, height: 128)
                                        .cornerRadius(64)
                                } else {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 64))
                                        .padding()
                                        .foregroundColor(Color(.label))
                                }
                            }
                            // .border(.black, width: 3)
                            .overlay(RoundedRectangle(cornerRadius: 64).stroke(.black, lineWidth: 3))
                        }
                    }
                    
                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        
                        SecureField("Password", text: $password)
                    }
                    .padding(12)
                    .background(.white)
                    
                    Button {
                        logInOrCreateAccountAction()
                    } label: {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }
                        .background(.blue)
                    }
                    
                    Text(loginStatusMessage)
                        .foregroundColor(.red)
                }
                .padding()
            }
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05)).ignoresSafeArea())
        }
        // .navigationViewStyle(StackNavigationViewStyle())
        .fullScreenCover(isPresented: $shouldShowImagePicker) {
            ImagePicker(image: $image)
        }
    }
    
    @State var image: UIImage?
    
    private func logInOrCreateAccountAction() {
        if isLoginMode {
            loginUser()
            print("Log In")
        } else {
            createNewAccount()
            print("Create Account")
        }
    }
    
    //
    // The Preview crashes if FirebaseApp.configure() is run 2+ times.
    // We can fix it with a FirebaseManager class and a Singleton instance.
    //
    // Auth.auth() -> FirebaseManager.shared.auth
    //
    private func loginUser() {
        FirebaseManager.shared.auth.signIn(withEmail: email, password: password) { result, error in
            if let error {
                let loginStatusMessage = "Failed to Login user: \(error.localizedDescription)"
                print(loginStatusMessage)
                self.loginStatusMessage = loginStatusMessage
                return
            }
            
            if let userID = result?.user.uid {
                let loginStatusMessage = "Successfully Logged In as user: \(userID)"
                print(loginStatusMessage)
                self.loginStatusMessage = loginStatusMessage
            }
        }
    }
    
    @State var loginStatusMessage = ""
    
    private func createNewAccount() {
        FirebaseManager.shared.auth.createUser(withEmail: email, password: password) { result, error in
            if let error {
                let loginStatusMessage = "Failed to create user: \(error.localizedDescription)"
                print(loginStatusMessage)
                self.loginStatusMessage = loginStatusMessage
                return
            }
            
            if let userID = result?.user.uid {
                let loginStatusMessage = "Successfully created user: \(userID)"
                print(loginStatusMessage)
                self.loginStatusMessage = loginStatusMessage
                
                // Must have a Billing Plan
                // self.persistImageToStorage()
            }
        }
    }
    
    
    //
    // https://console.firebase.google.com/u/0/project/idev-chat-ios-app/storage
    //
    // https://firebase.blog/posts/2024/11/claim-300-to-get-started
    //
    // https://firebase.google.com/pricing?authuser=0
    //
    private func persistImageToStorage() {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        guard let imageData = image?.jpegData(compressionQuality: 0.5) else { return }
        
        let filename = uid // UUID().uuidString
        let ref = FirebaseManager.shared.storage.reference(withPath: filename)
        
        ref.putData(imageData, metadata: nil) { storageMetadata, error in
            if let error {
                self.loginStatusMessage = "Failed to PUT image into Firebase Storage associated with current user: \(error.localizedDescription)"
                return
            }
            
            ref.downloadURL { url, error in
                if let error {
                    self.loginStatusMessage = "Failed to retrieve downloadURL: \(error)"
                    return
                }
                
                if let url {
                    self.loginStatusMessage = "Successfully stored image with url: \(url.absoluteString)"
                    print(url.absoluteString)
                    
                    self.storeUserInformation(imageProfileUrl: url)
                }
            }
        }
    }
    
    private func storeUserInformation(imageProfileUrl: URL) {
        guard let uid = FirebaseManager.shared.auth.currentUser?.uid else { return }
        
        let userData = ["email": email, "uid": uid, "profileImageUrl": imageProfileUrl.absoluteString]
        
        FirebaseManager.shared.firestore.collection("users")
            .document(uid).setData(userData) { error in
                if let error {
                    print(error)
                    self.loginStatusMessage = error.localizedDescription
                    return
                }
                
                print("Success")
            }
    }
}

#Preview {
    LogInOrCreateAccountView()
}
