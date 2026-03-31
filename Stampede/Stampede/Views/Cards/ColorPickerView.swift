import SwiftUI

struct ColorPickerGridView: View {
    @Binding var selectedHex: String
    @Environment(\.dismiss) private var dismiss

    private let columns = Array(repeating: GridItem(.flexible()), count: 4)

    var body: some View {
        NavigationStack {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(AppConstants.colorPalette) { paletteColor in
                    Button {
                        selectedHex = paletteColor.hex
                        dismiss()
                    } label: {
                        Circle()
                            .fill(paletteColor.color)
                            .frame(width: 56, height: 56)
                            .overlay(
                                Circle()
                                    .stroke(Color.primary, lineWidth: selectedHex == paletteColor.hex ? 3 : 0)
                                    .padding(2)
                            )
                            .overlay(
                                selectedHex == paletteColor.hex
                                    ? Image(systemName: "checkmark")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                    : nil
                            )
                    }
                }
            }
            .padding()
            .navigationTitle("Choose Color")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
