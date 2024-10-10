//
//  CUPIDDataLoader.swift
//  commproviderlookup
//
//  Created by Yannick McCabe-Costa on 10/10/2024.
//

import Foundation

class CUPIDDataLoader {
    func loadCUPIDs() -> [CupidEntry] {
        guard let url = Bundle.main.url(forResource: "cupids", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return []
        }
        
        let decoder = JSONDecoder()
        return (try? decoder.decode([CupidEntry].self, from: data)) ?? []
    }
}

