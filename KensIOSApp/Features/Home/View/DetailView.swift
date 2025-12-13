import SwiftUI
import SwiftData

/// Detail view for a single item
struct DetailView: View {

    // MARK: - Properties

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Bindable var item: SampleItem

    @State private var isEditing = false
    @State private var editedName: String = ""
    @State private var editedDescription: String = ""

    // MARK: - Body

    var body: some View {
        Form {
            detailsSection
            metadataSection
            actionsSection
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(isEditing ? "Done" : "Edit") {
                    if isEditing {
                        saveChanges()
                    } else {
                        startEditing()
                    }
                }
            }
        }
    }

    // MARK: - Sections

    private var detailsSection: some View {
        Section("Details") {
            if isEditing {
                TextField("Name", text: $editedName)
                TextField("Description", text: $editedDescription, axis: .vertical)
                    .lineLimit(3...6)
            } else {
                LabeledContent("Name", value: item.name)

                if let description = item.itemDescription {
                    LabeledContent("Description") {
                        Text(description)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private var metadataSection: some View {
        Section("Metadata") {
            LabeledContent("Created") {
                Text(item.createdAt, style: .date)
            }

            LabeledContent("Updated") {
                Text(item.updatedAt, style: .relative)
            }

            Toggle("Favorite", isOn: $item.isFavorite)
        }
    }

    private var actionsSection: some View {
        Section {
            Button("Delete Item", role: .destructive) {
                deleteItem()
            }
        }
    }

    // MARK: - Actions

    private func startEditing() {
        editedName = item.name
        editedDescription = item.itemDescription ?? ""
        isEditing = true
    }

    private func saveChanges() {
        item.update(
            name: editedName,
            description: editedDescription.isEmpty ? nil : editedDescription
        )
        isEditing = false
        Log.data("Updated item: \(item.name)")
    }

    private func deleteItem() {
        modelContext.delete(item)
        dismiss()
        Log.data("Deleted item from detail view")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DetailView(item: SampleItem.preview)
    }
    .modelContainer(for: SampleItem.self, inMemory: true)
}
