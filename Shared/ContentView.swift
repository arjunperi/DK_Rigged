//
//  ContentView.swift
//  Shared
//
//  Created by Arjun Peri on 8/16/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var appState = AppState()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SportsView()
                .tabItem {
                    Image(systemName: "sportscourt.fill")
                    Text("Sports")
                }
                .tag(0)
            
            CasinoView()
                .tabItem {
                    Image(systemName: "dice.fill")
                    Text("Casino")
                }
                .tag(1)
            
            AccountView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Account")
                }
                .tag(2)
        }
        .environmentObject(appState)
        .accentColor(.green)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
