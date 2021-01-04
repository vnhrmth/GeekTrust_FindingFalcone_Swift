//
//  TimeCalculatorTest.swift
//  FindingFalconeTests
//
//  Created by Vinay Hiremath on 03/01/21.
//

import XCTest
@testable import FindingFalcone

class TimeCalculatorTest: XCTestCase {
    let timeCalculator = TimeCalculator()
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testcalculateTimeWithEmptyDictionary_Should_Return_0(){
        let emptyDict = [Planet:Vehicle]()
        let timetaken = timeCalculator.calculateTime(dict: emptyDict)
        XCTAssertEqual(0, timetaken)
    }
    
    func testcalculateTimeWithDictionary_Should_Return_correctvalue(){
        var emptyDict = [Planet:Vehicle]()
        let planet = Planet(name: "X", distance: 120)
        emptyDict[planet] = Vehicle(name: "X", totalNo: 1, maxDistance: 100, speed: 40)
        
        let timetaken = timeCalculator.calculateTime(dict: emptyDict)
        XCTAssertEqual(3, timetaken)
    }
}
