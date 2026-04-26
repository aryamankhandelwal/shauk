import Foundation

// MARK: - Supporting Enums

enum Gender: String, Codable, CaseIterable {
    case female
    case male
}

enum ClothingSize: String, Codable, CaseIterable {
    case xs  = "XS"
    case s   = "S"
    case m   = "M"
    case l   = "L"
    case xl  = "XL"
    case xxl = "XXL"
}

enum MeasurementUnit: String, CaseIterable {
    case inches = "Inches"
    case cm     = "CM"
}

// MARK: - Measurement Field

enum MeasurementField: CaseIterable {
    case bust, waist, hips, inseam, sleeveLength
    case chest, shoulders

    var label: String {
        switch self {
        case .bust:         return "Bust"
        case .waist:        return "Waist"
        case .hips:         return "Hips"
        case .inseam:       return "Inseam"
        case .sleeveLength: return "Sleeve Length"
        case .chest:        return "Chest"
        case .shoulders:    return "Shoulders"
        }
    }

    static func fields(for gender: Gender) -> [MeasurementField] {
        switch gender {
        case .female: return [.bust, .waist, .hips, .inseam, .sleeveLength]
        case .male:   return [.chest, .waist, .hips, .shoulders, .sleeveLength]
        }
    }

    /// Valid range in inches
    var inchRange: ClosedRange<Double> {
        switch self {
        case .bust, .chest:   return 24...60
        case .waist:          return 20...60
        case .hips:           return 24...65
        case .inseam:         return 24...40
        case .sleeveLength:   return 20...40
        case .shoulders:      return 14...24
        }
    }

    /// Valid range in cm
    var cmRange: ClosedRange<Double> {
        switch self {
        case .bust, .chest:   return 60...152
        case .waist:          return 50...152
        case .hips:           return 60...165
        case .inseam:         return 60...102
        case .sleeveLength:   return 50...102
        case .shoulders:      return 36...61
        }
    }

    func isValid(_ value: Double, unit: MeasurementUnit) -> Bool {
        let range = unit == .inches ? inchRange : cmRange
        return range.contains(value)
    }
}

// MARK: - Measurements

struct Measurements: Codable {
    var bustIn: Double?;   var bustCm: Double?
    var waistIn: Double?;  var waistCm: Double?
    var hipsIn: Double?;   var hipsCm: Double?
    var inseamIn: Double?; var inseamCm: Double?
    var sleeveIn: Double?; var sleeveCm: Double?
    var chestIn: Double?;  var chestCm: Double?
    var shouldersIn: Double?; var shouldersCm: Double?

    func value(for field: MeasurementField, unit: MeasurementUnit) -> Double? {
        switch (field, unit) {
        case (.bust, .inches): return bustIn
        case (.bust, .cm):     return bustCm
        case (.waist, .inches): return waistIn
        case (.waist, .cm):    return waistCm
        case (.hips, .inches): return hipsIn
        case (.hips, .cm):     return hipsCm
        case (.inseam, .inches): return inseamIn
        case (.inseam, .cm):   return inseamCm
        case (.sleeveLength, .inches): return sleeveIn
        case (.sleeveLength, .cm):     return sleeveCm
        case (.chest, .inches): return chestIn
        case (.chest, .cm):    return chestCm
        case (.shoulders, .inches): return shouldersIn
        case (.shoulders, .cm):     return shouldersCm
        }
    }

    mutating func set(_ value: Double?, for field: MeasurementField, unit: MeasurementUnit) {
        switch (field, unit) {
        case (.bust, .inches): bustIn = value
        case (.bust, .cm):     bustCm = value
        case (.waist, .inches): waistIn = value
        case (.waist, .cm):    waistCm = value
        case (.hips, .inches): hipsIn = value
        case (.hips, .cm):     hipsCm = value
        case (.inseam, .inches): inseamIn = value
        case (.inseam, .cm):   inseamCm = value
        case (.sleeveLength, .inches): sleeveIn = value
        case (.sleeveLength, .cm):     sleeveCm = value
        case (.chest, .inches): chestIn = value
        case (.chest, .cm):    chestCm = value
        case (.shoulders, .inches): shouldersIn = value
        case (.shoulders, .cm):     shouldersCm = value
        }
    }
}

// MARK: - UserProfile (matches Supabase users table)

struct UserProfile: Codable {
    var id: UUID?
    var gender: Gender?
    var topSize: ClothingSize?
    var bottomSize: ClothingSize?
    var bustIn: Double?;   var bustCm: Double?
    var waistIn: Double?;  var waistCm: Double?
    var hipsIn: Double?;   var hipsCm: Double?
    var inseamIn: Double?; var inseamCm: Double?
    var sleeveLengthIn: Double?; var sleeveLengthCm: Double?
    var chestIn: Double?;  var chestCm: Double?
    var shouldersIn: Double?; var shouldersCm: Double?
    var onboardingComplete: Bool
    var onboardingStep: Int

    init(
        id: UUID? = nil,
        gender: Gender? = nil,
        topSize: ClothingSize? = nil,
        bottomSize: ClothingSize? = nil,
        measurements: Measurements = .init(),
        onboardingComplete: Bool = false,
        onboardingStep: Int = 0
    ) {
        self.id = id
        self.gender = gender
        self.topSize = topSize
        self.bottomSize = bottomSize
        self.bustIn = measurements.bustIn;     self.bustCm = measurements.bustCm
        self.waistIn = measurements.waistIn;   self.waistCm = measurements.waistCm
        self.hipsIn = measurements.hipsIn;     self.hipsCm = measurements.hipsCm
        self.inseamIn = measurements.inseamIn; self.inseamCm = measurements.inseamCm
        self.sleeveLengthIn = measurements.sleeveIn; self.sleeveLengthCm = measurements.sleeveCm
        self.chestIn = measurements.chestIn;   self.chestCm = measurements.chestCm
        self.shouldersIn = measurements.shouldersIn; self.shouldersCm = measurements.shouldersCm
        self.onboardingComplete = onboardingComplete
        self.onboardingStep = onboardingStep
    }

    enum CodingKeys: String, CodingKey {
        case id, gender
        case topSize            = "top_size"
        case bottomSize         = "bottom_size"
        case bustIn             = "bust_in"
        case bustCm             = "bust_cm"
        case waistIn            = "waist_in"
        case waistCm            = "waist_cm"
        case hipsIn             = "hips_in"
        case hipsCm             = "hips_cm"
        case inseamIn           = "inseam_in"
        case inseamCm           = "inseam_cm"
        case sleeveLengthIn     = "sleeve_length_in"
        case sleeveLengthCm     = "sleeve_length_cm"
        case chestIn            = "chest_in"
        case chestCm            = "chest_cm"
        case shouldersIn        = "shoulders_in"
        case shouldersCm        = "shoulders_cm"
        case onboardingComplete = "onboarding_complete"
        case onboardingStep     = "onboarding_step"
    }
}
