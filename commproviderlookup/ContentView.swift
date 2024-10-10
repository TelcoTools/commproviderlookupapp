//
//  ContentView.swift
//  commproviderlookup
//
//  Created by Yannick McCabe-Costa on 10/10/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            CPLookupView()
                .tabItem {
                    Label("CP Lookup", systemImage: "phone.fill")
                }
                .tag(0)
                .transition(.move(edge: .trailing))

            CUPIDsView()
                .tabItem {
                    Label("CUPIDs", systemImage: "building.fill")
                }
                .tag(1)
                .transition(.move(edge: selectedTab == 1 ? .leading : .trailing))

            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle.fill")
                }
                .tag(2)
                .transition(.move(edge: selectedTab == 2 ? .leading : .trailing))
        }
        .animation(.easeInOut, value: selectedTab)
    }
}

#Preview {
    ContentView()
}
