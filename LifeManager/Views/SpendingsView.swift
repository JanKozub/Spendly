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
    
    var body: some View {
        VStack {
            if (payments.isEmpty) {
                Button("Import") {
                    let panel = NSOpenPanel()
                    panel.begin { result in
                        if result == .OK, let fileURL = panel.url {
                            payments = Payment.loadSantanderPaymentsFromCSV(file: fileURL)
                        }
                    }
                }.controlSize(.extraLarge)
            } else {
                List {
                    Section {
                        HStack {
                            Text("Issued Date:").frame(maxWidth: 100, alignment: .center)
                            Text("Transaction Date:").frame(maxWidth: 150, alignment: .center)
                            Text("Title:").frame(maxWidth: .infinity, alignment: .center)
                            Text("Message:").frame(maxWidth: .infinity, alignment: .center)
                            Text("Amount:").frame(maxWidth: 100, alignment: .center)
                            Text("Balance:").frame(maxWidth: 100, alignment: .center)
                        }
                    }.padding(.top).padding(.top).padding(.top).padding(.top)
                    
                    Section {
                        ForEach($payments, id: \.self) {$payment in PaymentView(payment: $payment)}
                    }
                }
                .frame( maxWidth: .infinity)
                .edgesIgnoringSafeArea(.all)
                .listStyle(PlainListStyle())
            }
        }.toolbar {}
    }
    
    
}

#Preview {
    SpendingsView().padding()
}
