//
//  AddEditPlayerView.swift
//  Dong Country Ledger 5000
//
//  Add or edit player details
//

import SwiftUI

struct AddEditPlayerView: View {
    @EnvironmentObject var statsService: StatsService
    @Environment(\.dismiss) var dismiss

    let player: Player?

    @State private var name: String = ""
    @State private var isSaving = false
    @State private var showingError = false
    @State private var errorMessage = ""

    var isEditing: Bool { player != nil }

    var body: some View {
        NavigationStack {
            ZStack {
                TronGridBackground()

                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: isEditing ? "person.circle" : "person.badge.plus")
                                .font(.system(size: 48))
                                .foregroundColor(TronColors.cyan)
                                .neonGlow(color: TronColors.cyan, radius: 10)

                            Text(isEditing ? "EDIT PLAYER" : "NEW PLAYER")
                                .font(.system(size: 20, weight: .bold, design: .monospaced))
                                .foregroundColor(TronColors.cyan)
                        }
                        .padding(.top, 20)

                        // Form fields
                        VStack(spacing: 20) {
                            TronTextField(
                                title: "PLAYER NAME",
                                placeholder: "Enter name...",
                                text: $name,
                                color: TronColors.cyan
                            )
                        }
                        .padding(.horizontal, 16)

                        Spacer(minLength: 40)

                        // Save button
                        Button(action: savePlayer) {
                            HStack {
                                if isSaving {
                                    ProgressView()
                                        .tint(TronColors.darkBackground)
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: isEditing ? "checkmark.circle" : "plus.circle")
                                    Text(isEditing ? "SAVE CHANGES" : "ADD PLAYER")
                                }
                            }
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(TronColors.darkBackground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(name.isEmpty ? TronColors.dimText : TronColors.green)
                            .cornerRadius(12)
                            .neonGlow(color: name.isEmpty ? .clear : TronColors.green, radius: 10)
                        }
                        .disabled(name.isEmpty || isSaving)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(TronColors.orange)
                }
            }
            .onAppear {
                if let player = player {
                    name = player.name
                }
            }
            .alert("ERROR", isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private func savePlayer() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        isSaving = true

        Task {
            do {
                let trimmedName = name.trimmingCharacters(in: .whitespaces)

                if var existingPlayer = player {
                    // Update existing player
                    existingPlayer.name = trimmedName
                    try await statsService.updatePlayer(existingPlayer)
                } else {
                    // Add new player
                    try await statsService.addPlayer(name: trimmedName)
                }

                await MainActor.run {
                    dismiss()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }

            await MainActor.run {
                isSaving = false
            }
        }
    }
}

// MARK: - Tron Text Field
struct TronTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let color: Color
    var keyboardType: UIKeyboardType = .default

    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(color.opacity(0.8))

            TextField(placeholder, text: $text)
                .font(.system(size: 16, design: .monospaced))
                .foregroundColor(TronColors.primaryText)
                .keyboardType(keyboardType)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.words)
                .focused($isFocused)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(TronColors.surfaceBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isFocused ? color : color.opacity(0.3), lineWidth: isFocused ? 2 : 1)
                )
                .neonGlow(color: color, radius: isFocused ? 5 : 0)
        }
    }
}

#Preview {
    AddEditPlayerView(player: nil)
        .environmentObject(StatsService())
}
