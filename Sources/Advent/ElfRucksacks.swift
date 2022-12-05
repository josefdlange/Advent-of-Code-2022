//
//  ElfRucksacks.swift
//  
//
//  Created by Josef Lange on 12/5/22.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

class Rucksack {
    init(compartmentContents: String) {
        self.allItems = Array(compartmentContents)
    }
    
    var allItems: [Character]
    
    func firstCompartment() -> ArraySlice<Character> {
        guard allItems.count > 0 else {
            return ArraySlice()
        }
        
        return self.allItems[0 ..< self.allItems.count / 2]
    }
    
    func secondCompartment() -> ArraySlice<Character> {
        guard allItems.count > 0 else {
            return ArraySlice()
        }
        
        return self.allItems[self.allItems.count / 2 ..< self.allItems.count]
    }
    
    func compartmentOverlappingItem() -> Character? {
        return self.firstCompartment().filter(self.secondCompartment().contains).first
    }
    
    
    static func priority(forItem item: Character) -> Int {
        if (item.isLetter && item.isLowercase) {
            return (Int(item.asciiValue!) - 96)
        } else {
            return (Int(item.asciiValue!) - 38)
        }
    }
    
    func overlapPriority() -> Int {
        guard let overlappingItem = self.compartmentOverlappingItem() else {
            return 0
        }
        
        return Rucksack.priority(forItem: overlappingItem)
    }
}

class ElfRucksacks : CodeChallenge {
    var rucksacks: [Rucksack] = []
    
    init(fromDataFile fileName: String = "2022-12-03") {
        super.init()
        self.loadRucksackData(withFile: fileName)
    }
    
    func loadRucksackData(withFile fileName : String) {
        guard let data = self.loadLineDataFromFile(withName: fileName) else {
            return
        }
        
        rucksacks.append(contentsOf: data.components(separatedBy: .newlines).filter({ string in
            !string.isEmpty
        }).compactMap { line in
            return Rucksack.init(compartmentContents: line)
        })
    }
    
    func getTotalOverlapPriority() -> Int {
        return rucksacks.compactMap({ rucksack in
            return rucksack.overlapPriority()
        }).reduce(0, +)
    }
    
    func badge(forElvesRucksacks rucksacks : [Rucksack]) -> Character {
        rucksacks.dropFirst().reduce(rucksacks.first?.allItems, { partialResult, rucksack in
            return partialResult!.filter(rucksack.allItems.contains)
        })!.first!
    }
    
    func rucksackGroups() -> [[Rucksack]] {
        return self.rucksacks.chunked(into: 3)
    }
    
    func getTotalGroupBadgePriority() -> Int {
        return self.rucksackGroups().map(self.badge(forElvesRucksacks:)).map(Rucksack.priority(forItem:)).reduce(0, +)
    }
    
    override func runChallenge() {
        print("===================================")
        print("2022-12-03: Elf Rucksacks")
        print("===================================")
        print("")
        
        print("Total item overlap priority: \(self.getTotalOverlapPriority())")
        print("Total of group badge priorities: \(self.getTotalGroupBadgePriority())")
        
        print("")
    }
}
