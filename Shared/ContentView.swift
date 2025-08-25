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
        .accentColor(AppTheme.casinoBlue)
        .onAppear {
            #if os(iOS)
            // Ensure tab bar is always visible with dark theme
            UITabBar.appearance().backgroundColor = UIColor.clear
            UITabBar.appearance().unselectedItemTintColor = UIColor(AppTheme.secondaryText)
            UITabBar.appearance().isTranslucent = true
            
            // Remove default borders and shadows
            UITabBar.appearance().shadowImage = UIImage()
            UITabBar.appearance().backgroundImage = UIImage()
            
            // Customize tab bar appearance for iOS 15+
            if #available(iOS 15.0, *) {
                let appearance = UITabBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.backgroundColor = UIColor.clear
                appearance.shadowColor = UIColor.clear
                appearance.shadowImage = UIImage()
                
                // Customize tab item appearance
                appearance.stackedLayoutAppearance.selected.iconColor = UIColor(AppTheme.casinoBlue)
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                    .foregroundColor: UIColor(AppTheme.casinoBlue),
                    .font: UIFont.boldSystemFont(ofSize: 12)
                ]
                
                appearance.stackedLayoutAppearance.normal.iconColor = UIColor(AppTheme.secondaryText)
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                    .foregroundColor: UIColor(AppTheme.secondaryText),
                    .font: UIFont.boldSystemFont(ofSize: 12)
                ]
                
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
            
            // Additional styling for better visibility
            UITabBar.appearance().barTintColor = UIColor.clear
            UITabBar.appearance().tintColor = UIColor(AppTheme.casinoBlue)
            #endif
        }
        .overlay(
            // Clean tab bar without borders
            Color.clear
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .frame(maxHeight: .infinity, alignment: .top)
        )
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .preferredColorScheme(.dark)
        #if os(iOS)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            // Ensure tab bar styling is maintained when app becomes active
            UITabBar.appearance().backgroundColor = UIColor.clear
            UITabBar.appearance().barTintColor = UIColor.clear
            UITabBar.appearance().tintColor = UIColor(AppTheme.casinoBlue)
        }
        #endif
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
