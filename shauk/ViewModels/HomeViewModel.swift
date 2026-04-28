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
            fetchScreenshots(for: cards)
        } catch {
            phase = .error(error.localizedDescription)
        }
    }

    private func fetchScreenshots(for cards: [OutfitCard]) {
        Task {
            await withTaskGroup(of: (String, String?, Bool).self) { group in
                for card in cards {
                    group.addTask {
                        do {
                            let image = try await APIService.shared.screenshot(url: card.sourceURL)
                            return (card.id, image, false)
                        } catch {
                            return (card.id, nil, true)
                        }
                    }
                }
                for await (id, image, failed) in group {
                    if let image {
                        self.updateCard(id: id, imageBase64: image)
                    } else if failed {
                        self.markCardFailed(id: id)
                    }
                }
            }
        }
    }

    private func updateCard(id: String, imageBase64: String) {
        guard case .results(var cards) = phase,
              let idx = cards.firstIndex(where: { $0.id == id }) else { return }
        cards[idx] = cards[idx].withImage(imageBase64)
        phase = .results(cards)
    }

    private func markCardFailed(id: String) {
        guard case .results(var cards) = phase,
              let idx = cards.firstIndex(where: { $0.id == id }) else { return }
        cards[idx] = cards[idx].withImageFailed()
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
