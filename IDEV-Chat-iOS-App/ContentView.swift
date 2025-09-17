import SwiftUI

struct ContentView: View {
    
    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                Picker(selection: $isLoginMode,
                       label: Text("Picker here")) {
                    Text("Login").tag(true)
                    Text("Create Account").tag(false)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.vertical, 12)
                
                Button {
                    
                } label: {
                    Image(systemName: "person.fill")
                        .font(.system(size: 64))
                        .padding()
                }
                
                TextField("Email", text: $email)
                TextField("Password", text: $password)
                
                Button {
                    
                } label: {
                    HStack {
                        Spacer()
                        Text("Create Account")
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                        Spacer()
                    }
                    .background(.blue)
                }
            }
            .navigationTitle("Create Account")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
