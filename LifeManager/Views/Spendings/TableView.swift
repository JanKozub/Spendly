//
//  TableView.swift
//  LifeManager
//
//  Created by Jan Kozub on 02/07/2024.
//

import SwiftUI

struct TableView: View {
    @Binding var payments: [Payment];
    
    var body: some View {
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
}

#Preview {
    TableView(payments: .constant([]))
}
