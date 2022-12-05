//
//  File.swift
//  
//
//  Created by Josef Lange on 12/5/22.
//

import Foundation

class CodeChallenge {
    func loadLineDataFromFile(withName fileName: String, ofType fileType: String = "txt") -> String? {
        print("Loading input data")
        
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
