import XCTest
import SwiftData
@testable import Gioielli

@MainActor
final class CastingSessionTests: XCTestCase {

    private var container: ModelContainer!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: CastingSession.self, Lavorazione.self, configurations: config)
    }

    override func tearDownWithError() throws {
        container = nil
    }

    func testCurrentStep_allNil_is1() throws {
        let s = CastingSession(title: "Test", date: .now)
        XCTAssertEqual(s.currentStep, 1)
    }

    func testCurrentStep_waxOnly_is1() {
        let s = CastingSession(title: "T", date: .now)
        s.waxWeight = 10
        XCTAssertEqual(s.currentStep, 1)
    }

    func testCurrentStep_throughStep4() {
        let s = CastingSession(title: "T", date: .now)
        s.waxWeight = 10
        s.silverNeeded = 120
        XCTAssertEqual(s.currentStep, 2)
        s.silverCost = 100
        XCTAssertEqual(s.currentStep, 3)
        s.castingCost = 80
        XCTAssertEqual(s.currentStep, 4)
    }

    func testIsComplete_falseWhenMissingCosts() {
        let s = CastingSession(title: "T", date: .now)
        s.waxWeight = 10
        s.silverNeeded = 120
        s.silverCost = 100
        XCTAssertFalse(s.isComplete)
    }

    func testIsComplete_trueWhenBothCostsFilled() {
        let s = CastingSession(title: "T", date: .now)
        s.silverCost = 100
        s.castingCost = 80
        XCTAssertTrue(s.isComplete)
    }

    func testTotalCost_nilWhenIncomplete() {
        let s = CastingSession(title: "T", date: .now)
        s.silverCost = 100
        XCTAssertNil(s.totalCost)
    }

    func testTotalCost_sumWhenComplete() {
        let s = CastingSession(title: "T", date: .now)
        s.silverCost = 100
        s.castingCost = 80
        XCTAssertEqual(s.totalCost, 180)
    }

    func testTotalSilverWeight_sumOfNonNilWeights() throws {
        let s = CastingSession(title: "T", date: .now)
        container.mainContext.insert(s)
        let l1 = Lavorazione(label: "A", session: s); l1.silverWeight = 14.2
        let l2 = Lavorazione(label: "B", session: s); l2.silverWeight = 19.8
        let l3 = Lavorazione(label: "C", session: s) // no silver weight yet
        container.mainContext.insert(l1)
        container.mainContext.insert(l2)
        container.mainContext.insert(l3)
        XCTAssertEqual(s.totalSilverWeight, 34.0, accuracy: 0.001)
    }

    func testTotalSilverWeight_zeroWhenNoWeights() throws {
        let s = CastingSession(title: "T", date: .now)
        container.mainContext.insert(s)
        XCTAssertEqual(s.totalSilverWeight, 0)
    }
}
