//
//  DatabaseHelper.swift
//  commproviderlookup
//
//  Created by Yannick McCabe-Costa on 10/10/2024.
//

import Foundation
import SQLite

struct PhoneNumberDBResult {
    let prefix: String
    let status: String
    let cp: String
}

class DatabaseHelper {
    private var db: Connection?
    private let numberingAllocation = Table("numbering_allocation")
    
    // Treat `numberColumn` as `Int64?` to align with `INTEGER` storage in the database
    private let numberColumn = Expression<Int64?>("number")
    private let statusColumn = Expression<String?>("status")
    private let cpColumn = Expression<String?>("cp")

    init() {
        connectDatabase()
    }

    private func connectDatabase() {
        do {
            if let path = Bundle.main.path(forResource: "database", ofType: "sqlite3") {
                db = try Connection(path)
                print("Database connected successfully at \(path)")
            } else {
                print("Database file not found in the bundle.")
            }
        } catch {
            print("Failed to connect to the database: \(error)")
        }
    }

    func searchLongestPrefixMatching(phonePrefixes: [String]) -> [PhoneNumberDBResult] {
        guard let db = db else {
            print("Database connection not established.")
            return []
        }

        // Convert `phonePrefixes` to `Int64` for integer-based matching
        let phonePrefixesAsInt64: [Int64] = phonePrefixes.compactMap { Int64($0) }
        var result: [PhoneNumberDBResult] = []
        
        do {
            let query = numberingAllocation
                .filter(phonePrefixesAsInt64.contains(numberColumn)) // Use `IN` with integer-based `phonePrefixes`
                .order(length(numberColumn).desc) // Order by length to get the longest match
                .limit(1) // Only take the longest match

            for row in try db.prepare(query) {
                if let prefix = row[numberColumn], let status = row[statusColumn], let cp = row[cpColumn] {
                    let dbResult = PhoneNumberDBResult(
                        prefix: String(prefix), // Convert prefix back to String for display
                        status: status,
                        cp: cp
                    )
                    result.append(dbResult)
                    break
                }
            }
            
            if result.isEmpty {
                print("No results found for the given prefixes.")
            }
        } catch {
            print("Failed to query database: \(error)")
        }

        return result
    }
}

// Helper to define the computed expression for length, adapted for Int64 columns
private func length(_ expression: Expression<Int64?>) -> Expression<Int> {
    return Expression("LENGTH(\(expression.template))", [])
}
