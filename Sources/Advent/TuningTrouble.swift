//
//  TuningTrouble.swift
//  
//
//  Created by Josef Lange on 12/6/22.
//

import Foundation

class TuningTrouble: CodeChallenge {
    var signal: String = ""
    
    override init(fromDataFile fileName: String = "2022-12-06") {
        super.init(fromDataFile: fileName)
    }
    
    func loadSignal() {
        guard var data = self.loadLineDataFromFile(withName: self.dataFileName) else {
            print("Data not found!")
            return
        }
        
        self.signal = data.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func retrieveMarkers(forMarkerLength markerLength: Int = 4) -> [(Int, Substring)] {
        var markers: [(Int, Substring)] = []
        
        for i in 0..<self.signal.count - markerLength {
            let start = self.signal.index(self.signal.startIndex, offsetBy: i)
            let end = self.signal.index(self.signal.startIndex, offsetBy: i + markerLength)
            let potentialMarker = self.signal[start..<end]
            if Set(potentialMarker).count == markerLength {
                markers.append((i + markerLength, potentialMarker))
            }
        }
        
        return markers
    }
    
    func firstMarkerPosition(forMarkerLength markerLength: Int = 4) -> Int? {
        let markers = self.retrieveMarkers(forMarkerLength: markerLength)
        if markers.count > 0 {
            return markers[0].0
        }
        
        return nil
    }
    
    override func runChallenge() {
        self.loadSignal()
        
        print("===================================")
        print("2022-12-06: Tuning Trouble")
        print("===================================")
        print("")
        
        print("First marker position (unique len 4): \(self.firstMarkerPosition()!)")
        print("First marker position (unique len 14): \(self.firstMarkerPosition(forMarkerLength: 14)!)")
    }
}
