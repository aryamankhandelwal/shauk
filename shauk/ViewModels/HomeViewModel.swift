import Foundation

// MARK: - HomeViewModel

@Observable
@MainActor
final class HomeViewModel {

    // MARK: State

    var prompt: String = ""
    var phase: Phase = .idle
    var userProfile: UserProfile?
    var recentSearches: [String] = []

    // MARK: Phase

    enum Phase: Equatable {
        case idle
        case loading
        case results([OutfitCard])
        case error(String)

        static func == (lhs: Phase, rhs: Phase) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading): return true
            case (.error(let a), .error(let b)):       return a == b
            default:                                   return false
            }
        }
    }

    var canSearch: Bool { !prompt.trimmingCharacters(in: .whitespaces).isEmpty }

    // MARK: - Lifecycle

    func onAppear() async {
        loadRecentSearches()
        await loadProfile()
    }

    // MARK: - Profile

    func loadProfile() async {
        guard let idString = UserDefaults.standard.string(forKey: "supabaseUserId"),
              let id = UUID(uuidString: idString) else { return }
        userProfile = try? await SupabaseService.shared.fetchProfile(id: id)
    }

    // MARK: - Search

    func search() async {
        guard canSearch else { return }
        let query = prompt.trimmingCharacters(in: .whitespaces)
        addRecentSearch(query)
        phase = .loading
        do {
            let cards = try await APIService.shared.search(occasion: query, profile: userProfile)
            phase = .results(cards)
            fetchImageURLs(for: cards)
        } catch {
            phase = .error(error.localizedDescription)
        }
    }

    /// Maximum number of cards to show in the feed.
    private let maxDisplayCards = 6

    private func fetchImageURLs(for cards: [OutfitCard]) {
        Task {
            await withTaskGroup(of: (String, String?, String?).self) { group in
                for card in cards {
                    group.addTask {
                        do {
                            let result = try await APIService.shared.screenshot(url: card.sourceURL)
                            return (card.id, result.imageURL, result.resolvedURL)
                        } catch {
                            return (card.id, nil, nil)
                        }
                    }
                }
                for await (id, imageURL, resolvedURL) in group {
                    if let imageURL {
                        self.updateCard(id: id, imageURL: imageURL, resolvedURL: resolvedURL)
                    }
                    // Failed screenshots are silently ignored — card keeps its thumbnail
                }
            }
        }
    }

    private func updateCard(id: String, imageURL: String, resolvedURL: String?) {
        guard case .results(var cards) = phase,
              let idx = cards.firstIndex(where: { $0.id == id }) else { return }
        cards[idx] = cards[idx].withImageURL(imageURL, resolvedURL: resolvedURL)
        phase = .results(cards)
    }

    func searchChip(_ text: String) async {
        prompt = text
        await search()
    }

    func reset() {
        phase = .idle
    }

    // MARK: - Recent Searches

    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: "recentSearches") ?? []
    }

    private func addRecentSearch(_ query: String) {
        var searches = recentSearches
        searches.removeAll { $0 == query }
        searches.insert(query, at: 0)
        recentSearches = Array(searches.prefix(5))
        UserDefaults.standard.set(recentSearches, forKey: "recentSearches")
    }
}
