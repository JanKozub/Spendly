//
//  ContentView.swift
//  LifeManager
//
//  Created by Jan Kozub on 15/06/2024.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.positions) { item in
                    NavigationLink(value: item) {
                        Text(item.name)
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationDestination(for: Position.self) { item in
                SpendingsView()
                    .navigationTitle(item.name)
            }
        }
    }
}
