// Replace the currentUserProfile computed property in SettingsView.swift with this:

private var currentUserProfile: UserProfile {
    if let user = authManager.currentUser {
        // Use actual name if available, otherwise extract from email
        let displayName: String
        if let name = user.name, !name.isEmpty {
            displayName = name
        } else {
            displayName = user.email.components(separatedBy: "@").first?.capitalized ?? "User"
        }
        
        return UserProfile(
            name: displayName,
            email: user.email,
            backgroundColor: "#FFEF62"
        )
    } else {
        return UserProfile.current
    }
}
