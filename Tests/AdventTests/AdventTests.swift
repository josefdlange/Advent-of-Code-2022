import XCTest
@testable import Advent

final class AdventTests: XCTestCase {
    func testElfCalories() throws {
        let elfCalories = ElfCalories(fromDataFile: "2022-12-01.test")        
        XCTAssertEqual(elfCalories.getElfWithMostCalories()?.calorieCount(), 24000)
        XCTAssertEqual(elfCalories.getTopElves(howManyElves: 3).map({ elf in elf.calorieCount() }).reduce(0, +), 45000)
    }
    
    func testElfRockPaperScissors() throws {
        let elfRock = ElfRockPaperScissors(fromDataFile: "2022-12-02.test")
        XCTAssertEqual(elfRock.getNaiveGameTotal(), 15)
        XCTAssertEqual(elfRock.getStrategicGameTotal(), 12)
    }
    
    func testElfRucksacks() throws {
        let elfRucksacks = ElfRucksacks(fromDataFile: "2022-12-03.test")
        XCTAssertEqual(elfRucksacks.getTotalOverlapPriority(), 157)
        XCTAssertEqual(elfRucksacks.getTotalGroupBadgePriority(), 70)
    }
    
    func testCampCleanup() throws {
        let campCleanup = CampCleanup(fromDataFile: "2022-12-04.test")
        XCTAssertEqual(campCleanup.self.getContainedAssignmentPairs().count, 2)
    }
}
