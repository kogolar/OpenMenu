//
//  OpenMenuSlider.swift
//  OpenMenu
//

import CompactSlider
import SwiftUI

extension CGFloat {
    /// The min height of an ``OpenMenuSlider``.
    static let openMenuSliderMinHeight: CGFloat = 24
}

struct OpenMenuSlider<Value: BinaryFloatingPoint, ValueLabel: View, ValueLabelSelectability: TextSelectability>: View {
    private let value: Binding<Value>
    private let bounds: ClosedRange<Value>
    private let step: Value
    private let valueLabel: ValueLabel
    private let valueLabelSelectability: ValueLabelSelectability

    @State private var isHovering = false

    init(
        value: Binding<Value>,
        in bounds: ClosedRange<Value> = 0...1,
        step: Value = 0,
        valueLabelSelectability: ValueLabelSelectability = .disabled,
        @ViewBuilder valueLabel: () -> ValueLabel
    ) {
        self.value = value
        self.bounds = bounds
        self.step = step
        self.valueLabel = valueLabel()
        self.valueLabelSelectability = valueLabelSelectability
    }

    init(
        _ valueLabelKey: LocalizedStringKey,
        valueLabelSelectability: ValueLabelSelectability = .disabled,
        value: Binding<Value>,
        in bounds: ClosedRange<Value> = 0...1,
        step: Value = 0
    ) where ValueLabel == Text {
        self.init(
            value: value,
            in: bounds,
            step: step,
            valueLabelSelectability: valueLabelSelectability
        ) {
            Text(valueLabelKey)
        }
    }

    var body: some View {
        CompactSlider(value: value, in: bounds, step: step)
            .compactSliderHandleStyle(.rectangle(visibility: .focused, width: 1))
            .overlay {
                valueLabel
                    .textSelection(valueLabelSelectability)
                    .foregroundStyle(Color(nsColor: .labelColor).opacity(isHovering ? 1 : 0.7))
                    .padding(.horizontal, 6)
                    .allowsHitTesting(false)
            }
            .frame(minHeight: .openMenuSliderMinHeight)
            .onHover { isHovering = $0 }
    }
}
