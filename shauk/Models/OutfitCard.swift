import Foundation

// MARK: - OutfitCard

struct OutfitCard: Codable, Identifiable {
    let id: String
    let brand: String
    let name: String
    let price: String?
    let priceNumeric: Double?
    let currency: String?
    let occasion: String?
    let tags: [String]
    let garmentType: String?
    let color: String?
    let fabric: String?
    let embellishments: [String]
    let thumbnailURL: String?
    let imageURL: String?
    let sourceURL: String

    enum CodingKeys: String, CodingKey {
        case id, brand, name, price, currency, occasion, tags
        case priceNumeric  = "price_numeric"
        case garmentType   = "garment_type"
        case color, fabric, embellishments
        case thumbnailURL  = "thumbnail_url"
        case imageURL      = "image_url"
        case sourceURL     = "sourceURL"
    }

    init(id: String, brand: String, name: String, price: String? = nil,
         priceNumeric: Double? = nil, currency: String? = nil,
         occasion: String? = nil, tags: [String] = [],
         garmentType: String? = nil, color: String? = nil,
         fabric: String? = nil, embellishments: [String] = [],
         thumbnailURL: String? = nil, imageURL: String? = nil, sourceURL: String) {
        self.id = id
        self.brand = brand
        self.name = name
        self.price = price
        self.priceNumeric = priceNumeric
        self.currency = currency
        self.occasion = occasion
        self.tags = tags
        self.garmentType = garmentType
        self.color = color
        self.fabric = fabric
        self.embellishments = embellishments
        self.thumbnailURL = thumbnailURL
        self.imageURL = imageURL
        self.sourceURL = sourceURL
    }

    func withImageURL(_ url: String, resolvedURL: String?) -> OutfitCard {
        OutfitCard(id: id, brand: brand, name: name, price: price,
                   priceNumeric: priceNumeric, currency: currency,
                   occasion: occasion, tags: tags,
                   garmentType: garmentType, color: color,
                   fabric: fabric, embellishments: embellishments,
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

// MARK: - SavedOutfitRecord

struct SavedOutfitRecord: Codable, Identifiable {
    let id: String
    let userId: UUID
    let savedAt: Date
    let occasionSearch: String?
    let brand: String
    let name: String
    let price: String?
    let occasion: String?
    let tags: [String]
    let thumbnailURL: String?
    let imageURL: String?
    let sourceURL: String
    let garmentType: String?
    let color: String?
    let fabric: String?
    let embellishments: [String]
    let priceNumeric: Double?
    let currency: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userId          = "user_id"
        case savedAt         = "saved_at"
        case occasionSearch  = "occasion_search"
        case brand, name, price, occasion, tags
        case thumbnailURL    = "thumbnail_url"
        case imageURL        = "image_url"
        case sourceURL       = "source_url"
        case garmentType     = "garment_type"
        case color, fabric, embellishments
        case priceNumeric    = "price_numeric"
        case currency
    }

    init(from card: OutfitCard, userId: UUID, occasionSearch: String?) {
        self.id = card.id
        self.userId = userId
        self.savedAt = Date()
        self.occasionSearch = occasionSearch
        self.brand = card.brand
        self.name = card.name
        self.price = card.price
        self.occasion = card.occasion
        self.tags = card.tags
        self.thumbnailURL = card.thumbnailURL
        self.imageURL = card.imageURL
        self.sourceURL = card.sourceURL
        self.garmentType = card.garmentType
        self.color = card.color
        self.fabric = card.fabric
        self.embellishments = card.embellishments
        self.priceNumeric = card.priceNumeric
        self.currency = card.currency
    }

    func toOutfitCard() -> OutfitCard {
        OutfitCard(
            id: id, brand: brand, name: name, price: price,
            priceNumeric: priceNumeric, currency: currency,
            occasion: occasion, tags: tags,
            garmentType: garmentType, color: color,
            fabric: fabric, embellishments: embellishments,
            thumbnailURL: thumbnailURL, imageURL: imageURL,
            sourceURL: sourceURL
        )
    }
}
