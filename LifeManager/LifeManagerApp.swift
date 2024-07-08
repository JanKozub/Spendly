//
//  LifeManagerApp.swift
//  LifeManager
//
//  Created by Jan Kozub on 15/06/2024.
//

import SwiftUI
import SwiftData

@main
struct LifeManagerApp: App {
    let container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: Year.self, Spending.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1300, minHeight: 600)
        }
        .modelContainer(container)
    }
}
