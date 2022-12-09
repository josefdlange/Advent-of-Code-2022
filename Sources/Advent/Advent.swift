import Foundation

@main
public struct Advent {
    public static func main() {
        print("Advent of Code 2022\n")
        
        let codeChallenges: [String: CodeChallenge] = [
            "2022-12-01": ElfCalories(),
            "2022-12-02": ElfRockPaperScissors(),
            "2022-12-03": ElfRucksacks(),
            "2022-12-04": CampCleanup(),
            "2022-12-05": SupplyStacks(),
            "2022-12-06": TuningTrouble(),
            "2022-12-07": SpaceSaver(),
            "2022-12-08": TreeHouse(),
            "2022-12-09": RopeBridge()
        ]
        
        print("Please enter an advent date (YYYY-MM-DD) to run, 'all' for all dates in order, or anything else to run today's: ")
        
        let entry = readLine(strippingNewline: true)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var challengesToRun: [CodeChallenge] = []
        
        if entry == "all" {
            for dateKey in codeChallenges.keys.sorted() {
                challengesToRun.append(codeChallenges[dateKey]!)
            }
        } else if dateFormatter.date(from: entry!) != nil {
            if let challenge = codeChallenges[entry!] {
                challengesToRun.append(challenge)
            } else {
                print("Challenge \(entry!) not found!")
            }
        } else {
            if let challenge = codeChallenges[dateFormatter.string(from: Date())] {
                challengesToRun.append(challenge)
            } else {
                print("Challenge \(dateFormatter.string(from: Date())) not found!")
            }
        }
        
        for challenge in challengesToRun {
            challenge.runChallenge()
        }
    }
}
