//
//  ContentView.swift
//  LifeManager
//
//  Created by Jan Kozub on 15/06/2024.
//

import SwiftUI

struct ContentView: View {
    @State  private var selection: TabSection? = TabSection.spendings;
    
    var body: some View {
        NavigationSplitView {
            SidebarView(selection: $selection)
        } detail: {
            switch selection {
            case .spendings:
                SpendingsView();
            case .meals:
                MealsView();
            default:
                Text("Tab value not found");
            }
        }
    }
}
