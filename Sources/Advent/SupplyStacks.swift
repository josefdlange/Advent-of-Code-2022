//
//  CampCleanup.swift
//
//
//  Created by Josef Lange on 12/5/22.
//

import Foundation

struct CraneOperation {
    var quantity: Int
    var fromStack: Int
    var toStack: Int
    
    init(quantity: Int, fromStack: Int, toStack: Int) {
        self.quantity = quantity
        self.fromStack = fromStack
        self.toStack = toStack
    }
    
    init?(fromOperationDescriptionString descriptionString: String) {
        let params = descriptionString.components(separatedBy: .whitespaces).compactMap{Int($0)}
        guard params.count == 3 else {
            return nil
        }
        
        self.init(quantity: params[0], fromStack: params[1], toStack: params[2])
    }
}

class SupplyStacks : CodeChallenge {
    var operations: [CraneOperation] = []
    var supplyStacks: [[Character]] = []
    
    override init(fromDataFile fileName: String = "2022-12-05") {
        super.init(fromDataFile: fileName)
    }
    
    func loadCargoManifestAndMoves() {
        guard let data = self.loadLineDataFromFile(withName: self.dataFileName) else {
            print("Data not found!")
            return
        }
        
        let sections = data.components(separatedBy: "\n\n")
        guard sections.count == 2 else {
            print("Input data malformed (> 2 sections)")
            return
        }
        
        // I'm too lazy to implement a clever way to rotate this matrix so here's a hacky version
        let initialCargoState: [String] = sections[0].components(separatedBy: "\n")
        var rotatedCargoState: [[Character]] = Array(repeating: Array(repeating: " ", count: initialCargoState.count), count: initialCargoState.map({ str in str.count }).max()!)
        
        for xIndex in 0..<initialCargoState.count {
            for yIndex in 0..<initialCargoState.map({ str in str.count }).max()! {
                let sourceRow = Array(initialCargoState[xIndex])
                
                if yIndex < sourceRow.count {
                    rotatedCargoState[yIndex][initialCargoState.count - xIndex - 1] = Array(initialCargoState[xIndex])[yIndex];
                }
            }
        }
        
        rotatedCargoState = rotatedCargoState.filter { potentialStack in potentialStack.first != " "}
        self.supplyStacks = rotatedCargoState.map({ rawStack in
            rawStack.filter { char in
                char.isLetter
            }
        })
        
        let operations = sections[1]
        self.operations = operations.components(separatedBy: .newlines).compactMap{ CraneOperation(fromOperationDescriptionString: $0) }
    }
    
    func processCraneOperation(operation: CraneOperation) {
        for _ in 0..<operation.quantity {
            let crate = self.supplyStacks[operation.fromStack - 1].popLast()
            guard crate != nil else {
                continue
            }
            
            self.supplyStacks[operation.toStack - 1].append(crate!)
        }
    }
    
    func processCraneOperation9001(operation: CraneOperation) {
        var popped: [Character] = []
        for _ in 0..<operation.quantity {
            let crate = self.supplyStacks[operation.fromStack - 1].popLast()
            guard crate != nil else {
                continue
            }
            
            popped.insert(crate!, at: 0)
        }
        
        self.supplyStacks[operation.toStack - 1].append(contentsOf: popped)
    }
    
    func getStackTops() -> String {
        return String(self.supplyStacks.map({ stack in
            if let top = stack.last {
                return top
            } else {
                return " "
            }
        }))
    }
    
    func runAllOperations() {
        self.operations.forEach { operation in
            self.processCraneOperation(operation: operation)
        }
    }
    
    func runAllOperations9001() {
        self.operations.forEach { operation in
            self.processCraneOperation9001(operation: operation)
        }
    }
    
    override func runChallenge() {
        print("===================================")
        print("2022-12-05: Supply Stacks")
        print("===================================")
        print("")
        
        self.loadCargoManifestAndMoves()
        self.runAllOperations()
        print("Stack Tops: \(self.getStackTops())")
        
        self.loadCargoManifestAndMoves()
        self.runAllOperations9001()
        print("Stack Tops (9001): \(self.getStackTops())")
    }
}
