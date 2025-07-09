//
//  FigmaImportView.swift
//  Sonetel Mobile
//
//  Created by Builder.io Assistant on 2025-01-04.
//  UI for importing and testing Figma variables
//

import SwiftUI
import UniformTypeIdentifiers

struct FigmaImportView: View {
    @State private var isImporting = false
    @State private var importStatus = ""
    @State private var showFileImporter = false
    @State private var importSuccess = false
    @State private var generatedTokensPath = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                headerSection
                
                importMethodsSection
                
                statusSection
                
                if importSuccess {
                    successSection
                }
                
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .navigationTitle("Figma Import")
            .navigationBarTitleDisplayMode(.large)
        }
        .fileImporter(
            isPresented: $showFileImporter,
            allowedContentTypes: [UTType.json],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.and.arrow.down.on.square")
                .font(.system(size: 48))
                .foregroundColor(.blue)
            
            Text("Import Figma Variables")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Import your Figma design tokens to automatically generate iOS design system tokens")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private var importMethodsSection: some View {
        VStack(spacing: 16) {
            // Method 1: From app bundle
            Button(action: importFromBundle) {
                HStack {
                    Image(systemName: "doc.text")
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Import from App Bundle")
                            .font(.headline)
                        Text("Use figma-tokens.json in app bundle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if isImporting {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .disabled(isImporting)
            
            // Method 2: File picker
            Button(action: { showFileImporter = true }) {
                HStack {
                    Image(systemName: "folder")
                        .font(.title2)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Choose JSON File")
                            .font(.headline)
                        Text("Select figma-tokens.json from files")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .disabled(isImporting)
        }
    }
    
    private var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !importStatus.isEmpty {
                Text("Import Status")
                    .font(.headline)
                
                ScrollView {
                    Text(importStatus)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .frame(maxHeight: 200)
            }
        }
    }
    
    private var successSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
                
                Text("Import Successful!")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Next Steps:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("1. Copy GeneratedDesignTokens.swift to your Xcode project")
                    Text("2. Replace existing design tokens with generated ones")
                    Text("3. Rebuild your app to use the new tokens")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
            
            if !generatedTokensPath.isEmpty {
                Button("View Generated File") {
                    // Open file location
                    let url = URL(fileURLWithPath: generatedTokensPath)
                    if FileManager.default.fileExists(atPath: url.path) {
                        #if os(macOS)
                        NSWorkspace.shared.selectFile(url.path, inFileViewerRootedAtPath: url.deletingLastPathComponent().path)
                        #endif
                    }
                }
                .font(.caption)
            }
        }
    }
    
    // MARK: - Actions
    
    private func importFromBundle() {
        Task {
            await performImport {
                try await FigmaIntegrationManager.shared.importFromBundle()
            }
        }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            Task {
                await performImport {
                    try await FigmaIntegrationManager.shared.importFromFile(at: url)
                }
            }
            
        case .failure(let error):
            importStatus = "❌ File selection failed: \(error.localizedDescription)"
        }
    }
    
    private func performImport(_ importOperation: @escaping () async throws -> Void) async {
        await MainActor.run {
            isImporting = true
            importSuccess = false
            importStatus = "🎨 Starting Figma variables import...\n"
        }
        
        do {
            try await importOperation()
            
            await MainActor.run {
                importStatus += "✅ Import completed successfully!\n"
                importStatus += "📱 iOS design tokens generated\n"
                importStatus += "🔄 Ready to use in your app\n"
                importSuccess = true
                
                // Set the generated file path
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                generatedTokensPath = documentsPath.appendingPathComponent("DesignSystem/GeneratedDesignTokens.swift").path
            }
            
        } catch {
            await MainActor.run {
                importStatus += "❌ Import failed: \(error.localizedDescription)\n"
                
                // Add troubleshooting info
                importStatus += "\n🔧 Troubleshooting:\n"
                importStatus += "• Check JSON file format\n"
                importStatus += "• Ensure variables are properly named\n"
                importStatus += "• Verify export includes colors, typography, spacing\n"
            }
        }
        
        await MainActor.run {
            isImporting = false
        }
    }
}

// MARK: - Preview
#Preview {
    FigmaImportView()
}

// MARK: - Figma Export Instructions View
struct FigmaExportInstructionsView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    instructionSection(
                        title: "1. Open Your Figma File",
                        description: "Open the Figma file containing your design variables",
                        icon: "square.and.pencil"
                    )
                    
                    instructionSection(
                        title: "2. Access Variables Panel",
                        description: "In the right sidebar, click on the Variables tab (🔗 icon)",
                        icon: "sidebar.right"
                    )
                    
                    instructionSection(
                        title: "3. Export Variables",
                        description: "Click the export button and choose JSON format. Save as 'figma-tokens.json'",
                        icon: "square.and.arrow.down"
                    )
                    
                    instructionSection(
                        title: "4. Add to App",
                        description: "Add the JSON file to your app bundle or use the file picker in the import view",
                        icon: "plus.circle"
                    )
                    
                    recommendedStructureSection
                    
                    troubleshootingSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Export Instructions")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private func instructionSection(title: String, description: String, icon: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var recommendedStructureSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recommended Variable Structure")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Colors:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("• color/primitive/white")
                    Text("• color/primitive/gray-100")
                    Text("• color/semantic/surface-primary")
                    Text("• color/semantic/text-primary")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Typography:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("• typography/font-size/h1")
                    Text("• typography/font-weight/semibold")
                    Text("• typography/letter-spacing/tight")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Spacing:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("• spacing/lg (16px)")
                    Text("• spacing/component/screen-padding")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var troubleshootingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Troubleshooting")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("If export fails:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("• Use 'Design Tokens' plugin as alternative")
                    Text("• Check variable naming follows conventions")
                    Text("• Ensure all variables have values assigned")
                    Text("• Try exporting smaller groups of variables")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview("Instructions") {
    FigmaExportInstructionsView()
}
