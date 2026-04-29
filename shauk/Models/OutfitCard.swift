import Foundation

// MARK: - OutfitCard

struct OutfitCard: Codable, Identifiable {
    let id: String
    let brand: String
    let name: String
    let price: String?
    let occasion: String?
    let tags: [String]
    let thumbnailURL: String?
    let imageURL: String?
    let sourceURL: String

    enum CodingKeys: String, CodingKey {
        case id, brand, name, price, occasion, tags
        case thumbnailURL = "thumbnail_url"
        case imageURL     = "image_url"
        case sourceURL    = "sourceURL"
    }

    init(id: String, brand: String, name: String, price: String?, occasion: String?,
         tags: [String], thumbnailURL: String? = nil, imageURL: String? = nil, sourceURL: String) {
        self.id = id
        self.brand = brand
        self.name = name
        self.price = price
        self.occasion = occasion
        self.tags = tags
        self.thumbnailURL = thumbnailURL
        self.imageURL = imageURL
        self.sourceURL = sourceURL
    }

    func withImageURL(_ url: String, resolvedURL: String?) -> OutfitCard {
        OutfitCard(id: id, brand: brand, name: name, price: price,
                   occasion: occasion, tags: tags,
                   thumbnailURL: thumbnailURL, imageURL: url,
                   sourceURL: resolvedURL ?? sourceURL)
    }
}

// MARK: - SearchResponse

struct SearchResponse: Codable {
    let ok: Bool
    let cards: [OutfitCard]?
    let error: String?
}
