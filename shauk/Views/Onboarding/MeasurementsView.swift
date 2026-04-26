import SwiftUI

struct MeasurementsView: View {
    @Bindable var vm: OnboardingViewModel
    @Environment(\.appTheme) private var theme

    private var c: ThemeColors { theme.colors }
    private var fields: [MeasurementField] {
        MeasurementField.fields(for: vm.gender ?? .female)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            Text("Your measurements")
                .font(DesignFonts.playfair(size: 22))
                .foregroundColor(c.t1)
                .padding(.bottom, Spacing.xs)

            Text("Optional — helps us find perfect fits.")
                .font(DesignFonts.dmSans(size: 13, weight: .light))
                .foregroundColor(c.t3)
                .padding(.bottom, Spacing.xl)

            // Unit toggle
            UnitToggle(selected: $vm.measurementUnit, colors: c)
                .padding(.bottom, Spacing.xl)

            // Measurement fields
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(fields, id: \.self) { field in
                        MeasurementRow(
                            field: field,
                            unit: vm.measurementUnit,
                            value: textBinding(for: field),
                            error: vm.validationErrors[field],
                            colors: c
                        )
                        .padding(.bottom, Spacing.md)
                    }
                }
            }

            Spacer(minLength: Spacing.lg)

            Button("Start discovering") {
                Task { await vm.completeWithMeasurements() }
            }
            .buttonStyle(PrimaryButtonStyle(colors: c, disabled: vm.isSaving || vm.hasValidationErrors))
            .disabled(vm.isSaving || vm.hasValidationErrors)

            AsyncGhostButton(label: "Skip measurements", colors: c, isLoading: vm.isSaving) {
                await vm.skipMeasurements()
            }
            .padding(.top, Spacing.xs)
        }
        .alert("Couldn't save profile", isPresented: .init(
            get: { vm.saveError != nil },
            set: { if !$0 { vm.dismissError() } }
        )) {
            Button("Retry") { Task { await vm.completeWithMeasurements() } }
            Button("Cancel", role: .cancel) { vm.dismissError() }
        } message: {
            Text(vm.saveError ?? "")
        }
    }

    // MARK: - Text Binding helper

    private func textBinding(for field: MeasurementField) -> Binding<String> {
        Binding(
            get: {
                if let v = vm.measurements.value(for: field, unit: vm.measurementUnit) {
                    return String(format: "%g", v)
                }
                return ""
            },
            set: { vm.updateMeasurement(field: field, text: $0) }
        )
    }
}

// MARK: - Unit Toggle

private struct UnitToggle: View {
    @Binding var selected: MeasurementUnit
    let colors: ThemeColors

    var body: some View {
        HStack(spacing: 2) {
            ForEach(MeasurementUnit.allCases, id: \.self) { unit in
                Button(unit.rawValue) { withAnimation(.shaukSnap) { selected = unit } }
                    .font(DesignFonts.dmSans(size: 13, weight: .medium))
                    .foregroundColor(selected == unit ? colors.t1 : colors.t3)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(selected == unit ? colors.bg : Color.clear)
                    .cornerRadius(Radius.pill)
                    .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(colors.border)
        .cornerRadius(Radius.pill)
    }
}

// MARK: - Measurement Row

private struct MeasurementRow: View {
    let field: MeasurementField
    let unit: MeasurementUnit
    @Binding var value: String
    let error: String?
    let colors: ThemeColors

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(field.label.uppercased())
                .font(DesignFonts.dmSans(size: 12))
                .foregroundColor(colors.t3)
                .kerning(0.8)

            HStack {
                TextField("—", text: $value)
                    .keyboardType(.decimalPad)
                    .font(DesignFonts.dmSans(size: 15))
                    .foregroundColor(colors.inputText)

                Text(unit == .inches ? "in" : "cm")
                    .font(DesignFonts.dmSans(size: 13))
                    .foregroundColor(colors.t3)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.vertical, Spacing.sm)
            .background(colors.obCardBg)
            .overlay(
                RoundedRectangle(cornerRadius: Radius.sm)
                    .stroke(error != nil ? Color(hex: "d45858") : colors.border, lineWidth: 1.5)
            )
            .cornerRadius(Radius.sm)

            if let error {
                Text(error)
                    .font(DesignFonts.dmSans(size: 12))
                    .foregroundColor(Color(hex: "d45858"))
            }
        }
    }
}
