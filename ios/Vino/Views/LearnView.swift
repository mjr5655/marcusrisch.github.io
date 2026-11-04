import SwiftUI

struct LearnView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(LessonLibrary.all) { lesson in
                        NavigationLink {
                            LessonView(lesson: lesson)
                        } label: {
                            HStack(spacing: 14) {
                                Image(systemName: lesson.icon)
                                    .font(.title3)
                                    .foregroundStyle(Theme.gold)
                                    .frame(width: 40, height: 40)
                                    .background(Theme.gold.opacity(0.12), in: Circle())
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(lesson.title).font(.serif(.headline)).foregroundStyle(Theme.cream)
                                    Text(lesson.summary).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } header: {
                    SerifHeader(text: "Lessons")
                }
                .vinoRows()

                Section {
                    NavigationLink {
                        QuizView(title: "Wine Quiz", questions: LessonLibrary.allQuestions)
                    } label: {
                        Label("Full Quiz (\(LessonLibrary.allQuestions.count) questions)", systemImage: "checkmark.seal")
                    }
                } header: {
                    SerifHeader(text: "Practice")
                }
                .vinoRows()

                Section {
                    NavigationLink {
                        GrapeGuideView()
                    } label: {
                        Label("Grape Guide", systemImage: "leaf")
                    }
                    NavigationLink {
                        GlossaryView()
                    } label: {
                        Label("Glossary", systemImage: "character.book.closed")
                    }
                } header: {
                    SerifHeader(text: "Reference")
                }
                .vinoRows()
            }
            .vinoScreen()
            .navigationTitle("Learn")
        }
    }
}

struct LessonView: View {
    let lesson: Lesson

    var body: some View {
        List {
            ForEach(lesson.sections) { section in
                Section {
                    Text(section.body)
                        .lineSpacing(3)
                } header: {
                    SerifHeader(text: section.heading)
                }
                .vinoRows()
            }
            Section {
                NavigationLink {
                    QuizView(title: lesson.title, questions: lesson.quiz)
                } label: {
                    Label("Test yourself", systemImage: "questionmark.circle")
                }
            }
            .vinoRows()
        }
        .vinoScreen()
        .navigationTitle(lesson.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct QuizView: View {
    let title: String
    @State private var questions: [QuizQuestion]
    @State private var index = 0
    @State private var selected: Int?
    @State private var score = 0
    @State private var finished = false

    init(title: String, questions: [QuizQuestion]) {
        self.title = title
        _questions = State(initialValue: questions.shuffled())
    }

    var body: some View {
        Group {
            if finished {
                VStack(spacing: 16) {
                    Image(systemName: score * 2 >= questions.count ? "star.circle.fill" : "book.circle")
                        .font(.system(size: 64))
                        .foregroundStyle(Theme.gold)
                    Text("You scored \(score) of \(questions.count)")
                        .font(.title2.bold())
                    Button("Try again") { restart() }
                        .buttonStyle(GoldButtonStyle())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                let q = questions[index]
                List {
                    Section {
                        Text(q.question).font(.serif(.title3)).foregroundStyle(Theme.cream)
                    } header: {
                        SerifHeader(text: "Question \(index + 1) of \(questions.count)")
                    }
                    .vinoRows()
                    Section {
                        ForEach(q.options.indices, id: \.self) { i in
                            Button {
                                guard selected == nil else { return }
                                selected = i
                                if i == q.correctIndex { score += 1 }
                            } label: {
                                HStack {
                                    Text(q.options[i]).foregroundStyle(.primary)
                                    Spacer()
                                    if let selected {
                                        if i == q.correctIndex {
                                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                                        } else if i == selected {
                                            Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .vinoRows()
                    if selected != nil {
                        Section {
                            Text(q.explanation)
                            Button(index + 1 < questions.count ? "Next question" : "See results") {
                                if index + 1 < questions.count {
                                    index += 1
                                    selected = nil
                                } else {
                                    finished = true
                                }
                            }
                            .bold()
                        }
                        .vinoRows()
                    }
                }
                .vinoScreen()
            }
        }
        .background(Theme.navy.ignoresSafeArea())
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func restart() {
        questions.shuffle()
        index = 0
        selected = nil
        score = 0
        finished = false
    }
}

struct GrapeGuideView: View {
    @State private var search = ""

    private var grapes: [Grape] {
        search.isEmpty
            ? GrapeCatalog.all
            : GrapeCatalog.all.filter {
                $0.name.localizedCaseInsensitiveContains(search)
                    || $0.flavors.contains { f in f.localizedCaseInsensitiveContains(search) }
            }
    }

    var body: some View {
        List {
            ForEach(WineStyle.allCases) { style in
                let group = grapes.filter { $0.style == style }
                if !group.isEmpty {
                    Section {
                        ForEach(group) { grape in
                            NavigationLink {
                                GrapeDetailView(grape: grape)
                            } label: {
                                GrapeRow(grape: grape)
                            }
                        }
                    } header: {
                        SerifHeader(text: style.rawValue)
                    }
                    .vinoRows()
                }
            }
        }
        .vinoScreen()
        .navigationTitle("Grape Guide")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $search, prompt: "Grape or flavor")
    }
}

struct GrapeDetailView: View {
    let grape: Grape

    var body: some View {
        List {
            Section {
                HStack(spacing: 12) {
                    StyleBadge(style: grape.style, size: 44)
                    Text(grape.summary).lineSpacing(3)
                }
            }
            .vinoRows()
            Section {
                MeterRow(label: "Body", value: Double(grape.body), detail: grape.bodyWord)
                MeterRow(label: "Acidity", value: Double(grape.acidity), detail: grape.acidityWord)
                if grape.style == .red {
                    MeterRow(label: "Tannin", value: Double(grape.tannin), detail: grape.tanninWord)
                }
                MeterRow(label: "Sweetness", value: Double(grape.sweetness), detail: grape.sweetnessWord)
            } header: {
                SerifHeader(text: "Structure")
            }
            .vinoRows()
            Section {
                Text(grape.flavors.joined(separator: " · "))
            } header: {
                SerifHeader(text: "Typical flavors")
            }
            .vinoRows()
            Section {
                ForEach(grape.regions, id: \.self) { Text($0) }
            } header: {
                SerifHeader(text: "Where to look")
            }
            .vinoRows()
            Section {
                Text(grape.pairings.joined(separator: " · "))
            } header: {
                SerifHeader(text: "Pairs with")
            }
            .vinoRows()
            Section {
                Label {
                    Text(grape.tip).lineSpacing(3)
                } icon: {
                    Image(systemName: "lightbulb").foregroundStyle(Theme.gold)
                }
            } header: {
                SerifHeader(text: "Tip")
            }
            .vinoRows()
        }
        .vinoScreen()
        .navigationTitle(grape.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GlossaryView: View {
    @State private var search = ""

    private var terms: [GlossaryTerm] {
        search.isEmpty
            ? Glossary.terms
            : Glossary.terms.filter {
                $0.term.localizedCaseInsensitiveContains(search)
                    || $0.definition.localizedCaseInsensitiveContains(search)
            }
    }

    var body: some View {
        List(terms) { term in
            VStack(alignment: .leading, spacing: 4) {
                Text(term.term).font(.serif(.headline)).foregroundStyle(Theme.goldSoft)
                Text(term.definition).font(.subheadline).foregroundStyle(.secondary)
            }
            .padding(.vertical, 2)
            .listRowBackground(Theme.surface)
            .listRowSeparatorTint(Theme.hairline)
        }
        .vinoScreen()
        .navigationTitle("Glossary")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $search, prompt: "Search terms")
    }
}
