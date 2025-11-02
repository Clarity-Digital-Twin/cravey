@testable import Cravey
import SwiftUI
import Testing

/// Tests for IntensitySlider component
/// Presentation layer tests - Clean Architecture
@Suite("IntensitySlider Tests")
struct IntensitySliderTests {
    @Test("Should format intensity label correctly")
    func intensityLabel() {
        #expect(IntensitySlider.formatLabel(for: 1) == "1 - Very Mild")
        #expect(IntensitySlider.formatLabel(for: 2) == "2 - Very Mild")
        #expect(IntensitySlider.formatLabel(for: 3) == "3 - Mild")
        #expect(IntensitySlider.formatLabel(for: 4) == "4 - Mild")
        #expect(IntensitySlider.formatLabel(for: 5) == "5 - Moderate")
        #expect(IntensitySlider.formatLabel(for: 6) == "6 - Moderate")
        #expect(IntensitySlider.formatLabel(for: 7) == "7 - Strong")
        #expect(IntensitySlider.formatLabel(for: 8) == "8 - Strong")
        #expect(IntensitySlider.formatLabel(for: 9) == "9 - Overwhelming")
        #expect(IntensitySlider.formatLabel(for: 10) == "10 - Overwhelming")
    }

    @Test("Should return correct emoji for intensity")
    func intensityEmoji() {
        #expect(IntensitySlider.emoji(for: 1) == "😌")
        #expect(IntensitySlider.emoji(for: 2) == "😌")
        #expect(IntensitySlider.emoji(for: 3) == "🙂")
        #expect(IntensitySlider.emoji(for: 4) == "🙂")
        #expect(IntensitySlider.emoji(for: 5) == "😐")
        #expect(IntensitySlider.emoji(for: 6) == "😐")
        #expect(IntensitySlider.emoji(for: 7) == "😟")
        #expect(IntensitySlider.emoji(for: 8) == "😟")
        #expect(IntensitySlider.emoji(for: 9) == "😫")
        #expect(IntensitySlider.emoji(for: 10) == "😫")
    }
}
