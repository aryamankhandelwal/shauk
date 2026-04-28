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
    let imageFailed: Bool

    enum CodingKeys: String, CodingKey {
        case id, brand, name, price, occasion, tags
        case imageBase64 = "image_base64"
        case sourceURL   = "sourceURL"
        case imageFailed = "image_failed"
    }

    init(id: String, brand: String, name: String, price: String?, occasion: String?,
         tags: [String], imageBase64: String?, sourceURL: String, imageFailed: Bool = false) {
        self.id = id
        self.brand = brand
        self.name = name
        self.price = price
        self.occasion = occasion
        self.tags = tags
        self.imageBase64 = imageBase64
        self.sourceURL = sourceURL
        self.imageFailed = imageFailed
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        brand = try c.decode(String.self, forKey: .brand)
        name = try c.decode(String.self, forKey: .name)
        price = try c.decodeIfPresent(String.self, forKey: .price)
        occasion = try c.decodeIfPresent(String.self, forKey: .occasion)
        tags = try c.decode([String].self, forKey: .tags)
        imageBase64 = try c.decodeIfPresent(String.self, forKey: .imageBase64)
        sourceURL = try c.decode(String.self, forKey: .sourceURL)
        imageFailed = try c.decodeIfPresent(Bool.self, forKey: .imageFailed) ?? false
    }

    func withImage(_ base64: String) -> OutfitCard {
        OutfitCard(id: id, brand: brand, name: name, price: price,
                   occasion: occasion, tags: tags, imageBase64: base64, sourceURL: sourceURL)
    }

    func withImageFailed() -> OutfitCard {
        OutfitCard(id: id, brand: brand, name: name, price: price,
                   occasion: occasion, tags: tags, imageBase64: nil, sourceURL: sourceURL, imageFailed: true)
    }

    func withImageAndURL(_ base64: String, resolvedURL: String?) -> OutfitCard {
        OutfitCard(id: id, brand: brand, name: name, price: price,
                   occasion: occasion, tags: tags, imageBase64: base64,
                   sourceURL: resolvedURL ?? sourceURL)
    }
}

// MARK: - SearchResponse

struct SearchResponse: Codable {
    let ok: Bool
    let cards: [OutfitCard]?
    let error: String?
}
