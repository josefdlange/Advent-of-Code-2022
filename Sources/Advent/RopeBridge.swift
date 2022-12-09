//
//  RopeBridge.swift
//  
//
//  Created by Josef Lange on 12/9/22.
//

import Foundation

enum Direction: Character {
    case UP = "U"
    case DOWN = "D"
    case LEFT = "L"
    case RIGHT = "R"
    
    func opposite() -> Direction {
        switch self {
        case .UP: return .DOWN
        case .DOWN: return .UP
        case .LEFT: return .RIGHT
        case .RIGHT: return .LEFT
        }
    }
}

struct Position: Hashable, CustomStringConvertible {
    var x: Int
    var y: Int
    
    var description: String {
        return "(\(x), \(y))"
    }
    
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    init(byMovingInDirection direction: Direction, fromPosition position: Position) {
        switch direction {
        case .UP:
            self.x = position.x
            self.y = position.y + 1
        case .DOWN:
            self.x = position.x
            self.y = position.y - 1
        case .LEFT:
            self.x = position.x - 1
            self.y = position.y
        case .RIGHT:
            self.x = position.x + 1
            self.y = position.y
        }
    }
    
    init(byMovingDiagonallyWithCombinationOfYDirection yDirection: Direction, andXDirection xDirection: Direction, fromPosition position: Position) {
        let deltaX = xDirection == .RIGHT ? +1 : -1
        let deltaY = yDirection == .UP ? +1 : -1
        
        self.x = position.x + deltaX
        self.y = position.y + deltaY
    }
    
    func isAdjacentTo(position: Position) -> Bool {
        return abs(self.y - position.y) <= 1 && abs(self.x - position.x) <= 1
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
}

struct BridgeMove: CustomStringConvertible {
    var direction: Direction
    var distance: Int
    
    var description: String {
        return "\(direction) -> \(distance)"
    }
    
    init?(fromStringData data: String) {
        guard let loadedDirection = Direction(rawValue: data.first!) else {
            return nil
        }
        
        self.direction = loadedDirection
        
        guard let loadedDistance = Int(data.suffix(from: data.index(after:data.firstIndex(of: " ")!))) else {
            return nil
        }
        
        self.distance = loadedDistance
    }
}

class RopeBridge: CodeChallenge {
    var moves: [BridgeMove] = []
    
    override init(fromDataFile fileName: String = "2022-12-09") {
        super.init(fromDataFile: fileName)
    }
    
    override func runChallenge() {
        self.loadMoves()
        
        print("===================================")
        print("2022-12-09: Rope Bridge    ")
        print("===================================")
        print("")
        
        var ropeStates: [[Position]] = [[Position(x: 0, y: 0), Position(x: 0, y: 0)]]

        for move in self.moves {
            for _ in 0..<move.distance {
                ropeStates.append(self.processMove(inDirection: move.direction, forKnots: ropeStates.last!))
            }
        }
        
        let uniqueTailPositions = Set(ropeStates.map({$0.last}))
        print("Short rope unique tail positions for route: \(uniqueTailPositions.count)")
        
        ropeStates = [Array(repeating: Position(x: 0, y: 0), count: 10)]
        for move in self.moves {
            for _ in 0..<move.distance {
                ropeStates.append(self.processMove(inDirection: move.direction, forKnots: ropeStates.last!))
            }
        }
        
        let longUniqueTailPositions = Set(ropeStates.map({$0.last}))
        print("Long rope unique tail positions for route: \(longUniqueTailPositions.count)")
    }
    
    
    
    func loadMoves() {
        guard let data = self.loadLineDataFromFile(withName: self.dataFileName) else {
            print("Error loading \(self.dataFileName)")
            return
        }
        
        self.moves = data.components(separatedBy: .newlines).filter({ line in line.count > 0 }).compactMap({ moveData in BridgeMove(fromStringData: moveData) })
    }
    
    func processMove(inDirection direction: Direction, forKnots knots: [Position]) -> [Position] {
        let headPosition = knots.first!
        let newHeadPosition: Position = Position(byMovingInDirection: direction, fromPosition: headPosition)
        
        var newRopeState: [Position] = [newHeadPosition]
        
        var predecessorBefore = headPosition
        var predecessorAfter = newHeadPosition
        
        for (idx, knot) in knots.dropFirst().enumerated() {
//            print("Processing knot \(idx+1)")
            if knot.isAdjacentTo(position: predecessorAfter) {
//                print("Adjacent, \(predecessorBefore), \(predecessorAfter), \(knot)")
                newRopeState.append(knot)
                predecessorBefore = knot
                predecessorAfter = knot
            } else {
                var moveComponentX: Direction? = nil
                var moveComponentY: Direction? = nil
                
                if (predecessorAfter.x != knot.x) {
                    moveComponentX = predecessorAfter.x - knot.x > 0 ? .RIGHT : .LEFT
                }
                
                if (predecessorAfter.y != knot.y) {
                    moveComponentY = predecessorAfter.y - knot.y > 0 ? .UP : .DOWN
                }
                
                if (moveComponentX != nil && moveComponentY != nil) {
//                    print("Diagonal drag, \(predecessorBefore), \(predecessorAfter), \(knot)")
                    let newKnotPosition = Position(
                        byMovingDiagonallyWithCombinationOfYDirection: moveComponentY!,
                        andXDirection: moveComponentX!,
                        fromPosition: knot
                    )
                    newRopeState.append(newKnotPosition)
                    predecessorBefore = knot
                    predecessorAfter = newKnotPosition
                } else {
//                    print("Orthagonal drag, \(predecessorBefore), \(predecessorAfter), \(knot)")
                    let directionToMove = (moveComponentX != nil ? moveComponentX : moveComponentY)!
                    let newKnot = Position(byMovingInDirection: directionToMove, fromPosition: knot)
                    newRopeState.append(newKnot)
                    predecessorAfter = newKnot
                    predecessorBefore = knot
                }
            }
        }
        
//        self.printRopeState(withKnots: newRopeState)
        
        return newRopeState
    }
    
    func printRopeState(withKnots knots: [Position]) {
        for y in (-15...15).reversed() {
            var line: [String] = []
            for x in -15...15 {
                if knots.first!.x == x && knots.first!.y == y {
                    line.append("H")
                } else {
                    if let firstFound = knots.dropFirst().firstIndex(where: { $0.x == x && $0.y == y }) {
                        line.append("\(firstFound)")
                    } else if x == 0 && y == 0 {
                        line.append("s")
                    } else {
                        line.append(".")
                    }
                }
            }
            print(line.joined(separator: " "))
        }
    }
}
