import SwiftUI
import SwiftData

/// Shared form sections for adding and editing a wine. Place inside a `Form`.
struct WineForm: View {
    @Bindable var wine: Wine
    @AppStorage("nameA") private var nameA = "Me"
    @AppStorage("nameB") private var nameB = "Fiancée"

    var body: some View {
        LabelScanSection(wine: wine)

        Section {
            TextField("Name", text: $wine.name)
            TextField("Producer / winery", text: $wine.producer)
            TextField("Vintage (year)", value: $wine.vintage, format: .number.grouping(.never))
                .keyboardType(.numberPad)
            Picker("Style", selection: $wine.style) {
                ForEach(WineStyle.allCases) { Text($0.rawValue).tag($0) }
            }
        } header: {
            SerifHeader(text: "Wine")
        }
        .vinoRows()

        Section {
            HStack {
                TextField("Grape / variety", text: $wine.grape)
                Menu {
                    ForEach(GrapeCatalog.all) { grape in
                        Button(grape.name) {
                            wine.grape = grape.name
                            wine.style = grape.style
                        }
                    }
                } label: {
                    Image(systemName: "list.bullet")
                }
                .accessibilityLabel("Choose grape")
            }
            TextField("Region", text: $wine.region)
            TextField("Country", text: $wine.country)
            TextField("Price", value: $wine.price, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                .keyboardType(.decimalPad)
        } header: {
            SerifHeader(text: "Grape & origin")
        }
        .vinoRows()

        Section {
            Toggle("Wishlist (haven't tried it yet)", isOn: $wine.isWishlist)
            if !wine.isWishlist {
                HStack {
                    Text("Rating")
                    Spacer()
                    StarRating(rating: $wine.rating)
                }
                Picker("Tasted by", selection: $wine.taster) {
                    Text("Both of us").tag("")
                    Text(nameA).tag(nameA)
                    Text(nameB).tag(nameB)
                }
            }
            TextField("Notes: aromas, flavors, food, occasion…", text: $wine.notes, axis: .vertical)
                .lineLimit(3...8)
        } header: {
            SerifHeader(text: "Your take")
        }
        .vinoRows()
    }
}

struct AddWineView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var wine: Wine

    init(startOnWishlist: Bool = false) {
        _wine = State(initialValue: Wine(isWishlist: startOnWishlist))
    }

    var body: some View {
        NavigationStack {
            Form { WineForm(wine: wine) }
                .vinoScreen()
                .navigationTitle("Add Wine")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            context.insert(wine)
                            dismiss()
                        }
                        .disabled(wine.name.isEmpty && wine.grape.isEmpty)
                    }
                }
        }
    }
}

struct WineDetailView: View {
    @Bindable var wine: Wine

    var body: some View {
        Form {
            WineForm(wine: wine)

            if let grape = wine.catalogGrape {
                Section {
                    NavigationLink {
                        GrapeDetailView(grape: grape)
                    } label: {
                        GrapeRow(grape: grape)
                    }
                } header: {
                    SerifHeader(text: "Learn about this grape")
                }
                .vinoRows()
            }
        }
        .vinoScreen()
        .navigationTitle(wine.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Lets you set the two names used for "Tasted by" and per-person recommendations.
struct NamesView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("nameA") private var nameA = "Me"
    @AppStorage("nameB") private var nameB = "Fiancée"

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("First person", text: $nameA)
                    TextField("Second person", text: $nameB)
                } footer: {
                    Text("Used to track who tasted each wine and to give each of you your own recommendations.")
                }
                .vinoRows()
            }
            .vinoScreen()
            .navigationTitle("Names")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}
