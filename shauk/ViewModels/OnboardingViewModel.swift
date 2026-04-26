import SwiftUI

// MARK: - Onboarding Step

enum OnboardingStep: Int {
    case gender          = 0
    case sizes           = 1
    case measurementPrompt = 2
    case measurements    = 3
}

// MARK: - OnboardingViewModel

@Observable
@MainActor
final class OnboardingViewModel {

    // MARK: Current step
    var step: OnboardingStep

    // MARK: User selections
    var gender: Gender?
    var topSize: ClothingSize?
    var bottomSize: ClothingSize?
    var measurements: Measurements = .init()
    var measurementUnit: MeasurementUnit = .inches

    // MARK: UI state
    var isSaving = false
    var saveError: String?
    var validationErrors: [MeasurementField: String] = [:]

    // MARK: Persistence keys
    private let kStep          = "onboardingStep"
    private let kGender        = "onboardingGender"
    private let kTopSize       = "onboardingTopSize"
    private let kBottomSize    = "onboardingBottomSize"
    private let kUserId        = "supabaseUserId"
    private let kComplete      = "onboardingComplete"

    private let supabase = SupabaseService.shared

    // MARK: Init

    init() {
        let savedStepRaw = UserDefaults.standard.integer(forKey: "onboardingStep")
        self.step = OnboardingStep(rawValue: savedStepRaw) ?? .gender

        // Restore partial selections so the user doesn't re-enter data on resume
        if let g = UserDefaults.standard.string(forKey: "onboardingGender") {
            self.gender = Gender(rawValue: g)
        }
        if let t = UserDefaults.standard.string(forKey: "onboardingTopSize") {
            self.topSize = ClothingSize(rawValue: t)
        }
        if let b = UserDefaults.standard.string(forKey: "onboardingBottomSize") {
            self.bottomSize = ClothingSize(rawValue: b)
        }
    }

    // MARK: - Navigation

    var canAdvanceFromGender: Bool { gender != nil }
    var canAdvanceFromSizes:  Bool { topSize != nil && bottomSize != nil }

    func advanceFromGender() {
        guard canAdvanceFromGender else { return }
        UserDefaults.standard.set(gender?.rawValue, forKey: kGender)
        persistStep(.sizes)
        withAnimation(.shaukSlide) { step = .sizes }
    }

    func advanceFromSizes() {
        guard canAdvanceFromSizes else { return }
        UserDefaults.standard.set(topSize?.rawValue,    forKey: kTopSize)
        UserDefaults.standard.set(bottomSize?.rawValue, forKey: kBottomSize)
        persistStep(.measurementPrompt)
        withAnimation(.shaukSlide) { step = .measurementPrompt }
    }

    func advanceToMeasurements() {
        persistStep(.measurements)
        withAnimation(.shaukSlide) { step = .measurements }
    }

    // MARK: - Save & Complete

    /// Called when the user taps "Skip for now" on the measurement prompt screen
    func skipAndComplete() async {
        await saveAndComplete(includeMeasurements: false)
    }

    /// Called when the user taps "Start discovering" on the measurements screen
    func completeWithMeasurements() async {
        guard validateMeasurements() else { return }
        await saveAndComplete(includeMeasurements: true)
    }

    /// Called when the user skips the measurements screen entirely
    func skipMeasurements() async {
        await saveAndComplete(includeMeasurements: false)
    }

    private func saveAndComplete(includeMeasurements: Bool) async {
        isSaving = true
        saveError = nil
        defer { isSaving = false }

        do {
            let userId = try await supabase.currentUserID()
            UserDefaults.standard.set(userId.uuidString, forKey: kUserId)

            let profile = UserProfile(
                id: userId,
                gender: gender,
                topSize: topSize,
                bottomSize: bottomSize,
                measurements: includeMeasurements ? measurements : .init(),
                onboardingComplete: true,
                onboardingStep: OnboardingStep.measurements.rawValue
            )
            try await supabase.saveProfile(profile)

            UserDefaults.standard.set(true, forKey: kComplete)
            UserDefaults.standard.removeObject(forKey: kStep)
        } catch {
            saveError = error.localizedDescription
        }
    }

    // MARK: - Measurement Validation

    /// Returns true if all entered (non-empty) measurements are in valid range.
    private func validateMeasurements() -> Bool {
        validationErrors.removeAll()
        guard let gender else { return true }

        for field in MeasurementField.fields(for: gender) {
            if let val = measurements.value(for: field, unit: measurementUnit) {
                if !field.isValid(val, unit: measurementUnit) {
                    let range = measurementUnit == .inches ? field.inchRange : field.cmRange
                    let unit  = measurementUnit == .inches ? "in" : "cm"
                    validationErrors[field] = "Must be \(Int(range.lowerBound))–\(Int(range.upperBound)) \(unit)"
                }
            }
        }
        return validationErrors.isEmpty
    }

    func updateMeasurement(field: MeasurementField, text: String) {
        let value = Double(text)
        measurements.set(value, for: field, unit: measurementUnit)

        // Clear error when user edits the field
        validationErrors.removeValue(forKey: field)

        // Re-validate if a value is present
        if let v = value, !field.isValid(v, unit: measurementUnit) {
            let range = measurementUnit == .inches ? field.inchRange : field.cmRange
            let unit  = measurementUnit == .inches ? "in" : "cm"
            validationErrors[field] = "Must be \(Int(range.lowerBound))–\(Int(range.upperBound)) \(unit)"
        }
    }

    var hasValidationErrors: Bool { !validationErrors.isEmpty }

    // MARK: - Helpers

    private func persistStep(_ step: OnboardingStep) {
        UserDefaults.standard.set(step.rawValue, forKey: kStep)
    }

    func dismissError() { saveError = nil }
}
