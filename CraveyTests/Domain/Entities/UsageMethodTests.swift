@testable import Cravey
import Foundation
import Testing

/// Unit tests for UsageMethod enum
/// Tests the single source of truth for ROA validation (DEBT-041)
@Suite("UsageMethod Tests")
struct UsageMethodTests {
    // MARK: - Amount Range Tests

    @Test("Bowls amount range is 0.5 to 5.0 by 0.5")
    func bowlsAmountRange() {
        let expected = stride(from: 0.5, through: 5.0, by: 0.5).map { $0 }
        #expect(UsageMethod.bowls.amountRange == expected)
        #expect(UsageMethod.bowls.amountRange.count == 10)
        #expect(UsageMethod.bowls.amountRange.first == 0.5)
        #expect(UsageMethod.bowls.amountRange.last == 5.0)
    }

    @Test("Joints amount range matches Bowls")
    func jointsAmountRange() {
        #expect(UsageMethod.joints.amountRange == UsageMethod.bowls.amountRange)
    }

    @Test("Blunts amount range matches Bowls")
    func bluntsAmountRange() {
        #expect(UsageMethod.blunts.amountRange == UsageMethod.bowls.amountRange)
    }

    @Test("Vape amount range is 1 to 10 pulls")
    func vapeAmountRange() {
        let expected = Array(1 ... 10).map { Double($0) }
        #expect(UsageMethod.vape.amountRange == expected)
        #expect(UsageMethod.vape.amountRange.count == 10)
        #expect(UsageMethod.vape.amountRange.first == 1.0)
        #expect(UsageMethod.vape.amountRange.last == 10.0)
    }

    @Test("Dab amount range is 1 to 5 dabs")
    func dabAmountRange() {
        let expected = Array(1 ... 5).map { Double($0) }
        #expect(UsageMethod.dab.amountRange == expected)
        #expect(UsageMethod.dab.amountRange.count == 5)
    }

    @Test("Edible amount range is 5 to 100mg by 5")
    func edibleAmountRange() {
        let expected = stride(from: 5.0, through: 100.0, by: 5.0).map { $0 }
        #expect(UsageMethod.edible.amountRange == expected)
        #expect(UsageMethod.edible.amountRange.count == 20)
        #expect(UsageMethod.edible.amountRange.first == 5.0)
        #expect(UsageMethod.edible.amountRange.last == 100.0)
    }

    // MARK: - Amount Validation Tests

    @Test("isValidAmount accepts values in range")
    func isValidAmountAcceptsValidValues() {
        #expect(UsageMethod.bowls.isValidAmount(0.5) == true)
        #expect(UsageMethod.bowls.isValidAmount(2.5) == true)
        #expect(UsageMethod.bowls.isValidAmount(5.0) == true)
        #expect(UsageMethod.vape.isValidAmount(1.0) == true)
        #expect(UsageMethod.vape.isValidAmount(10.0) == true)
        #expect(UsageMethod.edible.isValidAmount(25.0) == true)
    }

    @Test("isValidAmount rejects values outside range")
    func isValidAmountRejectsInvalidValues() {
        #expect(UsageMethod.bowls.isValidAmount(0.0) == false)
        #expect(UsageMethod.bowls.isValidAmount(0.25) == false) // Not a valid step
        #expect(UsageMethod.bowls.isValidAmount(5.5) == false) // Too high
        #expect(UsageMethod.vape.isValidAmount(0.0) == false)
        #expect(UsageMethod.vape.isValidAmount(11.0) == false)
        #expect(UsageMethod.edible.isValidAmount(3.0) == false) // Not a valid step
        #expect(UsageMethod.edible.isValidAmount(105.0) == false)
    }

    // MARK: - Format Amount Tests

    @Test("formatAmount for Bowls shows decimal when needed")
    func formatAmountBowls() {
        #expect(UsageMethod.bowls.formatAmount(1.0) == "1 bowls")
        #expect(UsageMethod.bowls.formatAmount(2.5) == "2.5 bowls")
    }

    @Test("formatAmount for Joints shows decimal when needed")
    func formatAmountJoints() {
        #expect(UsageMethod.joints.formatAmount(1.0) == "1 joints")
        #expect(UsageMethod.joints.formatAmount(0.5) == "0.5 joints")
    }

    @Test("formatAmount for Blunts shows decimal when needed")
    func formatAmountBlunts() {
        #expect(UsageMethod.blunts.formatAmount(2.0) == "2 blunts")
    }

    @Test("formatAmount for Vape shows integer pulls")
    func formatAmountVape() {
        #expect(UsageMethod.vape.formatAmount(5.0) == "5 pulls")
        #expect(UsageMethod.vape.formatAmount(10.0) == "10 pulls")
    }

    @Test("formatAmount for Dab shows integer dabs")
    func formatAmountDab() {
        #expect(UsageMethod.dab.formatAmount(3.0) == "3 dabs")
    }

    @Test("formatAmount for Edible shows mg suffix")
    func formatAmountEdible() {
        #expect(UsageMethod.edible.formatAmount(25.0) == "25mg")
        #expect(UsageMethod.edible.formatAmount(100.0) == "100mg")
    }

    // MARK: - Raw Value Tests

    @Test("allCases contains exactly 6 methods")
    func allCasesCount() {
        #expect(UsageMethod.allCases.count == 6)
    }

    @Test("rawValues match expected strings")
    func rawValuesMatch() {
        #expect(UsageMethod.bowls.rawValue == "Bowls")
        #expect(UsageMethod.joints.rawValue == "Joints")
        #expect(UsageMethod.blunts.rawValue == "Blunts")
        #expect(UsageMethod.vape.rawValue == "Vape")
        #expect(UsageMethod.dab.rawValue == "Dab")
        #expect(UsageMethod.edible.rawValue == "Edible")
    }

    @Test("can initialize from rawValue")
    func initFromRawValue() {
        #expect(UsageMethod(rawValue: "Bowls") == .bowls)
        #expect(UsageMethod(rawValue: "Vape") == .vape)
        #expect(UsageMethod(rawValue: "Invalid") == nil)
        #expect(UsageMethod(rawValue: "bowls") == nil) // Case sensitive
    }
}
