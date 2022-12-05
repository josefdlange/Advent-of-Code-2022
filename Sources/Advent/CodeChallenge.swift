//
//  File.swift
//  
//
//  Created by Josef Lange on 12/5/22.
//

import Foundation

class CodeChallenge {
    var dataFileName: String = ""
    
    init(fromDataFile fileName: String) {
        self.dataFileName = fileName
    }
    
    func loadLineDataFromFile(withName fileName: String, ofType fileType: String = "txt") -> String? {
        guard let resource = Bundle.module.path(forResource: fileName, ofType: fileType, inDirectory: nil) else {
            print("Resource \(fileName).\(fileType) not found!")
            return nil
        }
            
        do {
            return try String(contentsOfFile: resource)
        } catch {
            return ""
        }
        
    }
    
    func runChallenge() {
        // Do nothing, for the base class.
    }
}
