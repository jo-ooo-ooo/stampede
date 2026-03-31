import SwiftUI
import SwiftData

struct CardDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let card: StampCard

    @State private var showEditForm = false
    @State private var showDeleteConfirmation = false
    @State private var entryToEdit: StampEntry?
    @Environment(\.dismiss) private var dismiss

    private var sortedEntries: [StampEntry] {
        (card.entries ?? []).sorted { $0.date > $1.date }
    }

    private var totalCount: Int {
        card.entries?.count ?? 0
    }

    var body: some View {
        List {
            // Stats section
            Section {
                HStack {
                    Label("Total Stamps", systemImage: "checkmark.circle.fill")
                    Spacer()
                    Text("\(totalCount)")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: card.color))
                }
            }

            // Stamp history
            Section("History") {
                if sortedEntries.isEmpty {
                    Text("No stamps yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(sortedEntries) { entry in
                        Button {
                            entryToEdit = entry
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(entry.date.formatted(.dateTime.month(.wide).day().year()))
                                        .font(.body)
                                        .foregroundStyle(.primary)
                                    if let note = entry.note, !note.isEmpty {
                                        Text(note)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    } else {
                                        Text("Tap to add note")
                                            .font(.caption)
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                                Spacer()
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color(hex: card.color))
                            }
                        }
                    }
                    .onDelete(perform: deleteEntries)
                }
            }
        }
        .navigationTitle(card.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showEditForm = true
                    } label: {
                        Label("Edit Card", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        showDeleteConfirmation = true
                    } label: {
                        Label("Delete Card", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showEditForm) {
            CardFormView(card: card)
        }
        .sheet(item: $entryToEdit) { entry in
            NoteEditSheet(entry: entry)
        }
        .alert("Delete Card?", isPresented: $showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                modelContext.delete(card)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete \"\(card.name)\" and all its stamp entries. This cannot be undone.")
        }
    }

    private func deleteEntries(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sortedEntries[index])
        }
        try? modelContext.save()
    }
}

// MARK: - Note Edit Sheet

struct NoteEditSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let entry: StampEntry

    @State private var note: String

    init(entry: StampEntry) {
        self.entry = entry
        _note = State(initialValue: entry.note ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Note") {
                    TextField("Add a note...", text: $note, axis: .vertical)
                        .lineLimit(3...5)
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

                Section {
                    Text(entry.date.formatted(.dateTime.weekday(.wide).month(.wide).day().year()))
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Edit Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = note.trimmingCharacters(in: .whitespaces)
                        entry.note = trimmed.isEmpty ? nil : trimmed
                        try? modelContext.save()
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
