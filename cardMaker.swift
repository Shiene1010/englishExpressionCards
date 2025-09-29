import SwiftUI
import Combine

// 카드 데이터 모델
struct Card: Codable, Identifiable {
    var id = UUID()
    var expression: String
    var meaning: String
    var example: String
    var createdAt: String
}

// GitHub API 업로드 담당 클래스
class GitHubUploader: ObservableObject {
    let token: String
    let owner: String = "Shiene1010"
    let repo: String = "englishExpressionCards"
    let branch: String = "main"
    
    init(token: String) {
        self.token = token
    }

    func uploadFile(path: String, content: Data, message: String, completion: @escaping (Result<Void, Error>) -> Void) {
        getFileSha(path: path) { shaResult in
            switch shaResult {
            case .success(let sha):
                self.sendPutRequest(path: path, content: content, message: message, sha: sha, completion: completion)
            case .failure:
                self.sendPutRequest(path: path, content: content, message: message, sha: nil, completion: completion)
            }
        }
    }

    private func getFileSha(path: String, completion: @escaping (Result<String?, Error>) -> Void) {
        let urlStr = "https://api.github.com/repos/\(owner)/\(repo)/contents/\(path)?ref=\(branch)"
        guard let url = URL(string: urlStr) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 2)))
                return
            }
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any], let sha = json["sha"] as? String {
                completion(.success(sha))
            } else {
                completion(.success(nil))
            }
        }.resume()
    }

    private func sendPutRequest(path: String, content: Data, message: String, sha: String?, completion: @escaping (Result<Void, Error>) -> Void) {
        let urlStr = "https://api.github.com/repos/\(owner)/\(repo)/contents/\(path)"
        guard let url = URL(string: urlStr) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 1)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let base64Content = content.base64EncodedString()
        var bodyDict: [String: Any] = [
            "message": message,
            "content": base64Content,
            "branch": branch
        ]
        if let sha = sha {
            bodyDict["sha"] = sha
        }

        request.httpBody = try? JSONSerialization.data(withJSONObject: bodyDict)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let resp = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "Invalid response", code: 3)))
                return
            }
            if resp.statusCode == 200 || resp.statusCode == 201 {
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "GitHub API error", code: resp.statusCode)))
            }
        }.resume()
    }
}

// 뷰 모델: 카드 생성, 관리, 업로드 기능
class CardViewModel: ObservableObject {
    @Published var expression = ""
    @Published var meaning = ""
    @Published var example = ""
    @Published var cards: [Card] = []
    
    private var uploader: GitHubUploader

    // 본인의 GitHub Personal Access Token 으로 교체하세요
    init() {
        let token = "<YOUR_PERSONAL_ACCESS_TOKEN>"
        uploader = GitHubUploader(token: token)
    }
    
    func createCard() {
        let now = ISO8601DateFormatter().string(from: Date())
        let card = Card(expression: expression, meaning: meaning, example: example, createdAt: now)
        cards.append(card)
        saveAndUploadCard(card)
        clearInput()
    }
    
    private func saveAndUploadCard(_ card: Card) {
        do {
            let data = try JSONEncoder().encode(card)
            let filename = "\(card.expression).json"
            uploader.uploadFile(path: filename, content: data, message: "Add card \(card.expression)") { result in
                switch result {
                case .success:
                    self.updateCentralPage()
                case .failure(let error):
                    print("Upload card error: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Encoding error: \(error.localizedDescription)")
        }
    }
    
    private func updateCentralPage() {
        do {
            let data = try JSONEncoder().encode(cards)
            uploader.uploadFile(path: "expressionsPage.json", content: data, message: "Update central page cards list") { result in
                if case .failure(let error) = result {
                    print("Updating central page error: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Encoding central page error: \(error.localizedDescription)")
        }
    }
    
    private func clearInput() {
        DispatchQueue.main.async {
            self.expression = ""
            self.meaning = ""
            self.example = ""
        }
    }
}

// UI 뷰 정의
struct ContentView: View {
    @StateObject var viewModel = CardViewModel()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Expression", text: $viewModel.expression)
                .textFieldStyle(.roundedBorder)
            TextField("Meaning", text: $viewModel.meaning)
                .textFieldStyle(.roundedBorder)
            TextField("Example", text: $viewModel.example)
                .textFieldStyle(.roundedBorder)
            
            Button("Create Card") {
                viewModel.createCard()
            }
            .buttonStyle(.borderedProminent)
            .padding(.vertical, 10)

            List(viewModel.cards) { card in
                VStack(alignment: .leading) {
                    Text(card.expression).font(.headline)
                    Text(card.meaning)
                    Text(card.example).italic()
                    Text(card.createdAt).font(.caption).foregroundColor(.gray)
                }
                .padding(4)
            }
        }
        .padding()
    }
}

// 앱 진입점
@main
struct CardMakerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
