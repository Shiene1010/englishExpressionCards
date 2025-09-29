import SwiftUI

struct Card: Codable, Identifiable, Hashable {
    var id: String
    var expression: String
    var meaning: String
    var example: String
    var createdAt: String
}

class CardListFetcher: ObservableObject {
    @Published var cards: [Card] = []
    @Published var errorMessage: String?

    func fetchCards(from urlString: String) {
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                do {
                    let decoded = try JSONDecoder().decode([Card].self, from: data)
                    self.cards = decoded
                    self.errorMessage = nil
                } catch {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

struct ContentView: View {
    @StateObject private var cardListFetcher = CardListFetcher()
    @State private var selectedCard: Card?

    let cardListURL = "https://shiene1010.github.io/englishExpressionCards/expressionsPage.json"

    var body: some View {
        NavigationView {
            VStack {
                Text("Available Cards")
                    .font(.headline)
                    .padding(.top)

                if let error = cardListFetcher.errorMessage {
                    Text("Error: \(error)").foregroundColor(.red)
                }

                List(selection: $selectedCard) {
                    ForEach(cardListFetcher.cards) { card in
                        Text(card.expression)
                            .tag(card)
                    }
                }
                .listStyle(PlainListStyle())

                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    if let card = selectedCard {
                        Text("Expression: \(card.expression)").font(.title)
                        Text("Meaning: \(card.meaning)").font(.headline)
                        Text("Example: \(card.example)").italic()
                        Text("Created At: \(card.createdAt)").font(.caption)
                    } else {
                        Text("Select a card from the list")
                            .italic()
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("English Cards")
            .onAppear {
                cardListFetcher.fetchCards(from: cardListURL)
            }
            // 강제로 선택 상태 갱신 트리거를 위해 onTapGesture로 리셋 후 재할당
            .onChange(of: selectedCard) { selected in
                guard let selected = selected else { return }
                DispatchQueue.main.async {
                    // 임시로 선택 해제 → 재선택해서 강제 UI 갱신 유도
                    let cardToReSelect = selected
                    selectedCard = nil
                    selectedCard = cardToReSelect
                }
            }
        }
    }
}

@main
struct CardListApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
