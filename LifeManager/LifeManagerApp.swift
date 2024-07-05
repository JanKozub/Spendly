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
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 1300, minHeight: 600)
        }
        .modelContainer(for: Year.self)
    }
}
