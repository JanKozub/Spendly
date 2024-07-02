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
                GeometryReader { reader in
                    List {
                        Section {
                            HStack {
                                Text("Issued(D)").frame(maxWidth: reader.size.width * 0.08, alignment: .center)
                                Text("Transaction(D)").frame(maxWidth: reader.size.width * 0.08, alignment: .center)
                                Text("Title").frame(maxWidth: reader.size.width * 0.36, alignment: .center)
                                Text("Message").frame(maxWidth: reader.size.width * 0.18, alignment: .center)
                                Text("Amount").frame(maxWidth: reader.size.width * 0.07, alignment: .center)
                                Text("Balance").frame(maxWidth: reader.size.width * 0.07, alignment: .center)
                                Text("Category").frame(maxWidth: reader.size.width * 0.08, alignment: .center)
                                Text("Type").frame(maxWidth: reader.size.width * 0.08, alignment: .center)
                            }
                        }.padding(.top).padding(.top).padding(.top).padding(.top)
                        
                        Section {
                            ForEach($payments, id: \.self) {$payment in PaymentView(payment: $payment, width: .constant(reader.size.width))}
                        }
                    }
                    .frame( maxWidth: .infinity)
                    .edgesIgnoringSafeArea(.all)
                    .listStyle(PlainListStyle())
                }
            }
        }.toolbar {}
    }
    
    
}

#Preview {
    SpendingsView().padding()
}
