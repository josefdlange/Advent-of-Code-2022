//
//  HillClimb.swift
//  
//
//  Created by Josef Lange on 12/12/22.
//

import Foundation

enum HillMove: CaseIterable {
    case up
    case down
    case left
    case right
    
    func getOutcome(fromInputXPosition x: Int, yPosition y: Int) -> (Int, Int) {
        switch self {
        case .up:
            return (x, y - 1)
        case .down:
            return (x, y + 1)
        case .left:
            return (x - 1, y)
        case.right:
            return (x + 1, y)
        }
    }
}

class HillClimb: CodeChallenge {
    var map: [[Int]] = []
    var startPosition: (Int, Int) = (0, 0)
    var endPosition: (Int, Int) = (0, 0)
    
    override init(fromDataFile fileName: String = "2022-12-12") {
        super.init(fromDataFile: fileName)
    }
    
    override func runChallenge() {
        self.loadGeography()
        
        print("===================================")
        print("2022-12-12: Hill Climb             ")
        print("===================================")
        print("")
        
        print("Shortest path from S to E: \(self.findShortestPath(fromPointAtXPosition: self.startPosition.0, yPosition: self.startPosition.1))")
        
        print("Shortest path from <a> to E: \(self.findShortestPath(fromPointAtXPosition: self.endPosition.0, yPosition: self.endPosition.1, toPointWithScore: 0))")
    }
    

    func loadGeography() {
        guard let data = self.loadLineDataFromFile(withName: self.dataFileName) else {
            print("Error loading \(self.dataFileName)")
            return
        }
        
        // Continue load here
        let rawCharMap: [[Character]] = data.components(separatedBy: .newlines).filter({ $0.count > 0 }).map({ Array($0) })
        
        self.map = rawCharMap.enumerated().map({ (yPosition, mapRow) in
            return mapRow.enumerated().map({ (xPosition, char) in
                if char == "S" {
                    self.startPosition = (xPosition, yPosition)
                    return 0
                } else if char == "E" {
                    self.endPosition = (xPosition, yPosition)
                    return 25
                } else {
                    return Int(char.asciiValue!) - 97
                }
            })
        })
    }
    
    func getPossibleMoves(forXPosition x: Int, yPosition y: Int, withVisited visited: [(Int, Int)], reversed: Bool = false) -> [(HillMove, (Int, Int))] {
        let filteredMoves: [(HillMove, (Int, Int))] = HillMove.allCases.compactMap({ move in
            let destination = move.getOutcome(fromInputXPosition: x, yPosition: y)
            
            if visited.firstIndex(where: { (visitedX, visitedY) in
                return visitedX == destination.0 && visitedY == destination.1
            }) != nil {
                return nil
            }
            
            guard self.map.indices.contains(destination.1) else {
                return nil
            }
            
            guard self.map[destination.1].indices.contains(destination.0) else {
                return nil
            }
            
            if reversed {
                if self.map[y][x] - self.map[destination.1][destination.0] > 1 {
                    return nil
                }
            } else {
                if self.map[destination.1][destination.0] - self.map[y][x] > 1 {
                    return nil
                }
            }
            
            return (move, destination)
        })
        
        return filteredMoves
    }
    
    func findShortestPath(fromPointAtXPosition x: Int, yPosition y: Int) -> Int {
        var moveQueue: [(HillMove, Int, (Int, Int))] = []
        var visited: [(Int, Int)] = []
        
        moveQueue.append(contentsOf: self.getPossibleMoves(forXPosition: x, yPosition: y, withVisited: visited).map({ (move, position) in
            return (move, 1, position)
        }))
        
        while moveQueue.count > 0 {
            let moveData = moveQueue.removeFirst()
            
            let moveDepth = moveData.1
            let movePosition = moveData.2
                        
            if (movePosition == self.endPosition) {
                return moveDepth
            }
            
            if visited.firstIndex(where: { (visitedX, visitedY) in
                return visitedX == moveData.2.0 && visitedY == moveData.2.1
            }) != nil {
                continue
            }
            
            visited.append(movePosition)
            
            moveQueue.append(contentsOf: self.getPossibleMoves(forXPosition: movePosition.0, yPosition: movePosition.1, withVisited: visited).map({ (innerMove, position) in
                return (innerMove, moveDepth + 1, position)
            }))
        }
        
        return -1
    }
    
    func findShortestPath(fromPointAtXPosition x: Int, yPosition y: Int, toPointWithScore desiredScore: Int) -> Int {
        var moveQueue: [(HillMove, Int, (Int, Int))] = []
        var visited: [(Int, Int)] = []
        
        moveQueue.append(contentsOf: self.getPossibleMoves(forXPosition: x, yPosition: y, withVisited: visited, reversed: true).map({ (move, position) in
            return (move, 1, position)
        }))
        
        while moveQueue.count > 0 {
            let moveData = moveQueue.removeFirst()
            
            let moveDepth = moveData.1
            let movePosition = moveData.2
                        
            if (self.map[movePosition.1][movePosition.0] == desiredScore) {
                return moveDepth
            }
            
            if visited.firstIndex(where: { (visitedX, visitedY) in
                return visitedX == moveData.2.0 && visitedY == moveData.2.1
            }) != nil {
                continue
            }
            
            visited.append(movePosition)
            
            moveQueue.append(contentsOf: self.getPossibleMoves(forXPosition: movePosition.0, yPosition: movePosition.1, withVisited: visited, reversed: true).map({ (innerMove, position) in
                return (innerMove, moveDepth + 1, position)
            }))
        }
        
        return -1
    }
}
