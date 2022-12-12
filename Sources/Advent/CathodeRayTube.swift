//
//  CathodeRayTube.swift
//  
//
//  Created by Josef Lange on 12/12/22.
//

import Foundation

enum InstructionType {
    case noop
    case addx
}

struct Instruction: CustomStringConvertible {
    var instructionType: InstructionType
    var value: Int?
    
    var cycles: Int {
        switch instructionType {
        case .noop:
            return 1
        case .addx:
            return 2
        }
    }
    
    var description: String {
        switch instructionType {
        case .addx:
            return "\(instructionType) \(value!)"
        case .noop:
            return "\(instructionType)"
        }
        return "<nil>"
    }
    
    init(instructionType: InstructionType, value: Int? = nil) {
        self.instructionType = instructionType
        self.value = value
    }
    
    init?(fromStringData stringData: String) {
        if stringData.hasPrefix("noop") {
            self.init(instructionType: .noop, value: nil)
        } else if stringData.hasPrefix("addx") {
            guard let rawValue = stringData.components(separatedBy: " ").last else {
                return nil
            }
            
            guard let value = Int(rawValue) else {
                return nil
            }
            
            self.init(instructionType: .addx, value: value)
        } else {
            return nil
        }
    }
}

var relevantCycles: [Int] = [20, 60, 100, 140, 180, 220]

class CathodeRayTube: CodeChallenge {
    var instructions: [Instruction] = []
    var cycleOutcomes: [(Instruction?, Int)] = [(nil, 1)]
    
    override init(fromDataFile fileName: String = "2022-12-10") {
        super.init(fromDataFile: fileName)
    }
    
    override func runChallenge() {
        self.loadInstructions()
        
        print("===================================")
        print("2022-12-10: Cathode-Ray Tube    ")
        print("===================================")
        print("")
        
        self.processInstructions()
        
        let signalStrengths = relevantCycles.map { cycle in self.getRegisterValue(duringCycle: cycle) * cycle }
        print("Aggregate signal strength: \(signalStrengths.reduce(0, +))")
        
        print("")
        
        print(self.getScanLines().joined(separator: "\n"))
    }
    
    func loadInstructions() {
        guard let data = self.loadLineDataFromFile(withName: self.dataFileName) else {
            print("Error loading \(self.dataFileName)")
            return
        }
        
        self.instructions = data.components(separatedBy: .newlines).filter({ line in line.count > 0 }).compactMap({ instructionData in Instruction(fromStringData: instructionData) })
    }
    
    func processInstructions() {
        for instruction in self.instructions {
            let register = self.cycleOutcomes.last!.1
            
            for _ in 1..<instruction.cycles {
                self.cycleOutcomes.append((nil, register))
            }
            
            if instruction.instructionType == .addx {
                self.cycleOutcomes.append((instruction, register + instruction.value!))
            } else {
                self.cycleOutcomes.append((instruction, register))
            }
        }
    }
    
    func getXPositionOf(cycle: Int) -> Int {
        return (cycle - 1) % 40
    }
    
    func getRegisterValue(duringCycle cycle: Int) -> Int {
        // We have a synthetic "first" cyle instruction in our cycleOutcomes which
        // means cycleOutcome idx==1 is the outcome of cycle #1, therefore the
        // register value _during_ idx==1 is actually cycleOutcome idx==0
        if cycle == 0 {
            return 1
        }
        
        return self.cycleOutcomes[cycle - 1].1
    }
    
    func cycleIsLit(duringCycle cycle: Int) -> Bool {
        let cycleRegisterValue = self.getRegisterValue(duringCycle: cycle)
        let xPosition = getXPositionOf(cycle: cycle)
        
        if abs(xPosition - cycleRegisterValue) <= 1 {
            return true
        }
        
        return false
    }
    
    func getScanLines() -> [String] {
        var lines: [String] = []
        var currentLine: String = ""
        
        for (i, outcome) in self.cycleOutcomes.enumerated() {
            if i == 0 {
                continue
            }
        
            currentLine = currentLine.appending(self.cycleIsLit(duringCycle: i) ? "#" : ".")
                        
            if i % 40 == 0 {
                lines.append(currentLine)
                currentLine = ""
            }
        }
        
        return lines
    }
}
