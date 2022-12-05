// Dec1 - December 1st AoC Challenge

struct Elf {
    var snacks : [Int]
    
    init(snacksData: String) {
        self.snacks = snacksData.components(separatedBy: .newlines).compactMap { stringValue in
            guard let intValue = Int(stringValue) else {
                return nil
            }
            
            return intValue
        }
    }
    
    func calorieCount() -> Int {
        return self.snacks.reduce(0, +)
    }
}

class ElfCalories : CodeChallenge {
    var elves : [Elf] = []
    
    init(fromDataFile fileName: String = "2022-12-01") {
        super.init()
        self.loadElves(withFile: fileName)
    }
    
    func loadElves (withFile fileName : String) {
        guard let data = self.loadLineDataFromFile(withName: fileName) else {
            print("Data not found!")
            return
        }
        
        for elfCalories in data.components(separatedBy: "\n\n") {
            self.elves.append(Elf(snacksData: elfCalories))
        }
    }
    
    override func runChallenge() {
        print("===============================")
        print("2022-12-01: Elf Calorie Counter")
        print("===============================")
        print("")
        
        let elfWithMost = self.getElfWithMostCalories()
        print("Elf with the most calories: \(elfWithMost!.calorieCount())")
        
        let topThreeElves = self.getTopElves(howManyElves: 3)
        print("Total calorie count of top three elves: \(topThreeElves.map({ elf in elf.calorieCount() }).reduce(0, +))")
        print("")
    }
    
    func getTopElves(howManyElves : Int) -> ArraySlice<Elf> {
        let sortedElves = self.elves.sorted { elfOne, elfTwo in
            return elfOne.calorieCount() > elfTwo.calorieCount()
        }
        
        return sortedElves.prefix(howManyElves)
    }
    
    func getElfWithMostCalories() -> Elf? {
        let topElves = self.getTopElves(howManyElves: 1)
        return topElves.first
    }
}
