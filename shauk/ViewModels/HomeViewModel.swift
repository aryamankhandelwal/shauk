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
    var likedIDs: Set<String> = []
    private var currentOccasionSearch: String = ""

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

    func loadSavedIDs() async {
        likedIDs = (try? await SupabaseService.shared.fetchSavedIDs()) ?? []
    }

    func toggleLike(_ card: OutfitCard) {
        if likedIDs.contains(card.id) {
            likedIDs.remove(card.id)
            Task { try? await SupabaseService.shared.unsaveOutfit(cardID: card.id) }
        } else {
            likedIDs.insert(card.id)
            let search = currentOccasionSearch
            Task { try? await SupabaseService.shared.saveOutfit(card, occasionSearch: search) }
        }
    }

    func search() async {
        guard canSearch else { return }
        let query = prompt.trimmingCharacters(in: .whitespaces)
        currentOccasionSearch = query
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

    /// Maximum concurrent screenshot requests to avoid overwhelming the API.
    private let maxConcurrentScreenshots = 4

    private func fetchImageURLs(for cards: [OutfitCard]) {
        Task {
            await withTaskGroup(of: (String, String?, String?).self) { group in
                var inFlight = 0
                var cardIterator = cards.makeIterator()

                // Seed the group with initial batch
                while inFlight < maxConcurrentScreenshots, let card = cardIterator.next() {
                    inFlight += 1
                    group.addTask {
                        do {
                            let result = try await APIService.shared.screenshot(url: card.sourceURL, thumbnailURL: card.thumbnailURL)
                            return (card.id, result.imageURL, result.resolvedURL)
                        } catch {
                            return (card.id, nil, nil)
                        }
                    }
                }

                // As each completes, enqueue the next card
                for await (id, imageURL, resolvedURL) in group {
                    if let imageURL {
                        self.updateCard(id: id, imageURL: imageURL, resolvedURL: resolvedURL)
                    }
                    if let card = cardIterator.next() {
                        group.addTask {
                            do {
                                let result = try await APIService.shared.screenshot(url: card.sourceURL, thumbnailURL: card.thumbnailURL)
                                return (card.id, result.imageURL, result.resolvedURL)
                            } catch {
                                return (card.id, nil, nil)
                            }
                        }
                    }
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
