//
//  MonkeyBusiness.swift
//  
//
//  Created by Josef Lange on 12/12/22.
//

import Foundation

enum Operator: CustomStringConvertible {
    case multiply;
    case add;
    
    var description: String {
        switch self {
        case .add:
            return "+"
        case .multiply:
            return "*"
        }
    }
}

class Monkey: CustomStringConvertible {
    var monkeyId: Int
    var items: [Int]
    
    var op: Operator
    var operand: Int?
    
    var testDivisor: Int
    var testTrueTarget: Int
    var testFalseTarget: Int
    
    var inspectionCount: Int = 0
    
    var description: String {
        var lines: [String] = []
        
        lines.append("Monkey \(monkeyId):")
        lines.append("  Starting items: \(items.map({ String($0) }).joined(separator: ", "))")
        lines.append("  Operation: new = old \(op) \(operand != nil ? String(operand!) : "old")")
        lines.append("  Test: divisible by \(testDivisor)")
        lines.append("    If true: throw to monkey \(testTrueTarget)")
        lines.append("    If false: throw to monkey \(testFalseTarget)")
        
        return lines.joined(separator: "\n")
    }
    
    
    init(withMonkeyId monkeyId: Int, items: [Int], op: Operator, operand: Int?, testDivisor: Int, testTrueTarget: Int, testFalseTarget: Int) {
        self.monkeyId = monkeyId
        self.items = items
        self.op = op
        self.operand = operand
        self.testDivisor = testDivisor
        self.testTrueTarget = testTrueTarget
        self.testFalseTarget = testFalseTarget
    }
    
    convenience init?(fromMonkeyData monkeyData: [String]) {
        var monkeyId: Int? = nil
        var items: [Int]? = nil
        var op: Operator? = nil
        var operand: Int? = nil
        var testDivisor: Int? = nil
        var testTrueTarget: Int? = nil
        var testFalseTarget: Int? = nil
        
        for line in monkeyData {
            let cleanLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if cleanLine.hasPrefix("Monkey ") {
                monkeyId = Int(line.dropLast().components(separatedBy: .whitespaces).last!)!
            } else if cleanLine.hasPrefix("Starting items: ") {
                items = cleanLine.suffix(from: cleanLine.index(after: cleanLine.firstIndex(of: ":")!)).components(separatedBy: ",").map({ $0.trimmingCharacters(in: .whitespaces) }).map({ Int($0)! })
            } else if cleanLine.hasPrefix("Operation: ") {
                let operationString = cleanLine.suffix(from: cleanLine.index(after: cleanLine.firstIndex(of: "=")!)).trimmingCharacters(in: .whitespaces)
                let operationArguments = operationString.components(separatedBy: " ").dropFirst()
                let opString = operationArguments.first!
                let operandString = operationArguments.last!
                
                if opString == "*" {
                    op = .multiply
                } else {
                    op = .add
                }
                
                operand = Int(operandString)
            } else if cleanLine.hasPrefix("Test: ") {
                testDivisor = Int(cleanLine.components(separatedBy: " ").last!)!
            } else if cleanLine.hasPrefix("If true:") {
                testTrueTarget = Int(cleanLine.components(separatedBy: " ").last!)!
            } else if cleanLine.hasPrefix("If false:") {
                testFalseTarget = Int(cleanLine.components(separatedBy: " ").last!)!
            }
        }
        
        guard monkeyId != nil && items != nil && op != nil && testDivisor != nil && testTrueTarget != nil && testFalseTarget != nil else {
            return nil
        }
        
        self.init(withMonkeyId: monkeyId!, items: items!, op: op!, operand: operand, testDivisor: testDivisor!, testTrueTarget: testTrueTarget!, testFalseTarget: testFalseTarget!)
    }
    
    func inspectItem(atIndex itemIndex: Int, advancedReliefBase: Int? = nil) {
        let item = self.items[itemIndex]
        let resolvedOperand = self.operand ?? item
        
        switch(self.op) {
        case .multiply:
            self.items[itemIndex] = item * resolvedOperand
        case .add:
            self.items[itemIndex] = item + resolvedOperand
        }
        
        if advancedReliefBase != nil {
            self.items[itemIndex] = self.items[itemIndex] % advancedReliefBase!
        } else {
            self.items[itemIndex] /= 3
        }
        
        self.inspectionCount += 1
    }
    
    func getDestinationMonkeyIndex(forItemAtIndex itemIndex: Int) -> Int {
        return self.items[itemIndex] % self.testDivisor == 0 ? self.testTrueTarget : self.testFalseTarget
    }
    
    func throwItem(atIndex itemIndex: Int, toMonkey otherMonkey: Monkey) {
        let item = self.items.remove(at: itemIndex)
        otherMonkey.receiveItem(item)
    }
    
    func receiveItem(_ item: Int) {
        self.items.append(item)
    }
}

class MonkeyBusiness: CodeChallenge {
    var monkeys: [Monkey] = []
    var useAdvancedWorryRelief: Bool = false
    
    override init(fromDataFile fileName: String = "2022-12-11") {
        super.init(fromDataFile: fileName)
    }
    
    override func runChallenge() {
        self.loadMonkeys()
        
        print("===================================")
        print("2022-12-11: Monkey Business    ")
        print("===================================")
        print("")
        
        self.processRounds(20)
        
        print("Monkey Business Level: \(self.getMonkeyBusiness())")
        
        self.useAdvancedWorryRelief = true
        self.loadMonkeys()
        
        self.processRounds(10000)
        
        print("Unbounded Monkey Business Level: \(self.getMonkeyBusiness())")
        
    }
    
    func loadMonkeys() {
        guard let data = self.loadLineDataFromFile(withName: self.dataFileName) else {
            print("Error loading \(self.dataFileName)")
            return
        }
        
        self.monkeys = data.components(separatedBy: "\n\n").compactMap({ monkeyDataString in Monkey(fromMonkeyData: monkeyDataString.components(separatedBy: .newlines) ) })
    }
    
    func getAdvancedReliefBase() -> Int? {
        if self.useAdvancedWorryRelief {
            return self.monkeys.map({ $0.testDivisor }).reduce(1, *)
        }
        
        return nil
    }
    
    func processRounds(_ roundCount: Int) {
        for _ in 0..<roundCount {
            self.processRound()
        }
    }
    
    func processRound() {
        self.monkeys.forEach({ processTurn(forMonkey: $0) })
    }
    
    func processTurn(forMonkey monkey: Monkey) {
        var throwsToMake: [(Int, Int)] = []
        for (itemIndex, _) in monkey.items.enumerated() {
            monkey.inspectItem(atIndex: itemIndex, advancedReliefBase: self.getAdvancedReliefBase())
            let destinationMonkeyIndex = monkey.getDestinationMonkeyIndex(forItemAtIndex: itemIndex)
            throwsToMake.append((itemIndex, destinationMonkeyIndex))
        }
        
        for (itemIndex, destinationMonkeyIndex) in throwsToMake.reversed() {
            let otherMonkey = self.monkeys[destinationMonkeyIndex]
            monkey.throwItem(atIndex: itemIndex, toMonkey: otherMonkey)
        }
    }
    
    func acquireTargets(numberOfTargets: Int) -> [Monkey] {
        return Array(self.monkeys.sorted(by: { $0.inspectionCount > $1.inspectionCount })[..<numberOfTargets])
    }
    
    func getMonkeyBusiness() -> Int {
        return self.acquireTargets(numberOfTargets: 2).map({ $0.inspectionCount }).reduce(1, *)
    }
}
