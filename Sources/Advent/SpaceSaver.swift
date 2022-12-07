//
//  SpaceSaver.swift
//  
//
//  Created by Josef Lange on 12/6/22.
//

import Foundation

class FSNode : CustomStringConvertible {
    private(set) var parent: FSNode? = nil
    private(set) var name: String
    private(set) var isDirectory: Bool
    private(set) var size: Int?
    private(set) var children: [FSNode] = []
    
    init(withDirectoryName name: String) {
        self.name = name
        self.isDirectory = true
        self.size = nil
    }
    
    init(withFileName name: String, andSize size: Int) {
        self.name = name
        self.isDirectory = false
        self.size = size
    }
    
    func getTotalSize() -> Int {
        let innateSize = self.size ?? 0
        return innateSize + self.children.reduce(0, { partialResult, childNode in partialResult + childNode.getTotalSize() })
    }
    
    func addChildNode(child: FSNode) {
        child.parent = self
        self.children.append(child)
    }
    
    func findChild(withName name: String) -> FSNode? {
        self.children.first { node in node.name == name }
    }
    
    func findNodes(matchingRequirement matchesRequirement: (FSNode) -> Bool) -> [FSNode] {
        let initial = matchesRequirement(self) ? [self] : []
        return self.children.reduce(initial) { partialResult, childNode in
            return partialResult + childNode.findNodes(matchingRequirement: matchesRequirement)
        }
    }
    
    func getParentCount() -> Int {
        guard let parent = self.parent else {
            return 0
        }
        
        return parent.getParentCount() + 1
    }
    
    var description: String {
        let prefix = String(repeating: " ", count: self.getParentCount() * 2)
        let myLine = "\(prefix) \(isDirectory ? "DIR" : "FILE") - \"\(name)\" \(size != nil ? " - \(size!)" : "")"
        let childLines = self.children.map { node in node.description }
        let allLines = [myLine] + childLines
        return String(allLines.joined(separator:"\n"))
    }
}

class SpaceSaver: CodeChallenge {
    var commands: [String] = []
    var fsRoot: FSNode = FSNode(withDirectoryName: "/")
    var _currentDirectory: FSNode? = nil
    var currentDirectory: FSNode {
        get {
            return _currentDirectory ?? fsRoot
        }
        set {
            _currentDirectory = newValue
        }
    }
    
    override init(fromDataFile fileName: String = "2022-12-07") {
        super.init(fromDataFile: fileName)
    }
    
    override func runChallenge() {
        self.loadCommands()
        
        print("===================================")
        print("2022-12-07: No Space Left On Device")
        print("===================================")
        print("")
        
        self.processFilesystem()
        
        print("Filesystem traversed!")
        print("")
        print(self.fsRoot)
        print("")
        
        let underThresholdSize = self.getCombinedSizesOfDirectories(belowThreshold: 100000)
        print("Sum of sizes of directories who are < 100000 in total size: \(underThresholdSize)")
        
        let spaceDeficit = self.determineSpaceDeficit(forTotalSpace: 70000000, requiredSpace: 30000000)
        print("Looking for best candidate directory to delete to free up space of \(spaceDeficit)...")
        guard let candidate = self.findSmallestDirectory(aboveThreshold: spaceDeficit) else {
            print("Candidate not found")
            return
        }
        
        print("Found: \(candidate.name) - size \(candidate.getTotalSize())")
    }
    
    func loadCommands() {
        guard let data = self.loadLineDataFromFile(withName: self.dataFileName) else {
            print("Error loading \(self.dataFileName)")
            return
        }
        
        self.commands = data.components(separatedBy: .newlines)
    }
    
    func processFilesystem() {
        for line in self.commands {
            self.interpretLine(commandLine: line)
        }
    }
    
    func interpretLine(commandLine: String) {
        guard commandLine.count > 0 else {
            print("Skipping empty line.")
            return
        }
        
        if commandLine.starts(with: "$") {
            let commandPieces = commandLine.components(separatedBy: .whitespaces)
            let command = commandPieces[1]
            let argument = commandPieces.count > 2 ? commandPieces[2] : nil
            
            processCommandInput(command: command, argument: argument)
        } else {
            processCommandOutput(commandOutput: commandLine)
        }
    }
    
    func processCommandInput(command: String, argument: String? = nil) {
        if command == "ls" {
            // Do nothing, for now, I think!
        } else if command == "cd" {
            guard argument != nil else {
                print("Invalid argument for command 'cd'")
                return
            }
            
            if argument == ".." {
                guard let parentNode = self.currentDirectory.parent else {
                    print("Directory \(self.currentDirectory.name) has no parent node.")
                    return
                }
                
                self.currentDirectory = parentNode
            } else if argument == "/" {
                self.currentDirectory = self.fsRoot
            } else {
                guard let childDirectory = self.currentDirectory.findChild(withName: argument!) else {
                    print("Directory \(argument!) not found.")
                    return
                }
                
                self.currentDirectory = childDirectory
            }
        }
    }
    
    func processCommandOutput(commandOutput: String) {
        let parts = commandOutput.components(separatedBy: .whitespaces)
        if parts[0] == "dir" {
            self.currentDirectory.addChildNode(child: FSNode(withDirectoryName: parts[1]))
        } else {
            guard let size = Int(parts[0]) else {
                print("Invalid file size: \(parts[0])")
                return
            }
            
            self.currentDirectory.addChildNode(child: FSNode(withFileName: parts[1], andSize: size))
        }
    }
    
    func getCombinedSizesOfDirectories(belowThreshold threshold: Int) -> Int {
        let directories = self.fsRoot.findNodes(matchingRequirement: { node in
            return  node.isDirectory && node.getTotalSize() < threshold
        })
  
        return directories.reduce(0) { partialResult, node in
            return partialResult + node.getTotalSize()
        }
    }
    
    func determineSpaceDeficit(forTotalSpace totalSpace: Int, requiredSpace: Int) -> Int {
        return requiredSpace - (totalSpace - self.fsRoot.getTotalSize())
    }
    
    func findSmallestDirectory(aboveThreshold threshold: Int) -> FSNode? {
        let candidateDirectories = self.fsRoot.findNodes { node in
            return node.isDirectory && node.getTotalSize() > threshold
        }
        
        return candidateDirectories.sorted(by: { $0.getTotalSize() > $1.getTotalSize() }).reversed().first
    }
}
