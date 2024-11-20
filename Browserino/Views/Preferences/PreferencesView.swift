// PreferencesView.swift
// Browserino
//
// Created by Aleksandr Strizhnev on 06.06.2024.
//

import AppKit
import SwiftUI

extension NSTableView {
    open override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        backgroundColor = NSColor.clear
        enclosingScrollView?.drawsBackground = false
    }
}

struct PreferencesView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralTab()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag(0)
            
            BrowsersTab()
                .tabItem {
                    Label("Browsers", systemImage: "globe")
                }
                .tag(1)
            
            AppsTab()
                .tabItem {
                    Label("Apps", systemImage: "app")
                }
                .tag(2)
            
            BrowserSearchLocationsTab()
                .tabItem {
                    Label("Locations", systemImage: "location")
                }
                .tag(3)
    
            AboutTab()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(4)
            
            RulesTab()
                .tabItem {
                    Label("Rules", systemImage: "doc.text")
                }
                .tag(5)
        }
        .frame(minWidth: 700, minHeight: 500)
    }
}

#Preview {
    PreferencesView()
}
