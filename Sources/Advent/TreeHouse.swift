//
//  TreeHouse.swift
//  
//
//  Created by Josef Lange on 12/8/22.
//

import Foundation

class Tree: CustomStringConvertible {
    var height: Int
    
    init(height: Int) {
        self.height = height
    }
    
    var description: String {
        return "{\(self.height)}"
    }
}

class TreeGrid: CustomStringConvertible {
    private var gridData: [[Tree]]
    var allTrees: [Tree] {
        get {
            self.gridData.flatMap { $0 }
        }
    }
    
    var description: String {
        return self.gridData.map { treeRow in
            return treeRow.map{ tree in
                return tree.description
            }.joined(separator:"  ")
        }.joined(separator: "\n\n")
    }
    
    init(gridData: [[Tree]]) {
        self.gridData = gridData
    }
    
    init(fromStringData stringData: String) {
        self.gridData = stringData.components(separatedBy: .newlines).filter({ rawGridRow in
            return rawGridRow.count > 0
        }).map { rowData in
            return rowData.map { treeHeightChar in
                return Tree(height: Int(String(treeHeightChar))!)
            }
        }
    }
    
    func getRow(atIndex index: Int) -> [Tree] {
        return self.gridData[index]
    }
    
    func getColumn(atIndex index: Int) -> [Tree] {
        return self.gridData.map { row in
            return row[index];
        }
    }
    
    func findTreeCoordinates(_ tree: Tree) -> (Int, Int)? {
        for (x, row) in self.gridData.enumerated() {
            for (y, candidateTree) in row.enumerated() {
                if candidateTree === tree {
                    return (x, y)
                }
            }
        }
        
        return nil
    }
    
    func treeIsVisible(_ tree: Tree) -> Bool {
        guard let coordinates = self.findTreeCoordinates(tree) else {
            print("Tree not in forest, therefore not visible. Consider that, grasshopper.")
            return false
        }
        
        let row = self.getRow(atIndex: coordinates.0)
        let column = self.getColumn(atIndex: coordinates.1)
        
        for sequence in [row, column] {
            if (
                sequence.split(
                    omittingEmptySubsequences: false,
                    whereSeparator: { candidateTree in candidateTree === tree }
                ).contains { lineOfSight in lineOfSight.allSatisfy { losTree in losTree.height < tree.height } }
            ) {
                return true
            }
        }
        
        return false
    }
    
    func treeViewingScore(_ tree: Tree) -> Int {
        guard let coordinates = self.findTreeCoordinates(tree) else {
            print("Tree not in forest, therefore not visible. Consider that, grasshopper.")
            return 0
        }
                
        let row = self.getRow(atIndex: coordinates.0)
        let column = self.getColumn(atIndex: coordinates.1)
        
        if coordinates.0 == 0 || coordinates.0 == row.count - 1 || coordinates.1 == 0 || coordinates.1 == column.count - 1 {
            return 0
        }
        
        var score = 1
        
        for sequence in [row, column] {
            let linesOfSightRaw = sequence.split(
                omittingEmptySubsequences: false,
                whereSeparator: { candidateTree in candidateTree === tree }
            )
            let linesOfSight: [[Tree]] = [Array(linesOfSightRaw.first!.reversed()), Array(linesOfSightRaw.last!)]
                        
            score = linesOfSight.reduce(score, { partialResult, lineOfSight in
                guard let visibleLineOfSight = lineOfSight.split(
                    omittingEmptySubsequences: false,
                    whereSeparator: { innerCandidate in innerCandidate.height >= tree.height }
                ).first else {
                    return 1
                }
                
                return (visibleLineOfSight.count + ((visibleLineOfSight.count == lineOfSight.count) ? 0 : 1)) * partialResult
            })
        }
                
        return score
    }
}

class TreeHouse: CodeChallenge {
    var forest: TreeGrid? = nil
    
    override init(fromDataFile fileName: String = "2022-12-08") {
        super.init(fromDataFile: fileName)
    }
    
    override func runChallenge() {
        self.loadForest()
        
        print("===================================")
        print("2022-12-08: Treetop Tree House     ")
        print("===================================")
        print("")
        
        print("Visible Trees (Step 1): \(self.getVisibleTrees().count)")
        print("Optimal Viewing Score (Step 2): \(self.getOptimalScoreTreeScore())")
    }
    
    func loadForest() {
        guard let data = self.loadLineDataFromFile(withName: self.dataFileName) else {
            print("Error loading \(self.dataFileName)")
            return
        }
        
        self.forest = TreeGrid(fromStringData: data)
    }
    
    func getVisibleTrees() -> [Tree] {
        return self.forest!.allTrees.filter { tree in self.forest!.treeIsVisible(tree) }
    }
    
    func getOptimalScoreTreeScore() -> Int {
        self.forest!.allTrees.map { tree in self.forest!.treeViewingScore(tree) }.max()!
    }
}
