import SwiftUI
import SwiftData

struct CardFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let cardToEdit: StampCard?
    let nextSortOrder: Int

    @State private var name: String
    @State private var icon: String
    @State private var colorHex: String
    @State private var allowsMultiple: Bool
    @State private var showIconPicker = false
    @State private var showColorPicker = false

    private var isEditing: Bool { cardToEdit != nil }
    private var isValid: Bool {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        return trimmed.count >= 1 && trimmed.count <= AppConstants.maxCardNameLength
    }

    init(card: StampCard? = nil, nextSortOrder: Int = 0) {
        self.cardToEdit = card
        self.nextSortOrder = nextSortOrder
        _name = State(initialValue: card?.name ?? "")
        _icon = State(initialValue: card?.icon ?? AppConstants.allIcons.first ?? "star.fill")
        _colorHex = State(initialValue: card?.color ?? AppConstants.colorPalette.first?.hex ?? "#FF7B6B")
        _allowsMultiple = State(initialValue: card?.allowsMultiple ?? false)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                        .onChange(of: name) { _, newValue in
                            if newValue.count > AppConstants.maxCardNameLength {
                                name = String(newValue.prefix(AppConstants.maxCardNameLength))
                            }
                        }
                }

                Section {
                    Toggle("Allow multiple check-ins per day", isOn: $allowsMultiple)
                }

                Section {
                    Button {
                        showIconPicker = true
                    } label: {
                        HStack {
                            Text("Icon")
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: icon)
                                .font(.title2)
                                .foregroundStyle(Color(hex: colorHex))
                        }
                    }

                    Button {
                        showColorPicker = true
                    } label: {
                        HStack {
                            Text("Color")
                                .foregroundStyle(.primary)
                            Spacer()
                            Circle()
                                .fill(Color(hex: colorHex))
                                .frame(width: 28, height: 28)
                        }
                    }
                }

                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 8) {
                            Image(systemName: icon)
                                .font(.system(size: 40))
                                .foregroundStyle(.white)
                            Text(name.isEmpty ? "Preview" : name)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                        }
                        .frame(width: 120, height: 120)
                        .background(Color(hex: colorHex))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                } header: {
                    Text("Preview")
                }
            }
            .navigationTitle(isEditing ? "Edit Card" : "New Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                        dismiss()
                    }
                    .disabled(!isValid)
                }
            }
            .sheet(isPresented: $showIconPicker) {
                IconPickerView(selectedIcon: $icon)
            }
            .sheet(isPresented: $showColorPicker) {
                ColorPickerGridView(selectedHex: $colorHex)
            }
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        if let card = cardToEdit {
            card.name = trimmedName
            card.icon = icon
            card.color = colorHex
            card.allowsMultiple = allowsMultiple
        } else {
            let card = StampCard(name: trimmedName, icon: icon, color: colorHex, sortOrder: nextSortOrder, allowsMultiple: allowsMultiple)
            modelContext.insert(card)
            print("[Stampede] Inserted card: \(trimmedName), sortOrder: \(nextSortOrder)")
        }
        do {
            try modelContext.save()
            print("[Stampede] Save succeeded")
        } catch {
            print("[Stampede] Save failed: \(error)")
        }
    }
}
