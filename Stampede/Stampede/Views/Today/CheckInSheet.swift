import SwiftUI

struct CheckInSheet: View {
    let card: StampCard
    let onConfirm: (String?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var note: String = ""
    @State private var didCheckIn = false

    private var cardColor: Color { Color(hex: card.color) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if didCheckIn {
                    // Celebration state
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: card.icon)
                            .font(.system(size: 60))
                            .foregroundStyle(cardColor)

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.green)

                        Text("Stamped!")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                    .transition(.scale.combined(with: .opacity))
                    Spacer()
                } else {
                    // Check-in form
                    VStack(spacing: 8) {
                        Image(systemName: card.icon)
                            .font(.system(size: 40))
                            .foregroundStyle(cardColor)
                        Text(card.name)
                            .font(.headline)
                    }
                    .padding(.top)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Note (optional)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        TextField("Add a note...", text: $note, axis: .vertical)
                            .lineLimit(3...5)
                            .textFieldStyle(.roundedBorder)
                            .onChange(of: note) { _, newValue in
                                if newValue.count > AppConstants.maxNoteLength {
                                    note = String(newValue.prefix(AppConstants.maxNoteLength))
                                }
                            }
                        Text("\(note.count)/\(AppConstants.maxNoteLength)")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.horizontal)

                    Spacer()

                    Button {
                        let trimmedNote = note.trimmingCharacters(in: .whitespaces)
                        onConfirm(trimmedNote.isEmpty ? nil : trimmedNote)

                        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                            didCheckIn = true
                        }

                        // Auto-dismiss after celebration
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            dismiss()
                        }
                    } label: {
                        Text("Check In")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(cardColor)
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle(didCheckIn ? "" : "Check In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !didCheckIn {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .interactiveDismissDisabled(didCheckIn)
    }
}
