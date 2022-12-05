//
//  ElfRockPaperScissors.swift
//  
//
//  Created by Josef Lange on 12/5/22.
//

import Foundation

enum Outcome {
    case victory
    case draw
    case defeat
    
    func requiredMove(forOtherMove otherMove: Move) -> Move {
        switch self {
        case .draw:
            return otherMove
        case .victory:
            switch otherMove {
            case .rock:
                return .paper
            case .paper:
                return .scissors
            case .scissors:
                return .rock
            }
        case .defeat:
            switch otherMove {
            case .rock:
                return .scissors
            case .paper:
                return .rock
            case .scissors:
                return .paper
            }
        }
    }
}

enum Move : Comparable {
    case rock
    case paper
    case scissors
    
    static func > (lhs: Move, rhs: Move) -> Bool {
        switch lhs {
        case .rock:
            return rhs == .scissors
        case .paper:
            return rhs == .rock
        case .scissors:
            return rhs == .paper
        }
    }
    
    static func < (lhs: Move, rhs: Move) -> Bool {
        switch lhs {
        case .rock:
            return rhs == .paper
        case .paper:
            return rhs == .scissors
        case .scissors:
            return rhs == .rock
        }
    }
    
    func scoreForPlaying() -> Int {
        switch self {
        case .rock:
            return 1
        case .paper:
            return 2
        case .scissors:
            return 3
        }
    }
}

class ElfRockPaperScissors : CodeChallenge {
    var naiveStrategyGuide: [[Move]] = []
    var roundOutcomeStrategyGuide: [(Move, Outcome)] = []
    
    init(fromDataFile fileName: String = "2022-12-02") {
        super.init()
        self.loadGuide(withFile: fileName)
    }
    
    func getMove(forGuideValue guideValue: String) -> Move? {
        switch(guideValue) {
        case "A", "X":
            return .rock
        case "B", "Y":
            return .paper
        case "C", "Z":
            return .scissors
        default:
            return nil
        }
    }
    
    func getOutcome(forGuideValue guideValue: String) -> Outcome? {
        switch guideValue {
        case "X":
            return .defeat
        case "Y":
            return .draw
        case "Z":
            return .victory
        default:
            return nil
        }
    }
    
    // The score for a single round is the score for the shape you selected
    // (1 for Rock, 2 for Paper, and 3 for Scissors) plus the score for the
    // outcome of the round (0 if you lost, 3 if the round was a draw, and 6
    // if you won).
    func scoreRound(theirMove: Move, myMove: Move) -> Int {
        return myMove.scoreForPlaying() + (myMove > theirMove ? 6 : (myMove == theirMove ? 3 : 0))
    }
    
    func loadGuide(withFile fileName: String) {
        guard let data = self.loadLineDataFromFile(withName: fileName) else {
            print("Data not found!")
            return
        }
        
        for playLine in data.components(separatedBy: .newlines) {
            let tokens = playLine.components(separatedBy: .whitespaces)
            
            guard tokens.count == 2 else {
                print("Skipping line: \(playLine)")
                continue
            }
            
            self.naiveStrategyGuide.append(tokens.compactMap({ play in self.getMove(forGuideValue:play) }))
            
            let theirMove = self.getMove(forGuideValue: tokens.first!)
            let outcome = self.getOutcome(forGuideValue: tokens.last!)
            
            guard theirMove != nil else { continue }
            guard outcome != nil else { continue }
                
            self.roundOutcomeStrategyGuide.append((theirMove!, outcome!))
        }
    }
    
    func getNaiveGameTotal() -> Int {
        return self.naiveStrategyGuide.compactMap({ moves in
            return self.scoreRound(theirMove: moves[0], myMove: moves[1])
        }).reduce(0, +)
    }
    
    func getStrategicGameTotal() -> Int {
        return self.roundOutcomeStrategyGuide.compactMap({ (theirMove: Move, outcome: Outcome) in
            let myMove = outcome.requiredMove(forOtherMove: theirMove)
            return self.scoreRound(theirMove: theirMove, myMove: myMove)
        }).reduce(0, +)
    }
    
    override func runChallenge() {
        print("===================================")
        print("2022-12-02: Elf Rock/Paper/Scissors")
        print("===================================")
        print("")
        
        print("Naïve game total: \(self.getNaiveGameTotal())")
        print("Strategic game total: \(self.getStrategicGameTotal())")
        
        print("")
    }
}
