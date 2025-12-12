import SwiftUI
import SwiftData

/// Home screen view
/// Demonstrates SwiftData integration and navigation
struct HomeView: View {

    // MARK: - Properties

    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var router: Router
    @Query(sort: \SampleItem.createdAt, order: .reverse) private var items: [SampleItem]

    @StateObject private var viewModel = HomeViewModel()
    @State private var showingAddSheet = false

    // MARK: - Body

    var body: some View {
        content
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    addButton
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddItemSheet { name, description in
                    addItem(name: name, description: description)
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        if items.isEmpty {
            emptyState
        } else {
            itemsList
        }
    }

    private var itemsList: some View {
        List {
            ForEach(items) { item in
                ItemRow(item: item)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        router.push(.detail(item: item))
                    }
            }
            .onDelete(perform: deleteItems)
        }
        .listStyle(.insetGrouped)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Items", systemImage: "tray")
        } description: {
            Text("Add your first item to get started")
        } actions: {
            Button("Add Item") {
                showingAddSheet = true
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var addButton: some View {
        Button {
            showingAddSheet = true
        } label: {
            Image(systemName: "plus")
        }
    }

    // MARK: - Actions

    private func addItem(name: String, description: String?) {
        withAnimation {
            let newItem = SampleItem(name: name, itemDescription: description)
            modelContext.insert(newItem)
            Log.data("Created new item: \(name)")
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let item = items[index]
                modelContext.delete(item)
                Log.data("Deleted item: \(item.name)")
            }
        }
    }
}

// MARK: - Item Row

struct ItemRow: View {
    let item: SampleItem

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)

                if let description = item.itemDescription {
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Spacer()

            if item.isFavorite {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Item Sheet

struct AddItemSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var description = ""

    let onSave: (String, String?) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    TextField("Name", text: $name)
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("New Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(name, description.isEmpty ? nil : description)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HomeView()
    }
    .environmentObject(Router())
    .modelContainer(for: SampleItem.self, inMemory: true)
}
