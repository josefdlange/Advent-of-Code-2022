import XCTest
@testable import Advent

final class AdventTests: XCTestCase {
    func testElfCalories() throws {
        let elfCalories = ElfCalories(fromDataFile: "2022-12-01.test")
        elfCalories.loadElves()
        XCTAssertEqual(elfCalories.getElfWithMostCalories()?.calorieCount(), 24000)
        XCTAssertEqual(elfCalories.getTopElves(howManyElves: 3).map({ elf in elf.calorieCount() }).reduce(0, +), 45000)
    }
    
    func testElfRockPaperScissors() throws {
        let elfRock = ElfRockPaperScissors(fromDataFile: "2022-12-02.test")
        elfRock.loadGuide()
        XCTAssertEqual(elfRock.getNaiveGameTotal(), 15)
        XCTAssertEqual(elfRock.getStrategicGameTotal(), 12)
    }
    
    func testElfRucksacks() throws {
        let elfRucksacks = ElfRucksacks(fromDataFile: "2022-12-03.test")
        elfRucksacks.loadRucksackData()
        XCTAssertEqual(elfRucksacks.getTotalOverlapPriority(), 157)
        XCTAssertEqual(elfRucksacks.getTotalGroupBadgePriority(), 70)
    }
    
    func testCampCleanup() throws {
        let campCleanup = CampCleanup(fromDataFile: "2022-12-04.test")
        campCleanup.loadAssignments()
        XCTAssertEqual(campCleanup.self.getContainedAssignmentPairs().count, 2)
    }
    
    func testSupplyStacks() throws {
        let supplyStacks = SupplyStacks(fromDataFile: "2022-12-05.test")
        supplyStacks.loadCargoManifestAndMoves()
        
        XCTAssertEqual(supplyStacks.operations.count, 4)
        
        supplyStacks.runAllOperations()
        
        XCTAssertEqual(supplyStacks.getStackTops(), "CMZ")
        
        supplyStacks.loadCargoManifestAndMoves()
        supplyStacks.runAllOperations9001()
        
        XCTAssertEqual(supplyStacks.getStackTops(), "MCD")
    }
    
    func testTuningTrouble() throws {
        let tuningTrouble = TuningTrouble()
        tuningTrouble.signal = "mjqjpqmgbljsphdztnvjfqwrcgsmlb"
        XCTAssertEqual(tuningTrouble.firstMarkerPosition(), 7)
        tuningTrouble.signal = "bvwbjplbgvbhsrlpgdmjqwftvncz"
        XCTAssertEqual(tuningTrouble.firstMarkerPosition(), 5)
        tuningTrouble.signal = "nppdvjthqldpwncqszvftbrmjlhg"
        XCTAssertEqual(tuningTrouble.firstMarkerPosition(), 6)
        tuningTrouble.signal = "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg"
        XCTAssertEqual(tuningTrouble.firstMarkerPosition(), 10)
        tuningTrouble.signal = "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw"
        XCTAssertEqual(tuningTrouble.firstMarkerPosition(), 11)
    }
    
    func testSpaceSaver() throws {
        let spaceSaver = SpaceSaver(fromDataFile: "2022-12-07.test")
        spaceSaver.loadCommands()
        spaceSaver.processFilesystem()
        XCTAssertEqual(spaceSaver.getCombinedSizesOfDirectories(belowThreshold: 100000), 95437)
        XCTAssertEqual(spaceSaver.determineSpaceDeficit(forTotalSpace: 70000000, requiredSpace: 30000000), 8381165)
        XCTAssertEqual(spaceSaver.findSmallestDirectory(aboveThreshold: 8381165)!.getTotalSize(), 24933642)
    }
    
    func testTreeHouse() throws {
        let treeHouse = TreeHouse(fromDataFile: "2022-12-08.test")
        treeHouse.loadForest()
        
        XCTAssertEqual(treeHouse.getVisibleTrees().count, 21)
        XCTAssertEqual(treeHouse.getOptimalScoreTreeScore(), 8)
    }
    
    func testRopeBridge() throws {
        let ropeBridge = RopeBridge(fromDataFile: "2022-12-09.test")
        ropeBridge.loadMoves()
        
        var ropeStates: [[Position]] = [[Position(x: 0, y: 0), Position(x: 0, y: 0)]]
        
        for move in ropeBridge.moves {
            for _ in 0..<move.distance {
                ropeStates.append(ropeBridge.processMove(inDirection: move.direction, forKnots: ropeStates.last!))
            }
        }
        
        let uniqueTailPositions = Set(ropeStates.map({$0.last!}))
        XCTAssertEqual(uniqueTailPositions.count, 13)
    }
    
    func testRopeBridgeLong() throws {
        let ropeBridge = RopeBridge(fromDataFile: "2022-12-09.long.test")
        ropeBridge.loadMoves()
        
        var ropeStates: [[Position]] = [Array(repeating: Position(x: 0, y: 0), count: 10)]
        
        for move in ropeBridge.moves {
//            print(move)
            for m in 0..<move.distance {
                ropeStates.append(ropeBridge.processMove(inDirection: move.direction, forKnots: ropeStates.last!))
            }

        }
        
        let uniqueTailPositions = Set(ropeStates.map({$0.last!}))
//        print(uniqueTailPositions)
        XCTAssertEqual(uniqueTailPositions.count, 36)
    }
}
