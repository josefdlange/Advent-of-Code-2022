//
//  CampCleanup.swift
//  
//
//  Created by Josef Lange on 12/5/22.
//

import Foundation

class CleaningAssignment {
    var start: Int
    var end: Int
    
    init(start: Int, end: Int) {
        self.start = start
        self.end = end
    }
    
    init?(withAreaRange areaRangeString: String) {
        let areaRange = areaRangeString.components(separatedBy: "-").compactMap { val in
            return Int(val)
        }
        guard areaRange.count == 2 else {
            return nil
        }
        
        self.start = areaRange.first!
        self.end = areaRange.last!
    }
    
    func contains(otherAssignment: CleaningAssignment) -> Bool {
        return self.start <= otherAssignment.start && self.end >= otherAssignment.end
    }
    
    func overlaps(otherAssignment: CleaningAssignment) -> Bool {
        return (
            otherAssignment.contains(otherAssignment: CleaningAssignment(start: self.start, end: self.start))
            || otherAssignment.contains(otherAssignment: CleaningAssignment(start: self.end, end:self.end))
        )
    }
}

class CampCleanup: CodeChallenge {
    
    var assignmentPairs: [(CleaningAssignment, CleaningAssignment)] = []
    
    init(fromDataFile fileName: String = "2022-12-04") {
        super.init()
        self.loadAssignments(withFile: fileName)
    }
    
    func loadAssignments(withFile fileName : String) {
        guard let data = self.loadLineDataFromFile(withName: fileName) else {
            return
        }
        
        self.assignmentPairs = data.components(separatedBy: .newlines).filter({ string in
            !string.isEmpty
        }).compactMap { line in
            return line.components(separatedBy:",").map { rangeString in
                return CleaningAssignment(withAreaRange: rangeString)
            }
        }.filter({ assignmentArray in
            return assignmentArray.count == 2
        }).map({ assignmentArray in
            return (assignmentArray[0]!, assignmentArray[1]!)
        })
    }
    
    func getContainedAssignmentPairs() -> [(CleaningAssignment, CleaningAssignment)] {
        self.assignmentPairs.filter { (firstAssignment, secondAssignment) in
            return firstAssignment.contains(otherAssignment: secondAssignment) || secondAssignment.contains(otherAssignment: firstAssignment)
        }
    }
    
    func getOverlappingAssignmentPairs() -> [(CleaningAssignment, CleaningAssignment)] {
        self.assignmentPairs.filter { (firstAssignment, secondAssignment) in
            return firstAssignment.overlaps(otherAssignment: secondAssignment) || secondAssignment.overlaps(otherAssignment: firstAssignment)
        }
    }
    
    override func runChallenge() {
        print("===================================")
        print("2022-12-04: Camp Cleanup")
        print("===================================")
        print("")
        
        print("Contained assignment pairs: \(self.getContainedAssignmentPairs().count)")
        print("Overlapping assignment pairs: \(self.getOverlappingAssignmentPairs().count)")
        
        print("")
    }
}
