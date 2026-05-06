import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var apiKey: String = AIService.shared.apiKey
    @State private var showKey = false
    @State private var saved = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        if showKey {
                            TextField("sk-ant-...", text: $apiKey)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .font(.system(.body, design: .monospaced))
                        } else {
                            SecureField("sk-ant-...", text: $apiKey)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .font(.system(.body, design: .monospaced))
                        }
                        Button {
                            showKey.toggle()
                        } label: {
                            Image(systemName: showKey ? "eye.slash" : "eye")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                } header: {
                    Text("Anthropic API Key")
                } footer: {
                    Text("Required for AI idea generation. Get your key at console.anthropic.com. Your key is stored only on this device.")
                }

                Section {
                    Button {
                        AIService.shared.apiKey = apiKey.trimmingCharacters(in: .whitespaces)
                        withAnimation { saved = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation { saved = false }
                        }
                    } label: {
                        HStack {
                            Text("Save API Key")
                                .fontWeight(.semibold)
                            Spacer()
                            if saved {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }

                Section("About") {
                    LabeledContent("App", value: "Drillboard")
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("AI Model", value: AIService.modelID)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
