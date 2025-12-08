import SwiftUI

struct ContentView: View {
    @State private var statusText: String = "Ready"
    @State private var lastCreatedUserId: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                
                Button("Get All Users") {
                    Task {
                        await testGetAllUsers()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Create User") {
                    Task {
                        await testCreateUser()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("Get User (lastCreatedUserId)") {
                    Task {
                        await testGetUser()
                    }
                }
                .buttonStyle(.bordered)
                .disabled(lastCreatedUserId == nil)
                
                Button("Update User (lastCreatedUserId)") {
                    Task {
                        await testUpdateUser()
                    }
                }
                .buttonStyle(.bordered)
                .disabled(lastCreatedUserId == nil)
                
                Button("Delete User (lastCreatedUserId)") {
                    Task {
                        await testDeleteUser()
                    }
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .disabled(lastCreatedUserId == nil)
                
                Divider()
                    .padding(.vertical, 8)
                
                Text("Status: \(statusText)")
                    .font(.footnote)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if let lastCreatedUserId {
                    Text("Last created id: \(lastCreatedUserId)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("API Test")
        }
    }
}

// MARK: - Test functions

extension ContentView {
    
    private func testGetAllUsers() async {
        do {
            let response = try await APIManager.shared.getAllUsers()
            let count = response.data.users?.count ?? 0
            print("✅ GetAllUsers success. User count: \(count)")
            print("Response: \(response)")
            
            await MainActor.run {
                statusText = "GetAllUsers OK. Total: \(count)"
            }
        } catch {
            print("❌ GetAllUsers error: \(error)")
            await MainActor.run {
                statusText = "GetAllUsers Error: \(error.localizedDescription)"
            }
        }
    }
    
    private func testCreateUser() async {
        let request = CreateUserRequest(
            firstName: "Talha",
            lastName: "Test",
            phoneNumber: "5551234567",
            profileImageUrl: nil // optionally 
        )
        
        do {
            let response = try await APIManager.shared.createUser(request)
            print("✅ CreateUser success")
            print("Response: \(response)")
            
            let newId = response.data.id
            await MainActor.run {
                statusText = "CreateUser OK. id: \(newId ?? "-")"
                lastCreatedUserId = newId
            }
        } catch {
            print("❌ CreateUser error: \(error)")
            await MainActor.run {
                statusText = "CreateUser Error: \(error.localizedDescription)"
            }
        }
    }
    
    private func testGetUser() async {
        guard let id = lastCreatedUserId else {
            await MainActor.run {
                statusText = "You must create a user first."
            }
            return
        }
        
        do {
            let response = try await APIManager.shared.getUser(id: id)
            print("✅ GetUser success for id: \(id)")
            print("Response: \(response)")
            
            await MainActor.run {
                statusText = "GetUser OK. \(response.data.firstName ?? "") \(response.data.lastName ?? "")"
            }
        } catch {
            print("❌ GetUser error: \(error)")
            await MainActor.run {
                statusText = "GetUser Error: \(error.localizedDescription)"
            }
        }
    }
    
    private func testUpdateUser() async {
        guard let id = lastCreatedUserId else {
            await MainActor.run {
                statusText = "You must create a user first."
            }
            return
        }
        
        let request = UpdateUserRequest(
            firstName: "Talha Updated",
            lastName: "Test Updated",
            phoneNumber: "5550000000",
            profileImageUrl: nil
        )
        
        do {
            let response = try await APIManager.shared.updateUser(id: id, with: request)
            print("✅ UpdateUser success for id: \(id)")
            print("Response: \(response)")
            
            await MainActor.run {
                statusText = "UpdateUser OK. \(response.data.firstName ?? "")"
            }
        } catch {
            print("❌ UpdateUser error: \(error)")
            await MainActor.run {
                statusText = "UpdateUser Error: \(error.localizedDescription)"
            }
        }
    }
    
    private func testDeleteUser() async {
        guard let id = lastCreatedUserId else {
            await MainActor.run {
                statusText = "You must create a user first."
            }
            return
        }
        
        do {
            let response = try await APIManager.shared.deleteUser(id: id)
            print("✅ DeleteUser success for id: \(id)")
            print("Response: \(response)")
            
            await MainActor.run {
                statusText = "DeleteUser OK. id: \(id)"
                lastCreatedUserId = nil
            }
        } catch {
            print("❌ DeleteUser error: \(error)")
            await MainActor.run {
                statusText = "DeleteUser Error: \(error.localizedDescription)"
            }
        }
    }
}

#Preview {
    ContentView()
}
