import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss

    // UI-only state
    @State private var showKey = false

    var body: some View {
        @Bindable var vm = viewModel

        NavigationStack {
            Form {
                Section {
                    HStack {
                        if showKey {
                            TextField("sk-ant-...", text: $vm.apiKey)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                                .font(.system(.body, design: .monospaced))
                        } else {
                            SecureField("sk-ant-...", text: $vm.apiKey)
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
                        .accessibilityLabel(showKey ? "Hide API key" : "Show API key")
                    }
                } header: {
                    Text("Anthropic API Key")
                } footer: {
                    Text("Required for AI idea generation. Get your key at console.anthropic.com. Your key is stored only on this device.")
                }

                Section {
                    Button {
                        withAnimation {
                            viewModel.save()
                        }
                    } label: {
                        HStack {
                            Text("Save API Key")
                                .fontWeight(.semibold)
                            Spacer()
                            if viewModel.saved {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                }

                Section("About") {
                    LabeledContent("App", value: "Drillboard")
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("AI Model", value: viewModel.modelID)
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
