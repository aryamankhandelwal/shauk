import Foundation
import Supabase

// MARK: - Errors

enum SupabaseServiceError: LocalizedError {
    case notAuthenticated
    case saveFailedAfterRetry

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:    return "Unable to create your account. Please check your connection and try again."
        case .saveFailedAfterRetry: return "Could not save your profile. Please check your connection and try again."
        }
    }
}

// MARK: - SupabaseService

@MainActor
final class SupabaseService {
    static let shared = SupabaseService()

    private let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: Secrets.supabaseURL)!,
            supabaseKey: Secrets.supabaseAnonKey
        )
    }

    // MARK: - Auth

    /// Returns the current user's UUID, signing in anonymously if needed.
    func currentUserID() async throws -> UUID {
        if let user = client.auth.currentUser {
            return user.id
        }
        let session = try await client.auth.signInAnonymously()
        return session.user.id
    }

    // MARK: - User Profile

    /// Upserts the user profile. Retries once on failure.
    func saveProfile(_ profile: UserProfile) async throws {
        do {
            try await upsert(profile)
        } catch {
            // Retry once
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5s
            do {
                try await upsert(profile)
            } catch {
                throw SupabaseServiceError.saveFailedAfterRetry
            }
        }
    }

    private func upsert(_ profile: UserProfile) async throws {
        try await client
            .from("users")
            .upsert(profile, onConflict: "id")
            .execute()
    }

    /// Fetches the user's profile from Supabase.
    func fetchProfile(id: UUID) async throws -> UserProfile? {
        let response: [UserProfile] = try await client
            .from("users")
            .select()
            .eq("id", value: id.uuidString)
            .limit(1)
            .execute()
            .value
        return response.first
    }

    // MARK: - Saved Outfits

    /// Saves a liked outfit. Upserts on (user_id, id) so it is idempotent.
    func saveOutfit(_ card: OutfitCard, occasionSearch: String?) async throws {
        let userId = try await currentUserID()
        let record = SavedOutfitRecord(from: card, userId: userId, occasionSearch: occasionSearch)
        try await client
            .from("saved_outfits")
            .upsert(record, onConflict: "user_id,id")
            .execute()
    }

    /// Removes a saved outfit. No-ops silently if the row does not exist.
    func unsaveOutfit(cardID: String) async throws {
        let userId = try await currentUserID()
        try await client
            .from("saved_outfits")
            .delete()
            .eq("user_id", value: userId.uuidString)
            .eq("id", value: cardID)
            .execute()
    }

    /// Fetches all saved outfits for the current user, most recent first.
    func fetchSavedOutfits() async throws -> [SavedOutfitRecord] {
        let userId = try await currentUserID()
        let records: [SavedOutfitRecord] = try await client
            .from("saved_outfits")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("saved_at", ascending: false)
            .execute()
            .value
        return records
    }

    /// Fetches only the set of saved card IDs — lightweight, used to restore liked state.
    func fetchSavedIDs() async throws -> Set<String> {
        let userId = try await currentUserID()
        struct IDOnly: Decodable { let id: String }
        let rows: [IDOnly] = try await client
            .from("saved_outfits")
            .select("id")
            .eq("user_id", value: userId.uuidString)
            .execute()
            .value
        return Set(rows.map(\.id))
    }
}
