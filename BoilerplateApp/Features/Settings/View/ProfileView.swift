import SwiftUI

/// User profile view placeholder
/// Replace with actual profile implementation
struct ProfileView: View {

    // MARK: - Properties

    @State private var displayName = ""
    @State private var email = ""

    // MARK: - Body

    var body: some View {
        List {
            profileHeaderSection
            accountSection
            signOutSection
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Sections

    private var profileHeaderSection: some View {
        Section {
            HStack(spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    Text(displayName.isEmpty ? "User Name" : displayName)
                        .font(.headline)

                    Text(email.isEmpty ? "user@example.com" : email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 8)
        }
    }

    private var accountSection: some View {
        Section("Account") {
            NavigationLink {
                EditProfileView()
            } label: {
                Label("Edit Profile", systemImage: "pencil")
            }

            NavigationLink {
                // Password change view
                Text("Change Password")
            } label: {
                Label("Change Password", systemImage: "lock")
            }
        }
    }

    private var signOutSection: some View {
        Section {
            Button("Sign Out", role: .destructive) {
                signOut()
            }
        }
    }

    // MARK: - Actions

    private func signOut() {
        // Implement sign out logic
        Log.info("User signed out")
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var displayName = ""
    @State private var bio = ""

    var body: some View {
        Form {
            Section("Profile Information") {
                TextField("Display Name", text: $displayName)
                TextField("Bio", text: $bio, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    saveProfile()
                    dismiss()
                }
            }
        }
    }

    private func saveProfile() {
        // Save profile changes
        Log.info("Profile updated")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProfileView()
    }
}
