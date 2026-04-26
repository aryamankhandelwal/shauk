import Foundation

// MARK: - APIService
// Stub for Phase 2. Will handle search, polling, and results.

final class APIService {
    static let shared = APIService()
    private init() {}

    private var baseURL: URL {
        URL(string: Secrets.apiBaseURL)!
    }
}
