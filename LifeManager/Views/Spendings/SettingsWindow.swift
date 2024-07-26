//
//  SettingsWindow.swift
//  LifeManager
//
//  Created by Jan Kozub on 25/07/2024.
//

import Foundation
import SwiftUI
import SwiftData

struct SettingsWindow: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var userInput: String = ""
    var context: ModelContext
    var prepareChartEntries: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Delete data") {
                try? context.delete(model: Year.self)
                prepareChartEntries()
                presentationMode.wrappedValue.dismiss()
            }.frame(maxWidth: .infinity).padding()
            
            Button("Save data to json") {
                do {
                    try DataExporter.exportToJSON(context: context)
                } catch {
                    print("Failed to save data in file")
                }
            }.frame(maxWidth: .infinity).padding()
            
            HStack {
                TextField("Enter text here", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    context.insert(PaymentCategory(name: userInput))
                    try? context.save()
                }) {
                    Text("Submit")
                }
            }.padding()
            
            Button("Close") {
                presentationMode.wrappedValue.dismiss()
            }.frame(maxWidth: .infinity).padding()
        }
        .padding().frame(width: 500, height: 500)
    }
}
