//
//  SpendingsView.swift
//  LifeManager
//
//  Created by Jan Kozub on 15/06/2024.
//

import SwiftUI
import Foundation
import SwiftData

struct SpendingsView: View {
    @State private var payments = [Payment]()
    @State private var importing = false
    
    @State private var top10Payments = ["1.test", "2.test", "3.test", "4.test", "5.test", "6.test", "7.test", "8.test", "9.test", "10.test"]
    
    @Query private var years: [Year]
    
    var body: some View {
        if (payments.isEmpty) {
            GeometryReader { reader in
                VStack {
                    HStack {
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: reader.size.height * 0.5, alignment: .top)
                    .border(.red)
                    
                    Divider()
                    
                    HStack {
                        VStack {
                            List {
                                ForEach(top10Payments, id: \.self) { el in
                                    Text(el)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: reader.size.height * 0.5, alignment: .top)
                        Divider()
                        VStack {
                            Button(action: {
                                let panel = NSOpenPanel()
                                panel.begin { result in
                                    if result == .OK, let fileURL = panel.url {
                                        payments = Payment.loadSantanderPaymentsFromCSV(file: fileURL)
                                    }
                                }
                            }) {Text("Import new month").frame(maxWidth: .infinity, minHeight: reader.size.height * 0.15)}
                            
                            Button(action: {
                                print("Button tapped!")
                                
                            }) {Text("Edit this month").frame(maxWidth: .infinity, minHeight: reader.size.height * 0.15)}
                            
                            Button(action: {
                                print("Button tapped!")
                                
                            }) {Text("Settings").frame(maxWidth: .infinity, minHeight: reader.size.height * 0.15)}
                        }
                        .frame(maxWidth: .infinity, maxHeight: reader.size.height * 0.5, alignment: .top)
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup {
                    DropdownMenu(selectedCategory: "Other", elements: ["Other", "test2"]).frame(width: 150)
                }
            }
            .padding(.all)
        } else {
            TableView(payments: $payments, years: .constant(years))
        }
    }
}

#Preview {
    SpendingsView().padding()
}
