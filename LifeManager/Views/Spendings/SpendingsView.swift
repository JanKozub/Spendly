//
//  SpendingsView.swift
//  LifeManager
//
//  Created by Jan Kozub on 15/06/2024.
//

import SwiftUI
import Foundation

struct SpendingsView: View {
    @State private var payments = [Payment]()
    @State private var importing = false
    
    @State private var top10Payments = ["1.test","2.test","3.test","4.test","5.test","6.test","7.test","8.test"]
    
    var body: some View {
        if (payments.isEmpty) {
            
            GeometryReader { reader in
                HStack {
                    VStack {
                        VStack {
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: reader.size.height * 0.5, alignment: .top)
                        .border(.red)
                        Divider()
                        VStack {
                            
                        }
                        .frame(maxWidth: .infinity, maxHeight: reader.size.height * 0.5, alignment: .top)
                        .border(.blue)
                    }
                    
                    Divider()
                    
                    VStack {
                        VStack {
                            Button(action: {
                                let panel = NSOpenPanel()
                                panel.begin { result in
                                    if result == .OK, let fileURL = panel.url {
                                        payments = Payment.loadSantanderPaymentsFromCSV(file: fileURL)
                                    }
                                }
                            }) {
                                Text("Import new month")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: reader.size.height * 0.1)
                            }
                            Button(action: {
                                print("Button tapped!")
                            }) {
                                Text("Edit this month")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: reader.size.height * 0.1)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: reader.size.height * 0.25, alignment: .top)
                        Divider()
                        VStack {
                            List {
                                ForEach(top10Payments, id: \.self) { el in
                                    Text(el)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: reader.size.height * 0.75, alignment: .top)
                    }
                }
            }
            .toolbar {
                ToolbarItemGroup {
                    CategoryMenu(elements: .constant(["Other", "test2"])).frame(width: 150)
                }
            }
            .padding(.all)
        } else {
            TableView(payments: .constant(payments))
        }
    }
}

#Preview {
    SpendingsView().padding()
}
