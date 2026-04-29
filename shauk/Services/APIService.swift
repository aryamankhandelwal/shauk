import Foundation

// MARK: - APIError

enum APIError: LocalizedError {
    case searchFailed(String)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .searchFailed(let msg): return msg
        case .invalidResponse:       return "Received an unexpected response from the server."
        }
    }
}

// MARK: - SearchRequest

private struct SearchRequest: Encodable {
    let occasion: String
    let gender: String?
    let top_size: String?
    let bottom_size: String?
    let bust_in: Double?
    let waist_in: Double?
    let hips_in: Double?
    let chest_in: Double?
    let shoulders_in: Double?
    let sleeve_length_in: Double?
    let inseam_in: Double?
}

// MARK: - APIService

final class APIService {
    static let shared = APIService()
    private init() {}

    private var baseURL: URL {
        URL(string: Secrets.apiBaseURL)!
    }

    // MARK: - Search

    func search(occasion: String, profile: UserProfile?) async throws -> [OutfitCard] {
        var req = URLRequest(url: baseURL.appendingPathComponent("api/search"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 30

        let body = SearchRequest(
            occasion: occasion,
            gender: profile?.gender?.rawValue,
            top_size: profile?.topSize?.rawValue,
            bottom_size: profile?.bottomSize?.rawValue,
            bust_in: profile?.bustIn,
            waist_in: profile?.waistIn,
            hips_in: profile?.hipsIn,
            chest_in: profile?.chestIn,
            shoulders_in: profile?.shouldersIn,
            sleeve_length_in: profile?.sleeveLengthIn,
            inseam_in: profile?.inseamIn
        )
        req.httpBody = try JSONEncoder().encode(body)

        let (data, _) = try await URLSession.shared.data(for: req)
        let response = try JSONDecoder().decode(SearchResponse.self, from: data)

        guard response.ok, let cards = response.cards else {
            throw APIError.searchFailed(response.error ?? "Unknown error")
        }
        return cards
    }

    // MARK: - Screenshot

    struct ScreenshotResult {
        let imageBase64: String
        let resolvedURL: String?
    }

    func screenshot(url: String) async throws -> ScreenshotResult {
        var req = URLRequest(url: baseURL.appendingPathComponent("api/screenshot"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.timeoutInterval = 25

        req.httpBody = try JSONEncoder().encode(["url": url])

        let (data, _) = try await URLSession.shared.data(for: req)

        struct ScreenshotResponse: Decodable {
            let ok: Bool
            let image_base64: String?
            let resolved_url: String?
            let error: String?
        }

        let response = try JSONDecoder().decode(ScreenshotResponse.self, from: data)
        guard response.ok, let imageBase64 = response.image_base64 else {
            throw APIError.searchFailed(response.error ?? "Screenshot failed")
        }
        return ScreenshotResult(imageBase64: imageBase64, resolvedURL: response.resolved_url)
    }
}
