//
//  SidebarView.swift
//  LifeManager
//
//  Created by Jan Kozub on 01/07/2024.
//

import SwiftUI

struct SidebarView: View {
    @Binding var selection: TabSection?
    
    var body: some View {
        List(selection: $selection) {
            Section() {
                ForEach(TabSection.allCases) { tab in
                    Label(tab.displayName, systemImage: tab.iconName).tag(tab)
                }
            }
        }
    }
}

#Preview {
    SidebarView(selection: .constant(.spendings)).listStyle(.sidebar)
}
