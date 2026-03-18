//
//  MacroAverageTests.swift
//  HomeTests
//
//  Created by SimpleCare on 3/18/26.
//

import XCTest
@testable import HomeDomain

final class MacroAverageTests: XCTestCase {

    func test_총합계산() {
        let macro = MacroAverage(protein: 100, carbs: 250, fat: 70)
        XCTAssertEqual(macro.total, 100 + 250 + 70)
    }

    func test_비율계산() {
        let macro = MacroAverage(protein: 100, carbs: 200, fat: 100)
        let total = 100.0 + 200.0 + 100.0
        XCTAssertEqual(macro.proteinRatio, 100.0 / total, accuracy: 0.01)
        XCTAssertEqual(macro.carbsRatio, 200.0 / total, accuracy: 0.01)
        XCTAssertEqual(macro.fatRatio, 100.0 / total, accuracy: 0.01)
    }

    func test_비율_총합0() {
        let macro = MacroAverage(protein: 0, carbs: 0, fat: 0)
        XCTAssertEqual(macro.proteinRatio, 0)
        XCTAssertEqual(macro.carbsRatio, 0)
        XCTAssertEqual(macro.fatRatio, 0)
    }

    func test_비율합_1() {
        let macro = MacroAverage(protein: 80, carbs: 300, fat: 65)
        let sum = macro.proteinRatio + macro.carbsRatio + macro.fatRatio
        XCTAssertEqual(sum, 1.0, accuracy: 0.001)
    }
}
