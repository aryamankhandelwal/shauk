import Foundation

// MARK: - OutfitCard

struct OutfitCard: Codable, Identifiable {
    let id: String
    let brand: String
    let name: String
    let price: String?
    let occasion: String?
    let tags: [String]
    let imageBase64: String?
    let sourceURL: String

    enum CodingKeys: String, CodingKey {
        case id, brand, name, price, occasion, tags
        case imageBase64 = "image_base64"
        case sourceURL   = "sourceURL"
    }

    func withImage(_ base64: String) -> OutfitCard {
        OutfitCard(id: id, brand: brand, name: name, price: price,
                   occasion: occasion, tags: tags, imageBase64: base64, sourceURL: sourceURL)
    }
}

// MARK: - SearchResponse

struct SearchResponse: Codable {
    let ok: Bool
    let cards: [OutfitCard]?
    let error: String?
}
