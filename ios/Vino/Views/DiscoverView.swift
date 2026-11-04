import SwiftUI
import SwiftData

struct DiscoverView: View {
    @Query private var wines: [Wine]
    @AppStorage("nameA") private var nameA = "Me"
    @AppStorage("nameB") private var nameB = "Fiancée"

    /// "" = both of us, otherwise a person's name.
    @State private var person = ""
    @State private var food = ""

    private var tastings: [TastedWine] {
        wines
            .filter { !$0.isWishlist && $0.rating > 0 }
            .filter { person.isEmpty || $0.taster == person || $0.taster.isEmpty }
            .map { TastedWine(grape: $0.grape, rating: $0.rating) }
    }

    private var profile: TasteProfile? { Recommender.profile(from: tastings) }
    private var recommendations: [Recommendation] { Recommender.recommend(from: tastings) }
    private var pairings: [Grape] { Recommender.grapes(forFood: food) }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("Recommend for", selection: $person) {
                        Text("Both of us").tag("")
                        Text(nameA).tag(nameA)
                        Text(nameB).tag(nameB)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Your taste") {
                    if let profile {
                        MeterRow(label: "Body", value: profile.body)
                        MeterRow(label: "Acidity", value: profile.acidity)
                        MeterRow(label: "Tannin", value: profile.tannin)
                        MeterRow(label: "Sweetness", value: profile.sweetness)
                    } else {
                        Text("Rate a few wines 4★ or higher in the Journal and your taste profile will appear here.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Section(profile == nil ? "Good places to start" : "Try next") {
                    if recommendations.isEmpty {
                        Text("You've explored everything in our catalog. Impressive!")
                            .foregroundStyle(.secondary)
                    }
                    ForEach(recommendations) { rec in
                        NavigationLink {
                            GrapeDetailView(grape: rec.grape)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                GrapeRow(grape: rec.grape)
                                Text(rec.reason)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section {
                    TextField("e.g. grilled salmon, spicy thai, pizza", text: $food)
                        .textInputAutocapitalization(.never)
                    if !food.isEmpty && pairings.isEmpty {
                        Text("No match found. Try a simpler word like 'steak' or 'cheese'.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    ForEach(pairings.prefix(6)) { grape in
                        NavigationLink {
                            GrapeDetailView(grape: grape)
                        } label: {
                            GrapeRow(grape: grape)
                        }
                    }
                } header: {
                    Text("What are you eating?")
                } footer: {
                    Text("Type a dish or ingredient to find wines that go with it.")
                }
            }
            .navigationTitle("Discover")
        }
    }
}
