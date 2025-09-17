import SwiftUI
import Firebase
import FirebaseAuth

// https://console.firebase.google.com/u/0/

final class FirebaseManager {
    
    public static let shared = FirebaseManager()
    
    public let auth: Auth
    
    private init() {
        FirebaseApp.configure()
        auth = Auth.auth()
    }
}

struct LogInOrCreateAccountView: View {
    
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    
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
                            
                        } label: {
                            Image(systemName: "person.fill")
                                .font(.system(size: 64))
                                .padding()
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
    }
    
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
            }
        }
    }
}

#Preview {
    LogInOrCreateAccountView()
}
