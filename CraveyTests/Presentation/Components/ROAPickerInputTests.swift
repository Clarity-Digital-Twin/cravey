@testable import Cravey
import Foundation
import Testing

@Suite("ROAPickerInput Tests (Phase 2B)")
struct ROAPickerInputTests {
    // MARK: - Test 1: Bowls Range

    @Test("Bowls should have 10 options (0.5 → 5.0, increment 0.5)")
    func bowlsRange() {
        let range = ROAAmountRange.range(for: "Bowls")

        // Verify count
        #expect(range.count == 10)

        // Verify min/max
        #expect(range.first == 0.5)
        #expect(range.last == 5.0)

        // Verify increments
        #expect(range.contains(1.0))
        #expect(range.contains(2.5))
        #expect(range.contains(4.5))
    }

    // MARK: - Test 2: Vape Range

    @Test("Vape should have 10 options (1 → 10, increment 1)")
    func vapeRange() {
        let range = ROAAmountRange.range(for: "Vape")

        // Verify count
        #expect(range.count == 10)

        // Verify min/max
        #expect(range.first == 1.0)
        #expect(range.last == 10.0)

        // Verify increments (all integers)
        #expect(range.contains(5.0))
        #expect(range.contains(10.0))
    }

    // MARK: - Test 3: Dab Range

    @Test("Dab should have 5 options (1 → 5, increment 1)")
    func dabRange() {
        let range = ROAAmountRange.range(for: "Dab")

        // Verify count (smallest range)
        #expect(range.count == 5)

        // Verify min/max
        #expect(range.first == 1.0)
        #expect(range.last == 5.0)
    }

    // MARK: - Test 4: Edible Range

    @Test("Edible should have 20 options (5mg → 100mg, increment 5mg)")
    func edibleRange() {
        let range = ROAAmountRange.range(for: "Edible")

        // Verify count (largest range)
        #expect(range.count == 20)

        // Verify min/max
        #expect(range.first == 5.0)
        #expect(range.last == 100.0)

        // Verify increments
        #expect(range.contains(25.0))
        #expect(range.contains(50.0))
        #expect(range.contains(75.0))
    }

    // MARK: - Test 5: Display Formatting

    @Test("Display formatting should match spec for all ROAs")
    func displayFormatting() {
        // Bowls: integer without decimal
        #expect(ROAAmountRange.displayAmount(method: "Bowls", amount: 1.0) == "1 bowls")

        // Bowls: decimal shown
        #expect(ROAAmountRange.displayAmount(method: "Bowls", amount: 2.5) == "2.5 bowls")

        // Vape: integer pulls
        #expect(ROAAmountRange.displayAmount(method: "Vape", amount: 5.0) == "5 pulls")

        // Dab: integer dabs
        #expect(ROAAmountRange.displayAmount(method: "Dab", amount: 3.0) == "3 dabs")

        // Edible: mg format (NO space)
        #expect(ROAAmountRange.displayAmount(method: "Edible", amount: 25.0) == "25mg")
    }
}
