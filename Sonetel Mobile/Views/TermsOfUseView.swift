//
//  TermsOfUseView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//

import SwiftUI

struct TermsOfUseView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            NavigationHeaderView(title: "Terms of Use") {
                dismiss()
            }

            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Terms of Use")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(FigmaColorTokens.textPrimary)

                        Text("Last updated: January 4, 2025")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(FigmaColorTokens.textSecondary)
                    }

                    VStack(alignment: .leading, spacing: 20) {
                        termsSection(
                            title: "1. Acceptance of Terms",
                            content: "By downloading, installing, or using the Sonetel Mobile application, you agree to be bound by these Terms of Use. If you do not agree to these terms, please do not use our service."
                        )

                        termsSection(
                            title: "2. Description of Service",
                            content: "Sonetel Mobile is a voice over internet protocol (VoIP) application that allows users to make and receive phone calls using an internet connection. The service includes features such as call management, contact integration, and call history."
                        )

                        termsSection(
                            title: "3. User Accounts",
                            content: "To use Sonetel Mobile, you must create an account and provide accurate, current, and complete information. You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account."
                        )

                        termsSection(
                            title: "4. Privacy and Data Protection",
                            content: "Your privacy is important to us. Our collection and use of personal information is governed by our Privacy Policy. By using our service, you consent to the collection and use of your information as described in our Privacy Policy."
                        )

                        termsSection(
                            title: "5. Acceptable Use",
                            content: "You agree to use Sonetel Mobile only for lawful purposes and in accordance with these Terms. You may not use the service to transmit any content that is illegal, harmful, threatening, abusive, harassing, defamatory, or otherwise objectionable."
                        )

                        termsSection(
                            title: "6. Service Availability",
                            content: "We strive to maintain high service availability, but we do not guarantee that the service will be available 100% of the time. Service may be temporarily unavailable due to maintenance, technical issues, or circumstances beyond our control."
                        )

                        termsSection(
                            title: "7. Limitation of Liability",
                            content: "To the maximum extent permitted by law, Sonetel shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising from your use of the service."
                        )

                        termsSection(
                            title: "8. Modifications to Terms",
                            content: "We reserve the right to modify these Terms of Use at any time. Changes will be effective immediately upon posting. Your continued use of the service after any changes constitutes acceptance of the new terms."
                        )

                        termsSection(
                            title: "9. Contact Information",
                            content: "If you have any questions about these Terms of Use, please contact us at support@sonetel.com or visit our website at www.sonetel.com for more information."
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
        }
        .background(FigmaColorTokens.surfacePrimary)
        .navigationBarHidden(true)
    }

    private func termsSection(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(FigmaColorTokens.textPrimary)

            Text(content)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(FigmaColorTokens.textPrimary)
                .lineSpacing(4)
        }
    }
}

#Preview {
    TermsOfUseView()
}
