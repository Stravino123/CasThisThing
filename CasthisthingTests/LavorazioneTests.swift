import XCTest
import SwiftData
@testable import Casthisthing

@MainActor
final class LavorazioneTests: XCTestCase {

    private var container: ModelContainer!

    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: CastingSession.self, Lavorazione.self, configurations: config)
    }

    override func tearDownWithError() throws {
        container = nil
    }

    private func makeSession(silverCost: Double?, castingCost: Double?) -> CastingSession {
        let s = CastingSession(title: "T", date: .now)
        s.silverCost = silverCost
        s.castingCost = castingCost
        container.mainContext.insert(s)
        return s
    }

    func testCost_nilWhenSessionIncomplete() {
        let s = makeSession(silverCost: 100, castingCost: nil)
        let l = Lavorazione(label: "A", session: s)
        l.silverWeight = 14.2
        container.mainContext.insert(l)
        XCTAssertNil(l.cost)
    }

    func testCost_nilWhenSilverCostMissing() {
        let s = makeSession(silverCost: nil, castingCost: 80)
        let l = Lavorazione(label: "A", session: s)
        l.silverWeight = 14.2
        container.mainContext.insert(l)
        XCTAssertNil(l.cost)
    }

    func testCost_nilWhenNoSilverWeight() {
        let s = makeSession(silverCost: 100, castingCost: 80)
        let l = Lavorazione(label: "A", session: s)
        container.mainContext.insert(l)
        XCTAssertNil(l.cost)
    }

    func testCost_proportionalFormula() {
        let s = makeSession(silverCost: 132, castingCost: 115)
        let l1 = Lavorazione(label: "A", session: s); l1.silverWeight = 14.2
        let l2 = Lavorazione(label: "B", session: s); l2.silverWeight = 19.8
        let l3 = Lavorazione(label: "C", session: s); l3.silverWeight = 10.0
        container.mainContext.insert(l1)
        container.mainContext.insert(l2)
        container.mainContext.insert(l3)
        XCTAssertEqual(l1.cost!, (14.2 / 44.0) * 247.0, accuracy: 0.001)
        XCTAssertEqual(l2.cost!, (19.8 / 44.0) * 247.0, accuracy: 0.001)
        XCTAssertEqual(l3.cost!, (10.0 / 44.0) * 247.0, accuracy: 0.001)
    }

    func testCost_nilWhenTotalSilverWeightIsZero() {
        let s = makeSession(silverCost: 100, castingCost: 80)
        let l = Lavorazione(label: "A", session: s)
        l.silverWeight = 0.0
        container.mainContext.insert(l)
        XCTAssertNil(l.cost)
    }

    func testCost_waxWeightIsIgnored() {
        let s = makeSession(silverCost: 100, castingCost: 80)
        let l1 = Lavorazione(label: "A", session: s)
        l1.waxWeight = 999
        l1.silverWeight = 20
        let l2 = Lavorazione(label: "B", session: s)
        l2.waxWeight = 999
        l2.silverWeight = 20
        container.mainContext.insert(l1)
        container.mainContext.insert(l2)
        XCTAssertEqual(l1.cost!, 90.0, accuracy: 0.001)
    }
}
