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
    @State private var isPortland = false
    @State private var isSaving = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @FocusState private var isNameFocused: Bool

    var isEditing: Bool { player != nil }

    var body: some View {
        ZStack {
            TronGridBackground()

            ScrollView {
                VStack(spacing: 18) {
                    HStack {
                        Button(action: { dismiss() }) { Color.clear }
                            .buttonStyle(.srImage("Cancel_Button"))
                            .frame(width: 104, height: 44)
                            .accessibilityLabel("Cancel")
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)

                    Image(isEditing ? "SR_Edit_Player_Title" : "SR_Add_Player_Title")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(.horizontal, 20)
                        .accessibilityLabel(isEditing ? "Edit player" : "Add player")

                    // Name field on the gold plate
                    SRArtPlate(isNameFocused ? "SR_Player_Name_Field_Selected" : "SR_Player_Name_Field_Unselected") { size in
                        TextField("", text: $name, prompt: Text("PLAYER NAME").foregroundColor(SRColors.gold.opacity(0.6)))
                            .font(SRFont.display(size.height * 0.20))
                            .foregroundColor(SRColors.text)
                            .multilineTextAlignment(.center)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.words)
                            .focused($isNameFocused)
                            .frame(width: size.width * 0.74)
                            .position(x: size.width * 0.5, y: size.height * 0.44)
                    }
                    .padding(.horizontal, 12)

                    // Portland players only appear for the Coattail Classic
                    Toggle(isOn: $isPortland) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("PORTLAND CHAPTER")
                                .font(SRFont.display(15))
                                .srGoldText()
                            Text("Coattail Classic only · not in LA stats")
                                .font(SRFont.mono(11))
                                .foregroundColor(SRColors.text.opacity(0.8))
                        }
                    }
                    .tint(SRColors.purple)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .srPlate(glow: SRColors.purple)
                    .padding(.horizontal, 24)

                    // Add Player / Save Changes
                    Button(action: savePlayer) {
                        GeometryReader { geo in
                            ZStack {
                                Image(systemName: isEditing ? "checkmark" : "plus")
                                    .font(.system(size: geo.size.height * 0.16, weight: .black))
                                    .foregroundColor(.black.opacity(0.75))
                                    .position(x: geo.size.width * 0.205, y: geo.size.height * 0.48)
                                Group {
                                    if isSaving {
                                        ProgressView().tint(SRColors.text)
                                    } else {
                                        Text(isEditing ? "SAVE CHANGES" : "ADD PLAYER")
                                            .font(SRFont.slab(geo.size.height * 0.15))
                                            .foregroundColor(SRColors.text)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.6)
                                    }
                                }
                                .frame(width: geo.size.width * 0.52)
                                .position(x: geo.size.width * 0.55, y: geo.size.height * 0.48)
                            }
                        }
                    }
                    .buttonStyle(.srImage("Primary_Action_Button_Blank"))
                    .padding(.horizontal, 20)
                    .opacity(trimmedName.isEmpty ? 0.5 : 1)
                    .disabled(trimmedName.isEmpty || isSaving)
                }
                .padding(.bottom, 24)
            }
        }
        .onAppear {
            if let player = player {
                name = player.name
                isPortland = player.isPortland
            }
        }
        .alert("ERROR", isPresented: $showingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespaces)
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
                    existingPlayer.teamName = isPortland ? Player.portlandChapter : nil
                    try await statsService.updatePlayer(existingPlayer)
                } else {
                    // Add new player
                    try await statsService.addPlayer(
                        name: trimmedName,
                        teamName: isPortland ? Player.portlandChapter : nil
                    )
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
