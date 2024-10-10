//
//  CUPIDsView.swift
//  commproviderlookup
//
//  Created by Yannick McCabe-Costa on 10/10/2024.
//

import Foundation
import SwiftUI

struct CUPIDsView: View {
    @State private var searchText: String = ""
    @State private var cupidEntries: [CupidEntry] = []

    // Filtered entries based on search text (supports both CP name and CUPID)
    private var filteredEntries: [CupidEntry] {
        if searchText.isEmpty {
            return cupidEntries  // Show all entries if no search text is provided
        } else {
            return cupidEntries.filter {
                "\($0.cupid)".contains(searchText) || $0.cp.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        VStack {
            // Search bar with alphanumeric input and "Done" button
            TextFieldWithDoneButton(text: $searchText, placeholder: "Find by CUPID or CP Name", isNumeric: false) // Pass isNumeric as false
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal)

            // Scrollable List of CUPID entries
            List(filteredEntries) { entry in
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.cp)
                        .font(.headline)
                    Text("CUPID: \(entry.cupid)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
            }
            .listStyle(PlainListStyle()) // Keeps the list simple and scrollable
        }
        .navigationTitle("CUPIDs")
        .onAppear {
            cupidEntries = CUPIDDataLoader().loadCUPIDs() // Load the static JSON data
        }
    }
}
